// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import "GdsLibrary.h"
#import "GdsElement.h"

@interface GdsStructure : NSObject
{
  GdsLibrary     *_library;
  NSString       *_name;
  NSMutableArray *_elements;
  NSValue        *_boundingBox;
}
- (id) initWithLibrary: (GdsLibrary *)library;
- (void) dealloc;

- (NSString *) name;
- (void) setName: (NSString *)name;

- (NSString *) keyName;
- (void) debugLog;

- (GdsLibrary *) library;
- (void) setLibrary: (GdsLibrary *)library;

- (NSRect) boundingBox;
- (NSArray *) elements;

- (void) addElement: (GdsElement *)newElement;
- (void) loadElements;
- (NSRect) lookupBoundingBox;
@end

// vim: filetype=objc ts=2 sw=2 expandtab
