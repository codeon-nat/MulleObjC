//
//  NSType.h
//  MulleObjC
//
//  Created by Nat! on 09.03.15.
//  Copyright (c) 2015 Mulle kybernetiK. All rights reserved.
//

#ifndef ns_type__h__
#define ns_type__h__

#include "ns_objc_include.h"

//
// allow isa with cpp define
//
#define isa       ((Class) _mulle_objc_object_get_isa( self))

//
// this should be C readable
// these are here in the header, but they are actually defined by the
// compiler. So you can't change them.
//
// --- compiler defined begin ---
typedef void                          *id;
typedef struct _mulle_objc_class      *Class;

//
// Protocol as a valid keyword and a pseudo-class does not exist
// @protocol( Foo) returns an unsigned long
// For other compilers say   `typedef Protocol   *PROTOCOL`
// and code will work on both sides.
//
typedef mulle_objc_methodid_t         SEL;
typedef SEL                           PROTOCOL;
typedef struct _mulle_objc_method     *Method;
typedef void                          *(*IMP)( void *, SEL, void *params);
// --- compiler defined end ---

// turn off this warning, because it's wrong for us
#pragma clang diagnostic ignored "-Wcast-of-sel-type"


//
// in AAM define some harmless syntax sugar, so more stuff compiles
//
#ifdef __OBJC_AAM__
# define __bridge
# define __unsafe_unretained
#endif


#ifndef NSINTEGER_DEFINED

// resist the temptation to typedef(!)
// but why ?
typedef uintptr_t   NSUInteger;
typedef intptr_t    NSInteger;

#define NSIntegerMax    ((NSInteger) (((NSUInteger) -1) >> 1))
#define NSIntegerMin    (-((NSInteger) (((NSUInteger) -1) >> 1)) - 1)
#define NSUIntegerMax   ((NSUInteger) -1)
#define NSUIntegerMin   0

#define NSINTEGER_DEFINED

#endif


// enum can't hold it
#define NSNotFound    NSIntegerMax


typedef enum
{
   NSOrderedAscending = -1,
   NSOrderedSame,
   NSOrderedDescending
} NSComparisonResult;


#define nil   ((id) 0)
#define Nil   ((Class) 0)


enum _MulleBool
{
   YES = 1,
   NO  = 0
};	     

//
// the hated BOOL. here it is an int 
// on windows it unfortunately already exists in "minwindef.h"
// so don't typedef it
//
#if defined( _WIN32) 
# ifndef _MINWINDEF_
#  error "#include <minwindef.h> missing"
# endif
#else 
typedef enum _MulleBool   BOOL;
#endif

enum
{
   MULLE_OBJC_IS_CLASSCLUSTER = (MULLE_OBJC_FOUNDATION_BIT0 << 0),
   MULLE_OBJC_IS_SINGLETON    = (MULLE_OBJC_FOUNDATION_BIT0 << 1)
};
#endif
