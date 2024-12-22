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
  IBOutlet GdsStructureView *structureView;
  IBOutlet NSScrollView     *structuresArea;
  IBOutlet NSScrollView     *elementsArea;
  IBOutlet id                infoBarView;
  IBOutlet NSTableView      *structureListView;
  IBOutlet NSTableView      *elementListView;
@public
  ElementListDelegate *elementListDelegate;

}

- (void) dealloc;
- (ElementListDelegate *) elementListDelegate;
@end

// vim: sw=2 ts=2 expandtab filetype=objc
