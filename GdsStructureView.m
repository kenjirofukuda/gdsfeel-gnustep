#import <AppKit/AppKit.h>
#import "GdsStructureView.h"
#import "GdsFeelCore/GdsElement.h"
#import "GdsFeelCore/GdsLayer.h"
#import "GdsElementDrawer.h"

NSString *GdsStructureDidChangeNotification = 
  @"GdsStructureDidChangeNotification";

@interface GdsStructureView (Private)
- (NSColor *) colorForElement: (GdsElement *) element;
- (void) drawElement: (GdsElement*) element;
- (void) viewFrameChanged: (NSNotification *) aNotification;
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
  NSEnumerator *iter = [[_structure elements] objectEnumerator];
  GdsElement *element;
  [[NSColor whiteColor] set];  
  while ((element = [iter nextObject]) != nil)
    {
      [[self colorForElement: element] set];
      [self drawElement: element];
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

@end

@implementation GdsStructureView (Private)
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
  drawer = AUTORELEASE([[drawerClass alloc]
			 initWithElement: element view: self]);
  [drawer draw];
}

- (void) viewFrameChanged: (NSNotification *) aNotification
{
  NSDebugLog(@"#viewFrameChanged:");
  [_viewport setPortSize: [self frame].size];
}

@end

@implementation GdsStructureView (Actions)
- (IBAction) fit: (id) sender
{
}

- (IBAction) zoomDouble: (id) sender
{
}

- (IBAction) zoomHalf: (id) sender
{
}

- (IBAction) viewMoveUp: (id) sender
{
}

- (IBAction) viewMoveDown: (id) sender
{
}

- (IBAction) viewMoveRight: (id) sender
{
}

- (IBAction) viewMoveLeft: (id) sender
{
}

@end
