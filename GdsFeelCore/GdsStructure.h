// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import "GdsLibrary.h"

@interface GdsStructure : NSObject
{
  NSString *_directoryPath;
  GdsLibrary *_library;
  NSString *_name;
  NSMutableArray *_elements;
  NSValue *_boundingBox;
}
- initWithDirectoryPath: (NSString *) directoryPath
		library: (GdsLibrary *) library;

- (void) dealloc;

- (NSString *) name;
- (NSString *) keyName;
- (void) debugLog;

- (GdsLibrary *) library;
- (NSRect) boundingBox;
- (NSArray *) elements;
@end
// vim: filetype=objc
