// -*- mode: Objc -*-
#import <AppKit/AppKit.h>
#import "GdsFeelCore/GdsStructure.h"
#import "GdsFeelCore/GdsViewport.h"

extern NSString *GdsStructureDidChangeNotification;

@interface GdsStructureView : NSView
{
  GdsStructure *_structure;
  GdsViewport *_viewport;
}
- (id) initWithFrame: (NSRect) frame;
- (void) dealloc;

- (GdsStructure *) structure;
- (void) setStructure: (GdsStructure *) structure;
- (GdsViewport *) viewport;

- (void) drawRect: (NSRect) rect;
- (BOOL) acceptsFirstResponder;
- (BOOL) acceptsFirstMouse: (NSEvent *) event;
@end

@interface GdsStructureView (Actions)
- (IBAction) fit: (id) sender;
- (IBAction) zoomDouble: (id) sender;
- (IBAction) zoomHalf: (id) sender;
- (IBAction) viewMoveUp: (id) sender;
- (IBAction) viewMoveDown: (id) sender;
- (IBAction) viewMoveRight: (id) sender;
- (IBAction) viewMoveLeft: (id) sender;
@end
