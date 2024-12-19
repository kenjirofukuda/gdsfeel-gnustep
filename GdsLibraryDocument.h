// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "GdsFeelCore/GdsZipedLibrary.h"
#import "GdsStructureView.h"

@interface GdsLibraryDocument : GSMarkupDocument
{
  GdsZipedLibrary *_library;
  NSArray         *_structureNames;

  IBOutlet GdsStructureView *structureView;
  IBOutlet NSScrollView     *structuresArea;
  IBOutlet id                structureListView;
  IBOutlet id                infoBarView;
}

- (void) dealloc;
@end

// vim: sw=2 ts=2 expandtab filetype=objc
