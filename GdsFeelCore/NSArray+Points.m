#import <Foundation/Foundation.h>
#import <float.h>
#import "NSArray+Points.h"

static float BIGVAL = FLT_MAX / 2.0;

@implementation NSMutableArray (Points)
- (void) addPointX: (CGFloat)x y: (CGFloat)y
{
  [self addPoint: NSMakePoint(x, y)];
}

- (void) addPoint: (NSPoint)point
{
  [self addObject: [NSValue valueWithPoint: point]];
}

- (void) addNSPointPtr: (NSPoint *)points count: (int)countPoints
{
  int i;
  for (i = 0; i < countPoints; i++)
    {
      [self addPoint: points[i]];
    }
}

@end

@implementation NSArray (Points)
- (NSPoint) pointAtIndex: (NSUInteger) index
{
  return [[self objectAtIndex: index] pointValue];
}

- (NSPoint *)asNSPointPtr:(int *)outCountPoints
{
  NSPoint *points = malloc(sizeof(NSPoint) * [self count]);
  if (outCountPoints)
    *outCountPoints = [self count];
  int i = 0;
  for (NSValue *v in self)
    {
      NSPoint xy = [v pointValue];
      points[i] = xy;
      i++;
    }
  return points;
}

- (NSRect) lookupBoundingBox
{
  float xmin, xmax, ymin, ymax;
  xmin = ymin = BIGVAL;
  xmax = ymax = -BIGVAL;
  for (NSValue *v in self)
    {
      NSPoint xy = [v pointValue];
      if (xmin > xy.x)
        xmin = xy.x;
      if (ymin > xy.y)
        ymin = xy.y;
      if (xmax < xy.x)
        xmax = xy.x;
      if (ymax < xy.y)
        ymax = xy.y;
    }
  return NSMakeRect(xmin, ymin, xmax - xmin, ymax - ymin);
}

- (NSArray *) transformedPoints: (NSAffineTransform *)transform
{
  NSMutableArray *array = [NSMutableArray new];
  for (NSValue *v in self)
    {
      NSPoint xy = [v pointValue];
      [array addPoint: [transform transformPoint: xy]];
    }
  return [NSArray arrayWithArray: array];
}

+ (NSArray *) pointsFromNSPointPtr: (NSPoint *)points count: (int)countPoints
{
  NSMutableArray *array = [NSMutableArray new];
  [array addNSPointPtr: points count: countPoints];
  return [NSArray arrayWithArray: array];
}

+ (NSArray *) pointsFromNSRect: (NSRect)rect
{
  NSMutableArray *array = [NSMutableArray new];
  [array addPoint: NSMakePoint(NSMinX(rect), NSMinY(rect))];
  [array addPoint: NSMakePoint(NSMinX(rect), NSMaxY(rect))];
  [array addPoint: NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
  [array addPoint: NSMakePoint(NSMaxX(rect), NSMinY(rect))];
  return [NSArray arrayWithArray: array];
}

@end

// vim: ts=2 sw=2 expandtab
