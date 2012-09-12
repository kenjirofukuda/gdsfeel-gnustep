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
  if ([className isEqualToString: @""] == YES)
    {
      
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

- (void) strokePoints: (NSArray *) points transform: (NSAffineTransform *) transform
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
