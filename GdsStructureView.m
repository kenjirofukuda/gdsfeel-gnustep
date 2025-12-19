#import <AppKit/AppKit.h>
#import "GdsStructureView.h"
#import "GdsFeelCore/GdsElement.h"
#import "GdsFeelCore/NSArray+Elements.h"
#import "GdsFeelCore/GdsLayer.h"
#import "GdsElementDrawer.h"
#import "GdsElement+Drawing.h"

NSString *GdsStructureDidChangeNotification
  = @"GdsStructureDidChangeNotification";

NSRect
RectFromPoints(NSPoint point1, NSPoint point2);
CGFloat
DistanceFromPoints(NSPoint a, NSPoint b);

@interface GdsStructureView (Override)
- (BOOL) acceptsFirstResponder;
- (BOOL) acceptsFirstMouse: (NSEvent *)event;
- (BOOL) preservesContentDuringLiveResize;
- (void) viewDidEndLiveResize;
- (void) viewDidMoveToWindow;
@end

@interface GdsStructureView (Drawing)
- (void) drawElement: (GdsElement *)element;
- (void) basicDrawElements: (NSArray *)elements;
- (void) forceRedraw;
- (NSColor *) backgroundColor;
- (NSImage *) fullImage;
@end

@interface GdsStructureView (Private)
- (void) viewFrameChanged: (NSNotification *)aNotification;
- (NSPoint) localPoint: (NSEvent *)theEvent;
- (void) rubberbandWithEvent: (NSEvent *)theEvent;
- (void) rubberbandWithEvent: (NSEvent *)theEvent
                      point1: (NSPoint *)point1
                      point2: (NSPoint *)point2;
- (void) removeTrack;
- (void) updateCursorLocation: (NSEvent *)theEvent;
@end

@implementation GdsStructureView // (Public)
- (id) initWithFrame: (NSRect)frame
{
  self = [super initWithFrame: frame];
  if (self != nil)
    {
      _rubberbandRect = NSZeroRect;
      [self setPostsFrameChangedNotifications: YES];
      [[self window] setAcceptsMouseMovedEvents: YES];
      [[NSNotificationCenter defaultCenter]
       addObserver: self
          selector: @selector(viewFrameChanged:)
              name: NSViewFrameDidChangeNotification
            object: nil];
    }
  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  [self removeTrack];
  RELEASE(_viewport);
  TEST_RELEASE(_structure);
  RELEASE(_infoBar);
  DEALLOC;
}

- (void) setInfoBar: (id)infoBar
{
  ASSIGN(_infoBar, infoBar);
}

- (GdsStructure *) structure
{
  return _structure;
}

- (void) setStructure: (GdsStructure *)structure
{
  GdsStructure *oldStructure = _structure;
  if (oldStructure == structure)
    return;
  ASSIGN(_structure, structure);
  ASSIGN(_viewport, [[GdsViewport alloc] initWithStructure: _structure]);
  [self viewFrameChanged: (NSNotification *) nil];
  [[self viewport] fit];
  [self setNeedsDisplay: YES];
  [[NSNotificationCenter defaultCenter]
   postNotificationName: GdsStructureDidChangeNotification
                 object: self];
}

- (GdsViewport *) viewport
{
  return _viewport;
}

- (void) drawRect: (NSRect)rect
{
  [super drawRect: rect];
  [[self backgroundColor] set];
  NSRectFill(rect);
  if (_structure == nil)
    return;

  [[self fullImage] compositeToPoint: NSMakePoint(0, 0)
                           operation: NSCompositeCopy];

  if (!NSEqualRects(_rubberbandRect, NSZeroRect))
    {
      [[NSColor knobColor] set];
      NSFrameRect(_rubberbandRect);
    }
}

- (void) drawElements: (NSArray *)elements transform: tx
{
  NSMutableArray *primitives;
  NSMutableArray *references;

  primitives = [NSMutableArray new];
  references = [NSMutableArray new];
  [elements getPrimitivesOn:primitives referencesOn:references];
  if (tx != nil)
    {
      [tx concat];
    }
  else 
    {
      [[_viewport transform] concat];
    }
  [self basicDrawElements: primitives];
  [self basicDrawElements: references];
  RELEASE(primitives);
  RELEASE(references);
}

@end // (Public)

@implementation GdsStructureView (Override)
- (BOOL) acceptsFirstResponder
{
  return YES;
}

- (BOOL) acceptsFirstMouse: (NSEvent *)event
{
  return YES;
}

- (BOOL) preservesContentDuringLiveResize
{
  return NO;
}

- (void) viewDidEndLiveResize
{
  [self forceRedraw];
  [super viewDidEndLiveResize];
}

- (void) viewDidMoveToWindow
{
  [super viewDidMoveToWindow];
  [self removeTrack];
  _trackId = [self addTrackingRect: [self bounds]
                             owner: self
                          userData: NULL
                      assumeInside: NO];
}

@end // (Override)

@implementation GdsStructureView (Drawing)
- (void) basicDrawElements: (NSArray *)elements
{
  //  [[_viewport transform] concat];
  for (GdsElement *element in elements) 
    {
      [self drawElement: element];
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
  [[self backgroundColor] set];
  NSRectFill(NSMakeRect(0, 0, [_offImage size].width, [_offImage size].height));

  NSDate *startTime = [NSDate date];

  [self drawElements: [_structure elements] transform: nil];

  NSTimeInterval elapsedTime = [startTime timeIntervalSinceNow];
  NSString      *str = [NSString
                        stringWithFormat: @"Elapsed time: %f msecs", fabs(elapsedTime) * 1000.0];
  NSLog(@ "%@", str);
  [_offImage unlockFocus];
  return _offImage;
}

- (NSColor *) backgroundColor;
{
  return [NSColor blackColor];
}

- (void)drawElement: (GdsElement *)element
{
  [element fullDrawOn: self];  
}

@end // (Drawing)

@implementation GdsStructureView (Events)
- (void) mouseDown: (NSEvent *)theEvent
{
  [self rubberbandWithEvent: theEvent];
}

- (void) mouseEntered: (NSEvent *)theEvent
{
  NSLog(@"%@", @"#mouseEntered:");
  [[self window] makeFirstResponder: self];
  [[self window] setAcceptsMouseMovedEvents: YES];
}

- (void) mouseExited: (NSEvent *)theEvent
{
  NSLog(@"%@", @"#mouseExited:");
  [[self window] setAcceptsMouseMovedEvents: NO];
}

- (void) mouseMoved: (NSEvent *)theEvent
{
  [self updateCursorLocation: theEvent];
}

- (void) keyDown: (NSEvent *)theEvent
{
  BOOL      handled = NO;
  NSString *characters;
  unichar   keyChar = 0;

  characters = [theEvent charactersIgnoringModifiers];
  if ([characters length] == 1)
    {
      keyChar = [characters characterAtIndex: 0];
      if (keyChar == NSHomeFunctionKey)
        {
          [self fit: nil];
          handled = YES;
        }
    }
  if (!handled && [characters isEqual: @"+"])
    {
      [self zoomDouble: nil];
      handled = YES;
    }
  if (!handled && [characters isEqual: @"-"])
    {
      [self zoomHalf: nil];
      handled = YES;
    }
  if (!handled)
    {
      [self interpretKeyEvents: [NSArray arrayWithObject: theEvent]];
      handled = YES;
    }
  if (!handled)
    {
      [super keyDown: theEvent];
      handled = YES;
    }
}

- (IBAction) moveUp: (id)sender
{
  [self viewMoveUp: sender];
}

- (IBAction) moveDown: (id)sender
{
  [self viewMoveDown: sender];
}

- (IBAction) moveRight: (id)sender
{
  [self viewMoveRight: sender];
}

- (IBAction) moveLeft: (id)sender
{
  [self viewMoveLeft: sender];
}
@end // (Events)

@implementation GdsStructureView (Private)
- (void) viewFrameChanged: (NSNotification *)aNotification
{
  NSDebugLog(@"#viewFrameChanged: %@", aNotification);
  [_viewport setPortSize: [self frame].size];
  [self removeTrack];
  _trackId = [self addTrackingRect: [self bounds]
                             owner: self
                          userData: NULL
                      assumeInside: NO];
  [self forceRedraw];
}

- (NSPoint) localPoint: (NSEvent *)theEvent
{
  return [self convertPoint: [theEvent locationInWindow] fromView: nil];
}

- (void) updateCursorLocation: (NSEvent *)theEvent
{
  NSPoint          vLoc = [self localPoint: theEvent];
  NSMutableString *s = [NSMutableString stringWithString: @"vLoc: "];
  [s appendString: NSStringFromPoint(vLoc)];
  if (_viewport)
    {
      NSAffineTransform *itx;
      NSPoint            wLoc;
      itx = [[NSAffineTransform alloc] initWithTransform: [_viewport transform]];
      [itx invert];
      wLoc = [itx transformPoint: vLoc];
      [s appendString: @"  wLoc: "];
      [s appendString: NSStringFromPoint(wLoc)];
      RELEASE(itx);
    }

  [_infoBar setStringValue: s];
}

- (void) rubberbandWithEvent: (NSEvent *)theEvent
{
  NSPoint            vLoc1;
  NSPoint            vLoc2;
  NSAffineTransform *itx;
  NSRect             wBounds;
  NSRect             vBounds;

  [self rubberbandWithEvent: theEvent point1: &vLoc1 point2: &vLoc2];
  if (!_viewport)
    return;
  vBounds = RectFromPoints(vLoc1, vLoc2);
  itx = [[NSAffineTransform alloc] initWithTransform: [_viewport transform]];
  [itx invert];
  wBounds.origin = [itx transformPoint: vBounds.origin];
  wBounds.size = [itx transformSize: vBounds.size];
  RELEASE(itx);
  if (vBounds.size.width > 2.0 && vBounds.size.height > 2.0)
    {
      // NSLog(@"wBounds = %@", NSStringFromRect(wBounds));
      [_viewport setBounds: wBounds];
    }
  else
    {
      [_viewport setCenter: wBounds.origin];
    }
  [self forceRedraw];
}

- (void) rubberbandWithEvent: (NSEvent *)theEvent
                      point1: (NSPoint *)point1
                      point2: (NSPoint *)point2
{
  *point1 = [self localPoint: theEvent];
  while (1)
    {
      theEvent = [[self window]
                  nextEventMatchingMask: (NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
      *point2 = [self localPoint: theEvent];
      [self updateCursorLocation: theEvent];
      // NSLog(@"curPoint = %@", NSStringFromPoint(*point2));

      if (NSEqualPoints(*point1, *point2))
        {
          if (!NSEqualRects(_rubberbandRect, NSZeroRect))
            {
              [self setNeedsDisplayInRect: _rubberbandRect];
            }
          _rubberbandRect = NSZeroRect;
        }
      else
        {
          [self setNeedsDisplayInRect: _rubberbandRect];
          NSRect newRect = RectFromPoints(*point1, *point2);
          _rubberbandRect = newRect;
          [self setNeedsDisplayInRect: _rubberbandRect];
        }
      if ([theEvent type] == NSLeftMouseUp)
        {
          break;
        }
    }
  if (!NSEqualRects(_rubberbandRect, NSZeroRect))
    {
      [self setNeedsDisplayInRect: _rubberbandRect];
    }
  _rubberbandRect = NSZeroRect;
}

- (void) removeTrack
{
  if (_trackId)
    [self removeTrackingRect: _trackId];
  _trackId = 0;
}

@end

@implementation GdsStructureView (Actions)
- (IBAction) fit: (id)sender
{
  [_viewport fit];
  [self forceRedraw];
}

- (IBAction) zoomDouble: (id)sender
{
  [_viewport setScale: [_viewport scale] * 2.0];
  [self forceRedraw];
  [self setNeedsDisplay: YES];
}

- (IBAction) zoomHalf: (id)sender
{
  [_viewport setScale: [_viewport scale] * 0.5];
  [self forceRedraw];
}

#define RATIO (0.3)

- (IBAction) viewMoveUp: (id)sender
{
  [_viewport viewMoveFractionX: 0.0 y: RATIO];
  [self forceRedraw];
}

- (IBAction) viewMoveDown: (id)sender
{
  [_viewport viewMoveFractionX: 0.0 y: -RATIO];
  [self forceRedraw];
}

- (IBAction) viewMoveRight: (id)sender
{
  [_viewport viewMoveFractionX: RATIO y: 0.0];
  [self forceRedraw];
}

- (IBAction) viewMoveLeft: (id)sender
{
  [_viewport viewMoveFractionX: -RATIO y: 0.0];
  [self forceRedraw];
}

@end

CGFloat
DistanceFromPoints(NSPoint a, NSPoint b)
{
  CGFloat dX = a.x - b.x;
  CGFloat dY = a.y - b.y;
  return sqrt(dX * dX + dY * dY);
}

NSRect
RectFromPoints(NSPoint point1, NSPoint point2)
{
  return NSMakeRect(
           ((point1.x <= point2.x) ? point1.x : point2.x),
           ((point1.y <= point2.y) ? point1.y : point2.y),
           ((point1.x <= point2.x) ? point2.x - point1.x : point1.x - point2.x),
           ((point1.y <= point2.y) ? point2.y - point1.y : point1.y - point2.y));
}

// vim: sw=2 ts=2 expandtab filetype=objc
