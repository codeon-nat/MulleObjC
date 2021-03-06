/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSInvocation.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSInvocation.h"

#import "NSMethodSignature.h"
#import "NSMethodSignature+Private.h"
#import "MulleObjCAllocation.h"
#import "NSAutoreleasePool.h"
#import "NSCopying.h"


@implementation NSInvocation

- (id) initWithMethodSignature:(NSMethodSignature *) signature
{
   size_t                   size;
   struct mulle_allocator   *allocator;
   size_t                   s_voidptr5;
   size_t                   underflow;
   
   if( ! signature)
   {
      [self release];
      mulle_objc_throw_invalid_argument_exception( "signature is nil");
      return( nil);
   }

   size       = [signature frameLength];
   size      += [signature methodReturnLength];
   s_voidptr5 = sizeof( void *) * 5;
   underflow  = size % s_voidptr5;
   if( underflow)
      size  += s_voidptr5 - underflow;
   
   allocator = MulleObjCObjectGetAllocator( self);
   _storage  = mulle_allocator_calloc( allocator, 1, size);
   _sentinel = &((char *) _storage)[ size];
   
   _methodSignature = [signature retain];

   return( self);
}


- (void) _releaseArguments
{
   NSInteger   i, n;
   char        *type;
   id          obj;
   char        *s;
   
   n = [_methodSignature numberOfArguments];
   for( i = 0; i < n; ++i)
   {
      type = [_methodSignature getArgumentTypeAtIndex:i];
      switch( *type)
      {
      case _C_COPY_ID   :
      case _C_RETAIN_ID :
         [self getArgument:&obj
                  atIndex:i];
         [obj release];
         break;
            
      case _C_CHARPTR :
         [self getArgument:&s 
                  atIndex:i];
         mulle_allocator_free( MulleObjCObjectGetAllocator( self), s);
         break;
      }
   }
}


- (void) finalize
{
}


- (void) dealloc
{
   struct mulle_allocator  *allocator;

   if( _argumentsRetained)
      [self _releaseArguments];

   allocator = MulleObjCObjectGetAllocator( self);
   mulle_allocator_free( allocator, _storage);
   [_methodSignature release];

   NSDeallocateObject( self);
}


+ (NSInvocation *) invocationWithMethodSignature:(NSMethodSignature *) signature
{
   return( [[[self alloc] initWithMethodSignature:signature] autorelease]);
}


- (NSMethodSignature *) methodSignature
{
   return( _methodSignature);
}


static int   frameRangeCheck( NSInvocation *self, char *adr, size_t size)
{
   if( &adr[ size] < self->_storage)
      return( -1);
   if( &adr[ size] > self->_sentinel)
      return( -1);
   return( 0);
}


static inline void   pointerAndSizeOfArgumentValue( NSInvocation *self, NSUInteger i, void **p_adr, size_t *p_size)
{
   MulleObjCMethodSignatureTypeinfo   *p;
   char      *adr;
   size_t    size;
   
   p    = [self->_methodSignature _runtimeTypeInfoAtIndex:i];
   adr  = &((char *) self->_storage)[ p->offset];
   size = p->natural_size;
   
   if( frameRangeCheck( self, adr, size))
      MulleObjCThrowInvalidIndexException( i);
   
   *p_adr  = adr;
   *p_size = size;
}


- (void) getReturnValue:(void *) value_p
{
   void     *adr;
   size_t   size;
   
   assert( value_p);

   pointerAndSizeOfArgumentValue( self, 0, &adr, &size);
   memcpy( value_p, adr, size);
}


- (void) setReturnValue:(void *) value_p
{
   void     *adr;
   size_t   size;

   assert( value_p);
   
   pointerAndSizeOfArgumentValue( self, 0, &adr, &size);
   memcpy( adr, value_p, size);
}


- (void) getArgument:(void *) value_p 
             atIndex:(NSUInteger) i
{
   void     *adr;
   size_t   size;

   assert( value_p);
   
   pointerAndSizeOfArgumentValue( self, i + 1, &adr, &size);
   memcpy( value_p, adr, size);
}


- (void) setArgument:(void *) value_p 
             atIndex:(NSUInteger) i
{
   void     *adr;
   size_t   size;

   assert( value_p);
      
   pointerAndSizeOfArgumentValue( self, i + 1, &adr, &size);
   memcpy( adr, value_p, size);
}


- (void) retainArguments
{
   NSInteger   i, n;
   char        *type;
   id          obj;
   char        *s;
   char        *dup;
   
   if( _argumentsRetained)
   {
#if DEBUG      
      abort();
#endif      
      return;
   }
   
   if( [_methodSignature isVariadic])
      mulle_objc_throw_internal_inconsistency_exception( "NSInvocation can not retain the arguments of variadic methods");
   
   _argumentsRetained = YES;
   
   n = [_methodSignature numberOfArguments];
   for( i = 0; i < n; ++i)
   {
      type = [_methodSignature getArgumentTypeAtIndex:i];
      switch( *type)
      {
      case _C_RETAIN_ID :
         [self getArgument:&obj
                  atIndex:i];
         [obj retain];
         break;

      case _C_COPY_ID :
         [self getArgument:&obj
                  atIndex:i];
         obj = [(id <NSCopying>) obj copy];
         [self setArgument:&obj
                   atIndex:i];
         break;
            
      case _C_CHARPTR :
         [self getArgument:&s 
                  atIndex:i];
         dup  = mulle_allocator_strdup( MulleObjCObjectGetAllocator( self), s);
         [self setArgument:&dup
                  atIndex:i];
         break;
      }
   }
}


- (BOOL) argumentsRetained
{
   return( _argumentsRetained);
}


- (SEL) selector
{
   SEL   result;

   assert( sizeof( SEL) == sizeof( mulle_objc_methodid_t));
   
   [self getArgument:&result 
             atIndex:1];

   return( result);
}


- (void) setSelector:(SEL) selector
{
   [self setArgument:&selector 
             atIndex:1];
}


- (id) target 
{
   id   result;

   [self getArgument:&result 
             atIndex:0];

   return( result);
}


- (void) setTarget:target
{
   [self setArgument:&target 
             atIndex:0];
}


- (void) invoke
{
   [self invokeWithTarget:[self target]];
}


- (void) invokeWithTarget:(id) target
{
   SEL                                sel;
   MulleObjCMethodSignatureTypeinfo   *info;
   void                               *param;
   void                               *rval;
   MulleObjCMetaABIType               pType;
   MulleObjCMetaABIType               rType;
   
   sel = [self selector];
   if( ! sel)
      mulle_objc_throw_internal_inconsistency_exception( "NSInvocation: selector has not been set yet");
   
   pType = [_methodSignature _methodMetaABIParameterType];
   rType = [_methodSignature _methodMetaABIReturnType];
   
   param = NULL;
   switch( pType)
   {
   case MulleObjCMetaABITypeVoid           :
      if( rType == MulleObjCMetaABITypeParameterBlock)
      {
         info  = [self->_methodSignature _runtimeTypeInfoAtIndex:0];
         param = &self->_storage[ info->offset];
         rval  = mulle_objc_object_inline_variable_methodid_call( target, sel, param);
         break;
      }
      
      rval = mulle_objc_object_inline_variable_methodid_call( target, sel, target);
      break;
         
   case MulleObjCMetaABITypeVoidPointer    :
      info  = [self->_methodSignature _runtimeTypeInfoAtIndex:3];
      param = &self->_storage[ info->offset];
      rval  = mulle_objc_object_inline_variable_methodid_call( target, sel, *(void **) param);
      break;
         
   case MulleObjCMetaABITypeParameterBlock :
      info  = [self->_methodSignature _runtimeTypeInfoAtIndex:3];
      param = &self->_storage[ info->offset];
      rval  = mulle_objc_object_inline_variable_methodid_call( target, sel, param);
      break;
   }

   switch( rType)
   {
   case MulleObjCMetaABITypeVoid           :
      break;
      
   case MulleObjCMetaABITypeVoidPointer    :
      [self setReturnValue:&rval];
      break;
      
   case MulleObjCMetaABITypeParameterBlock :
      [self setReturnValue:param];
      break;
   }
}


- (void) _setMetaABIFrame:(void *) frame
{
   MulleObjCMethodSignatureTypeinfo   *info;
   void                               *param;
   size_t                             size;
   
   switch( [_methodSignature _methodMetaABIParameterType])
   {
   case MulleObjCMetaABITypeVoid           :
      break;
      
   case MulleObjCMetaABITypeVoidPointer    :
      info  = [self->_methodSignature _runtimeTypeInfoAtIndex:3];
      param = &((char *) self->_storage)[ info->offset];
      assert( ! frameRangeCheck( self, param, sizeof( void *)));
      
      *((void **) param) = frame;
      break;
      
   case MulleObjCMetaABITypeParameterBlock :
      info  = [self->_methodSignature _runtimeTypeInfoAtIndex:3];
      param = &((char *) self->_storage)[ info->offset];
      size  = [_methodSignature frameLength];
      assert( ! frameRangeCheck( self, param, size));
      
      memcpy( param, frame, size);
      break;
   }
}

@end

