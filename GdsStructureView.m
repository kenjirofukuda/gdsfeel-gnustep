#import <AppKit/AppKit.h>
#import "GdsStructureView.h"
#import "GdsFeelCore/GdsElement.h"
#import "GdsFeelCore/NSArray+Elements.h"
#import "GdsFeelCore/GdsLayer.h"
#import "GdsElementDrawer.h"

NSString *GdsStructureDidChangeNotification = 
  @"GdsStructureDidChangeNotification";

NSRect RectFromPoints(NSPoint point1, NSPoint point2);
CGFloat DistanceFromPoints(NSPoint a, NSPoint b);

@interface GdsStructureView (Private)
- (NSColor *) colorForElement: (GdsElement *) element;
- (void) drawElement: (GdsElement*) element;
- (void) viewFrameChanged: (NSNotification *) aNotification;
- (NSImage *) fullImage;
- (void) forceRedraw;
- (void) basicDrawElements: (NSArray *) elements;
- (NSColor *) backgroundColor;
- (NSPoint) localPoint: (NSEvent *) theEvent;
- (void) keyDown: (NSEvent *) theEvent;
- (void) mouseDown: (NSEvent *) theEvent;
- (void) rubberbandWithEvent: (NSEvent *) theEvent;
- (void) rubberbandWithEvent: (NSEvent *) theEvent
                      point1: (NSPoint *) point1
                      point2: (NSPoint *) point2;
@end

@implementation GdsStructureView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  if (self != nil)
    {
      _rubberbandRect = NSZeroRect;
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
  [[self backgroundColor] set];
  NSRectFill(rect);
  if (_structure == nil)
    return;
  
  [[self fullImage] compositeToPoint: NSMakePoint(0,0) 
                           operation: NSCompositeCopy];

 if (! NSEqualRects(_rubberbandRect, NSZeroRect))
   {
     [[NSColor knobColor] set];
     NSFrameRect(_rubberbandRect);
   }
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
  [self drawElements: [_structure elements]];
  [_offImage unlockFocus];
  return _offImage;
}

- (NSColor *) backgroundColor;
{
  return [NSColor blackColor];
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
#ifdef __MINGW32__
/**
 * GNUstep live resizeing not supported
 */
- (BOOL) inLiveResize
{
  static const CGFloat slipMargin = 20;
  NSEvent *evt = [NSApp currentEvent];
  // NSDebugLog(@"evt = %@", evt);
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
#endif

- (NSPoint) localPoint: (NSEvent *) theEvent
{
  return [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void) mouseDown: (NSEvent *) theEvent
{
  [self rubberbandWithEvent: theEvent];
}

- (void) rubberbandWithEvent: (NSEvent *) theEvent
{
  NSPoint vLoc1;
  NSPoint vLoc2;
  NSAffineTransform *itx;
  NSRect wBounds;
  NSRect vBounds;

  [self rubberbandWithEvent:theEvent point1:&vLoc1 point2:&vLoc2];
  vBounds = RectFromPoints(vLoc1, vLoc2);
  itx = [[NSAffineTransform alloc] initWithTransform: [_viewport transform]];
  [itx invert];
  wBounds.origin = [itx transformPoint: vBounds.origin];
  wBounds.size = [itx transformSize: vBounds.size];
  RELEASE(itx);
  if (4.0 < DistanceFromPoints(vLoc1, vLoc2))
    {
      //NSLog(@"wBounds = %@", NSStringFromRect(wBounds));
      [_viewport setBounds: wBounds];
    }
  else 
    {
      [_viewport setCenter: wBounds.origin];
    }
  [self forceRedraw];
}

- (void) rubberbandWithEvent: (NSEvent *) theEvent
                      point1: (NSPoint *) point1
                      point2: (NSPoint *) point2
{
  *point1 = [self localPoint: theEvent];
  while (1)
    {
      theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
      *point2 = [self localPoint: theEvent];
      //NSLog(@"curPoint = %@", NSStringFromPoint(*point2));

      if (NSEqualPoints(*point1, *point2))
        {
          if (! NSEqualRects(_rubberbandRect, NSZeroRect))
            {
              [self setNeedsDisplayInRect:_rubberbandRect];
            }
          _rubberbandRect = NSZeroRect;
        }
      else
        {
          [self setNeedsDisplayInRect:_rubberbandRect];
          NSRect newRect = RectFromPoints(*point1, *point2);   
          _rubberbandRect = newRect;
          [self setNeedsDisplayInRect:_rubberbandRect];
        }
      if ([theEvent type] == NSLeftMouseUp) 
        {
          break;
        }
    }
   if (! NSEqualRects(_rubberbandRect, NSZeroRect))
     {
       [self setNeedsDisplayInRect:_rubberbandRect];
     }
   _rubberbandRect = NSZeroRect;
}
  
- (void) keyDown: (NSEvent *) theEvent
{
  BOOL handled = NO;
  NSString  *characters;
  unichar keyChar = 0;
        
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
  if (! handled &&  [characters isEqual: @"+"])
    {
      [self zoomDouble: nil];
      handled = YES;
    }
  if (! handled && [characters isEqual: @"-"])
    {
      [self zoomHalf: nil];
      handled = YES;
    }
  if (! handled)
    {
      [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
      handled = YES;
   }
  if (! handled)
   {
     [super keyDown:theEvent];
      handled = YES;
   }
}

- (IBAction) moveUp: (id) sender
{
  [self viewMoveUp: sender];
}

- (IBAction) moveDown: (id) sender
{
  [self viewMoveDown: sender];
}


- (IBAction) moveRight: (id) sender
{
  [self viewMoveRight: sender];
}


- (IBAction) moveLeft: (id) sender
{
  [self viewMoveLeft: sender];
}

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

CGFloat DistanceFromPoints(NSPoint a, NSPoint b)
{
  CGFloat dX = a.x - b.x;
  CGFloat dY = a.y - b.y;
  return sqrt(dX*dX + dY*dY);
}

NSRect RectFromPoints(NSPoint point1, NSPoint point2)
{
  return NSMakeRect(((point1.x <= point2.x) ? point1.x : point2.x),
                    ((point1.y <= point2.y) ? point1.y : point2.y),
                    ((point1.x <= point2.x) ? point2.x - point1.x : point1.x - point2.x),
                    ((point1.y <= point2.y) ? point2.y - point1.y : point1.y - point2.y));
}


// vim: sw=2 ts=2 expandtab filetype=objc
