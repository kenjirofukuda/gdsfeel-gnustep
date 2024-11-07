// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>

#import "GdsLibrary.h"
#import "GdsStructure.h"
#import "GdsElement.h"

@interface GdsInform : NSObject
{
  NSString     *_filename;
  NSFileHandle *_fh;
  GdsLibrary   *_library;
  GdsStructure *_structure;
  GdsElement   *_element;
}

- (instancetype) initWithFilename: (NSString *)filename;
- (void) run;
@end
