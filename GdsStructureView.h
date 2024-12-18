// -*- mode: Objc -*-
#import <AppKit/AppKit.h>
#import "GdsFeelCore/GdsStructure.h"
#import "GdsFeelCore/GdsViewport.h"

extern NSString *GdsStructureDidChangeNotification;

@interface GdsStructureView : NSView
{
  GdsStructure     *_structure;
  GdsViewport      *_viewport;
  NSImage          *_offImage;
  NSRect            _rubberbandRect;
  NSTextField      *_infoBar;
  NSTrackingRectTag _trackId;
}
- (id) initWithFrame: (NSRect)frame;
- (void) dealloc;

- (GdsStructure *) structure;
- (void) setStructure: (GdsStructure *)structure;
- (GdsViewport *) viewport;

- (void) setInfoBar: (id)infoBar;

- (void) drawRect: (NSRect)rect;
- (void) drawElements: (NSArray *)elements;
@end

@interface GdsStructureView (Actions)
- (IBAction) fit: (id)sender;
- (IBAction) zoomDouble: (id)sender;
- (IBAction) zoomHalf: (id)sender;
- (IBAction) viewMoveUp: (id)sender;
- (IBAction) viewMoveDown: (id)sender;
- (IBAction) viewMoveRight: (id)sender;
- (IBAction) viewMoveLeft: (id)sender;
@end

// vim: sw=2 ts=2 expandtab filetype=objc
