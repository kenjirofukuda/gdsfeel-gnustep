// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "GdsFeelCore/GdsLibrary.h"
#import "GdsStructureView.h"

@interface GdsLibraryDocument : GSMarkupDocument
{
  GdsLibrary *_library;
  NSArray *_structureNames;

  IBOutlet GdsStructureView *structureView;
  IBOutlet id structureListView;
}

- (void) dealloc;
@end
