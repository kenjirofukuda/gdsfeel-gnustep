// -*-Objc-*-

#import "GdsElement+Drawing.h"
#import "GdsFeelCore/GdsLayer.h"
#import <objc/runtime.h>
#import <AppKit/NSGraphicsContext.h>

@implementation GdsElement (Drawing)

@dynamic frameColor;

- (NSColor *) frameColor
{
  NSColor *it = objc_getAssociatedObject(self, @selector(setFrameColor:));
  if (it == nil || [NSColor whiteColor] == it)
    {
      [self setFrameColor: [self lookupFrameColor]];
    }
  return it;
}

- (NSColor *)frameColor2
{
  NSColor *it = [_extension objectForKey: @"frameColor"];
  if (it == nil)
    {
      [_extension setObject: [self lookupFrameColor] forKey: @"frameColor"];
    }
  return it;
}


- (void) setFrameColor:(NSColor *)val
{
  objc_setAssociatedObject(self, _cmd, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSColor *) lookupFrameColor
{
  GdsPrimitiveElement *primitive = (GdsPrimitiveElement *) self;
  return [[[[[primitive structure] library] layers]
                                    layerAtNumber: [primitive layerNumber]] color];
}

- (void) strokeOutlineOn: (GdsStructureView *) view
{
  // [self strokePoints: [self outlinePoints]
  //          transform: [[view viewport] transform]];
  CGFloat lineWidth = 1.0 / [[view viewport] scale];  
  [self strokePoints: [self outlinePoints]
           lineWidth: lineWidth ];
}

- (void) strokePoints: (NSArray *)points
{
  [self strokePoints: points transform: nil];
}

- (void) strokePoints: (NSArray *)points transform: (NSAffineTransform *)transform
{
  NSBezierPath *path = [NSBezierPath bezierPath];
  int           i;
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

- (void) strokePoints: (NSArray *)points lineWidth: (CGFloat) lineWidth
{
  NSBezierPath *path = [NSBezierPath bezierPath];
  int           i;
  for (i = 0; i < [points count]; i++)
    {
      NSPoint p = [[points objectAtIndex: i] pointValue];
      if (i == 0)
        [path moveToPoint: p];
      else
        [path lineToPoint: p];
    }
  [path closePath];
  [path setLineWidth: lineWidth];  
  [path stroke];
}

- (void) fullDrawOn: (GdsStructureView *) view
{
  [[self frameColor2] set];
  [self drawOn: view];
}

- (void) drawOn: (GdsStructureView *) view 
{
  [self strokeOutlineOn: view];
}
@end

@implementation GdsSref (Drawing)
- (void) drawOn: (GdsStructureView *) view
{
  GdsStructure        *refStructure;
  refStructure = [self referenceStructure];
  if (refStructure == nil)
    {
      return;
    }
  if ([view inLiveResize])
    {
      [super drawOn: view];
    }
  else
    {
      NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
      [theContext saveGraphicsState];
      [[view viewport] pushTransform: [self transform]];
      [view drawElements: [refStructure elements] transform: [self transform]];
      (void) [[view viewport] popTransform];
      [theContext restoreGraphicsState];
    }
}

- (NSColor *)frameColor2
{
  return [NSColor lightGrayColor];
}


@end

@implementation GdsAref (Drawing)
- (void) drawOn: (GdsStructureView *) view
{
  GdsStructure *refStructure;
  refStructure = [self referenceStructure];
  if (refStructure == nil)
    {
      return;
    }

  if ([view inLiveResize])
    {
      [super drawOn: view];
    }
  else
    {
      NSGraphicsContext *theContext = [NSGraphicsContext currentContext];
      [theContext saveGraphicsState];
      [[view viewport] pushTransform: [self transform]];
      [[self transform] concat];
      for (NSAffineTransform *tx in [self offsetTransforms])
        {
          [theContext saveGraphicsState];
          [[view viewport] pushTransform: tx];
          [view drawElements: [refStructure elements] transform: tx];
           (void) [[view viewport] popTransform];
          [theContext restoreGraphicsState];
        }
      (void) [[view viewport] popTransform];
      [theContext restoreGraphicsState];
    }
}

@end

