#import <Foundation/Foundation.h>
#import "GdsElementDrawer.h"
#import "GdsFeelCore/GdsElement.h"
#import "GdsStructureView.h"

@interface GdsElementDrawer (Private)
- (GdsViewport *) viewport;
- (void) strokeOutline;
- (void) strokePoints: (NSArray *) points;
- (void) strokePoints: (NSArray *) points
	          transform: (NSAffineTransform *) transform;
@end


@implementation GdsElementDrawer
- (id) initWithElement: (GdsElement *) element view: (GdsStructureView *) view
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_element, element);
      ASSIGN(_structureView, view);
    }
  return self;  
}

- (void) dealloc
{
  RELEASE(_element);
  RELEASE(_structureView);
  [super dealloc];
}

- (void) draw
{
  [self strokeOutline];
}

+ (Class) drawerClassForElement: (GdsElement *) element
{
  Class class = [GdsElementDrawer class];
  NSString *className = NSStringFromClass([element class]);
  if ([className isEqualToString: @"GdsSref"] == YES)
    {
      return [GdsSrefDrawer class];
    }
  if ([className isEqualToString: @"GdsAref"] == YES)
    {
      return [GdsArefDrawer class];
    }
  return class;
}

@end

@implementation GdsElementDrawer (Private)
- (GdsViewport *) viewport
{
  return [_structureView viewport];
}

- (void) strokeOutline
{
  [self strokePoints: [_element outlinePoints] 
	         transform: [[self viewport] transform]];
}

- (void) strokePoints: (NSArray *) points
{
  [self strokePoints: points transform: nil];
}

- (void) strokePoints: (NSArray *) points 
	          transform: (NSAffineTransform *) transform
{
  NSBezierPath *path = [NSBezierPath bezierPath];
  int i;
  for (i = 0; i < [points count]; i++) 
    {
      NSPoint p = [[points objectAtIndex: i] pointValue];
      if (i == 0)
	      [path moveToPoint: p];
      else
	      [path lineToPoint: p];
    }
  [path closePath];
  if (transform != nil)
    [path transformUsingAffineTransform: transform];
  [path stroke];
}
@end

@implementation GdsPrimitiveDrawer
@end

@implementation GdsBoundaryDrawer
@end

@implementation GdsPathDrawer
@end

@implementation GdsReferenceDrawer
- (void) draw
{
  GdsStructure *refStructure;
  GdsReferenceElement *element;
  element = (GdsReferenceElement *) _element;
  refStructure = [element referenceStructure];
  if (refStructure == nil)
    {
      return;
    }
  if ([_structureView inLiveResize]) 
    {
      [super draw];
    }
  else
    {
      [[_structureView viewport] pushTransform: [element transform]];
      [_structureView drawElements: [refStructure elements]];
      (void) [[_structureView viewport] popTransform];
    }
}
@end

@implementation GdsSrefDrawer
@end

@implementation GdsArefDrawer
- (void) draw
{
  GdsStructure *refStructure;
  GdsAref *element;
  element = (GdsAref *) _element;
  refStructure = [element referenceStructure];
  if (refStructure == nil)
    {
      return;
    }
  NSAffineTransform *tx;
  NSEnumerator *iter;

  if ([_structureView inLiveResize]) 
    {
      [super draw];
    }
  else
    {
      [[_structureView viewport] pushTransform: [element transform]];
      iter = [[element offsetTransforms] objectEnumerator]; 
      while ((tx = [iter nextObject]) != nil)
	      {
	        [[_structureView viewport] pushTransform: tx];
	        [_structureView drawElements: [refStructure elements]];
	        (void) [[_structureView viewport] popTransform];	   
	        [_structureView drawElements: [refStructure elements]];
	      }
      (void) [[_structureView viewport] popTransform];	   
    }
}
@end

// vim: sw=2 ts=2 expandtab filetype=objc
