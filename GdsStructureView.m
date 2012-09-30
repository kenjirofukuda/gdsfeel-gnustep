#import <AppKit/AppKit.h>
#import "GdsStructureView.h"
#import "GdsFeelCore/GdsElement.h"
#import "GdsFeelCore/NSArray+Elements.h"
#import "GdsFeelCore/GdsLayer.h"
#import "GdsElementDrawer.h"

NSString *GdsStructureDidChangeNotification = 
  @"GdsStructureDidChangeNotification";

@interface GdsStructureView (Private)
- (NSColor *) colorForElement: (GdsElement *) element;
- (void) drawElement: (GdsElement*) element;
- (void) viewFrameChanged: (NSNotification *) aNotification;
- (NSImage *) fullImage;
- (void) forceRedraw;
- (void) basicDrawElements: (NSArray *) elements;
@end

@implementation GdsStructureView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  if (self != nil)
    {
      [self setPostsFrameChangedNotifications: YES];
      [[NSNotificationCenter defaultCenter] 
        addObserver: self
           selector: @selector(viewFrameChanged:)
               name: NSViewFrameDidChangeNotification
             object: nil];
    }
  return self;
}

- (void)  dealloc
{
 [[NSNotificationCenter defaultCenter] removeObserver: self];
 RELEASE(_viewport);
 TEST_RELEASE(_structure);
  [super dealloc];
}

- (GdsStructure *) structure
{
  return _structure;
}

- (void) setStructure: (GdsStructure *) structure
{
  GdsStructure *oldStructure = _structure;
  if (oldStructure == structure)
    return;
  ASSIGN(_structure, structure);
  [[NSNotificationCenter defaultCenter] 
    postNotificationName: GdsStructureDidChangeNotification
                  object: self];
  ASSIGN(_viewport, [[GdsViewport alloc] initWithStructure: _structure]);
  [self viewFrameChanged: (NSNotification *) nil];
  [[self viewport] fit];
  [self setNeedsDisplay: YES];
}

- (GdsViewport *) viewport
{
  return _viewport;
}

- (void) drawRect: (NSRect) rect
{
  [super drawRect: rect];
  [[NSColor blackColor] set];
  NSRectFill(rect);
  if (_structure == nil)
    return;
  
  //  [self drawElements: [_structure elements]];
  [[self fullImage] compositeToPoint: NSMakePoint(0,0) 
                            operation: NSCompositeCopy];
}

- (BOOL) acceptsFirstResponder
{
  return YES;
}

- (BOOL) acceptsFirstMouse: (NSEvent *) event
{
  return YES;
}

- (BOOL) preservesContentDuringLiveResize
{
  return YES;
}

- (void) drawElements: (NSArray *) elements
{
  NSMutableArray *primitives;
  NSMutableArray *references;

  primitives = [NSMutableArray new];
  references = [NSMutableArray new];
  [elements getPrimitivesOn: primitives referencesOn: references];
  [self basicDrawElements: primitives];
  [self basicDrawElements: references];
  RELEASE(primitives);
  RELEASE(references);
}


- (void) viewDidEndLiveResize
{
  [self forceRedraw];
  [super viewDidEndLiveResize];
}

@end

@implementation GdsStructureView (Private)
- (void) basicDrawElements: (NSArray *) elements
{
  GdsElement *element;
  NSEnumerator *iter;

  iter = [elements objectEnumerator];
  [[NSColor whiteColor] set];  
  while ((element = [iter nextObject]) != nil)
    {
      [[self colorForElement: element] set];
      [self drawElement: element];
      // [element debugLog];
    }
}

- (void) forceRedraw
{
  DESTROY(_offImage);
  [self setNeedsDisplay: YES];  
}

- (NSImage *) fullImage
{
  if (_offImage)
    return _offImage;

  _offImage = [[NSImage alloc] initWithSize: [self frame].size];
  [_offImage lockFocus];
  [self drawElements: [_structure elements]];
  [_offImage unlockFocus];
  return _offImage;
}

- (NSColor *) colorForElement: (GdsElement *) element
{
  if ([element isReference])
    return [NSColor lightGrayColor];
  GdsPrimitiveElement *primitive = (GdsPrimitiveElement *) element;
  return [[[[[primitive structure] library] layers] 
      layerAtNumber: [primitive layerNumber]] color];
}

- (void) drawElement: (GdsElement*) element
{
  GdsElementDrawer *drawer;
  Class drawerClass;
  drawerClass = [GdsElementDrawer drawerClassForElement: element];
  if (drawerClass == Nil)
    {
      return;
    }
  drawer = AUTORELEASE([[drawerClass alloc] initWithElement: element view: self]);
  [drawer draw];
}

- (void) viewFrameChanged: (NSNotification *) aNotification
{
  NSDebugLog(@"#viewFrameChanged:");
  [_viewport setPortSize: [self frame].size];
  //if (! [self inLiveResize])
  [self forceRedraw];
}

#ifdef GNUSTEP
/**
 * GNUstep live resizeing not supported
 */
- (BOOL) inLiveResize
{
  static const CGFloat slipMargin = 20;
  NSEvent *evt = [NSApp currentEvent];
  if ([evt type] == NSLeftMouseUp)
    return NO;

  NSPoint globalLoc = [NSEvent mouseLocation];
  NSPoint windowLoc = [[self window] convertScreenToBase:globalLoc];
  NSPoint viewLoc = [self convertPoint: windowLoc fromView: nil];
  NSRect checkRect = [self frame];

  checkRect.size.width -= slipMargin;
  checkRect.size.height -= slipMargin;
  checkRect.origin.y += slipMargin;
  return ! NSPointInRect(viewLoc, checkRect);
}
#endif

@end

@implementation GdsStructureView (Actions)
- (IBAction) fit: (id) sender
{
  [_viewport fit];
  [self forceRedraw];
}

- (IBAction) zoomDouble: (id) sender
{
  [_viewport setScale: [_viewport scale] * 2.0];
  [self forceRedraw];
  [self setNeedsDisplay: YES];
}

- (IBAction) zoomHalf: (id) sender
{
  [_viewport setScale: [_viewport scale] * 0.5];
  [self forceRedraw];
}

#define RATIO (0.3)


- (IBAction) viewMoveUp: (id) sender
{
  [_viewport viewMoveFractionX: 0.0 y: RATIO];
  [self forceRedraw];
}

- (IBAction) viewMoveDown: (id) sender
{
  [_viewport viewMoveFractionX: 0.0 y: -RATIO];
  [self forceRedraw];
}

- (IBAction) viewMoveRight: (id) sender
{
  [_viewport viewMoveFractionX: RATIO y: 0.0];
  [self forceRedraw];
}

- (IBAction) viewMoveLeft: (id) sender
{
  [_viewport viewMoveFractionX: -RATIO y: 0.0];
  [self forceRedraw];
}

@end

// vim: sw=2 ts=2 expandtab filetype=objc
