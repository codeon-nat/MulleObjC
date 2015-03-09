/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSDebug.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "ns_type.h"

#import "ns_debug.h"
#import "NSObject.h"


char   *_NSPrintForDebugger( id a);
void   NSZombifyObject( id obj);

//
// move all DEBUG stuff out into a "mulleDebug.dylib" we can dynamically
// add
//

@interface NSObject( NSDebug)

- (id) debugDescription;
- (void) __willBeAddedToAutoreleasePool:(id) pool;
- (void) __checkReferenceCount;

@end


