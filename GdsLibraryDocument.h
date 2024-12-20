// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "GdsFeelCore/GdsZipedLibrary.h"
#import "GdsStructureView.h"

@interface ElementListDelegate : NSObject
{
  GdsStructure *_structure;
}
- (instancetype) init;
- (void) dealloc;
- (void) setStructure: (GdsStructure *)structure;
@end


@interface GdsLibraryDocument : GSMarkupDocument
{
  GdsZipedLibrary     *_library;
  NSArray             *_structureNames;
  ElementListDelegate *_elementListDelegate;

  IBOutlet GdsStructureView *structureView;
  IBOutlet NSScrollView     *structuresArea;
  IBOutlet id                structureListView;
  IBOutlet NSScrollView     *elementsArea;
  IBOutlet id                elementListView;
  IBOutlet id                infoBarView;
}

- (void) dealloc;
@end

// vim: sw=2 ts=2 expandtab filetype=objc
