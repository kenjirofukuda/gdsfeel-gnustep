// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "GdsFeelCore/GdsLibrary.h"
#import "GdsStructureView.h"

@interface GdsLibraryDocument : GSMarkupDocument
{
  GdsZipedLibrary *_library;
  NSArray *_structureNames;

  IBOutlet GdsStructureView *structureView;
  IBOutlet id structureListView;
  IBOutlet id infoBarView;
}

- (void) dealloc;
@end

// vim: sw=2 ts=2 expandtab filetype=objc
