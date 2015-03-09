
/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSThread.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSThread.h"
#import "NSAutoreleasePool.h"

#include <mulle_thread/mulle_thread.h>
#include <stdlib.h>


@implementation NSThread

static BOOL                  __NSIsMultiThreaded;
static mulle_thread_key_t    __NSThreadObjectKey;



/*
 */
- (id) initWithTarget:(id) target
             selector:(SEL) selector
               object:(id) argument
{
   self->target   = [target retain];
   self->argument = [argument retain];
   
   return( self);
}


- (void) dealloc
{
   [self->target release];
   [self->argument release];

   // experimentally put here:, in case the main thread
   // does not call bouncyBounceEnd
   _NSAutoreleasePoolConfigurationUnsetThread();
   
   mulle_objc_instance_free( self);
}


static void   bouncyBounceEnd( void *thread);


+ (void) load
{
   NSThread   *thread;
   /* make the current "load" thread the main thread
      needs */
   mulle_objc_runtime_dump_graphviz();
   thread = [NSThread new];
   [thread makeRuntimeThread];
}


+ (void) initialize
{
   if( ! __NSThreadObjectKey)
      mulle_thread_key_create( &__NSThreadObjectKey, bouncyBounceEnd);
}


- (NSThread *) makeRuntimeThread
{
   struct _mulle_objc_runtime   *runtime;
   
   if( mulle_thread_getspecific( __NSThreadObjectKey))
      return;

   runtime = _mulle_objc_get_runtime();
   assert( runtime);

   mulle_thread_setspecific( __NSThreadObjectKey, self);

   if( _mulle_objc_runtime_lookup_class( runtime,  MULLE_OBJC_CLASS_ID( 0x511c9ac972f81c49)))
      _NSAutoreleasePoolConfigurationSetThread();
      
   return( self);
}

+ (NSThread *) makeRuntimeThread
{
   return( [[NSThread new] makeRuntimeThread]);
}


+ (NSThread *) currentThread
{
   NSThread   *p;
   
   p = mulle_thread_getspecific( __NSThreadObjectKey);
   assert( p);
   return( p);  // not a leak
}


+ (void) _goingSingleThreaded
{
   // but still multi-threaded ATM (!)
   // another thread could be starting up right now from the main thread
   // also some thread destructors might be running
}


+ (void) _isGoingMultiThreaded
{
   //
   // when a notification fires here, it's for "technical" purposes still
   // single threaded.
   //
}


- (void) _threadWillExit
{
   // this will be done later by someone else
   //[[NSNotificationCenter defaultCenter] postNotificationName:NSThreadWillExitNotification
   //                                                    object:[NSThread currentThread]];
}


static mulle_atomic_ptr_t   __NSNumberOfThreads;


static void   bouncyBounceEnd( void *_thread)
{
   NSThread  *thread;

   [thread _threadWillExit];
   [thread release];

   if( ! _mulle_atomic_decrement_pointer( &__NSNumberOfThreads))
   {
      [NSThread _goingSingleThreaded];
      __NSIsMultiThreaded = NO;
   }
}


static void   *bouncyBounce( NSThread *thread)
{
   id                           rval;
   struct _mulle_objc_runtime   *runtime;
   struct _mulle_objc_class     *cls;
   
   __NSIsMultiThreaded = YES;

   [thread makeRuntimeThread];

   return( mulle_objc_object_call( thread->target, thread->sel, thread->argument));
}


+ (void) detachNewThreadSelector:(SEL) sel
                        toTarget:(id) target
                      withObject:(id) argument
{
   NSThread                     *thread;
   struct _mulle_objc_runtime   *runtime;
   mulle_thread_t                m_thread;
   
   if( ! _mulle_atomic_increment_pointer( &__NSNumberOfThreads))
      [NSThread _isGoingMultiThreaded];
   
   thread = [[NSThread alloc] initWithTarget:target
                                    selector:sel
                                      object:argument];
   
   if( mulle_thread_create( (void *(*)( void *)) bouncyBounce, thread, &m_thread))
      __NSThrowErrnoException( "thread creation");
}


+ (void) exit
{
   mulle_thread_cancel();
}


+ (BOOL) isMultiThreaded
{
   return( __NSIsMultiThreaded);
}

@end

