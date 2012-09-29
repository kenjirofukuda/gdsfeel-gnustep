#import "GdsViewport.h"

@interface GdsViewport (Private)
- (NSAffineTransform *) _lookupTransform;
- (NSAffineTransform *) _fittingTransform;
- (NSAffineTransform *) basicTransform;
- (void) _damageTransform;
@end

@implementation GdsViewport
- (id) initWithStructure: (GdsStructure *) structure
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_structure, structure);
      ASSIGN(_transformStack, [[NSMutableArray alloc] init]);
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_transformStack);
  RELEASE(_structure);
  RELEASE(_transform);
  [super dealloc];
}

- (NSAffineTransform *) transform
{
  if (_transform == nil)
    {
      NSAffineTransform *newTransform;
      NSAffineTransform *tx;
      newTransform = [NSAffineTransform transform];
      [newTransform prependTransform: [self basicTransform]];
      NSEnumerator *iter = [_transformStack objectEnumerator];
      while ((tx = [iter nextObject]) != nil)
        {
          [newTransform prependTransform: tx];
        }
      ASSIGN(_transform, newTransform);
    }
  return _transform;
}

- (NSSize) portSize
{
  return _portSize;
}

- (void) setPortSize: (NSSize) newSize
{
  _portSize = newSize;
  [self _damageTransform];
}

- (NSPoint) center
{
  return _center;
}

- (void) setCenter: (NSPoint) newCenter
{
  if (NSEqualPoints(_center, newCenter))
    return;
  _center = newCenter;
  [self _damageTransform];
}

- (CGFloat) scale
{
  return _scale;
}

- (void) setScale: (CGFloat) newScale
{
  if (_scale == newScale)
    return;
  _scale = newScale;
  [self _damageTransform];
}

- (void) setBounds: (NSRect) worldBounds
{
  NSRect modelBounds = [_structure boundingBox];
  double hRatio = _portSize.width / NSWidth(modelBounds);
  double vRatio = _portSize.height / NSHeight(modelBounds);
  double ratio = hRatio < vRatio ? hRatio : vRatio;
  NSPoint newCenter = NSMakePoint(NSMidX(worldBounds), NSMidY(worldBounds));
  _center = newCenter;
  _scale = (CGFloat) ratio;
  [self _damageTransform];
}

- (NSRect) bounds
{
  NSRect pixelBounds;
  NSRect viewBounds;
  NSAffineTransform *inverseTransform;
  pixelBounds = NSMakeRect(0.0, 0.0, _portSize.width, _portSize.height);
  inverseTransform = [[NSAffineTransform alloc] initWithTransform: [self transform]];
  [inverseTransform invert];
  viewBounds.origin = [inverseTransform transformPoint: pixelBounds.origin];
  viewBounds.size = [inverseTransform transformSize: pixelBounds.size];
  return viewBounds;
}

-(void) viewMoveFractionX: (CGFloat) aXfraction y: (CGFloat) aYfraction
{
  NSRect viewBounds;
  CGFloat xDelta, yDelta;
  NSPoint newCenter;

  viewBounds = [self bounds];
  xDelta = viewBounds.size.width * aXfraction;
  yDelta = viewBounds.size.height * aYfraction;
  newCenter = [self center];
  newCenter.x += xDelta;
  newCenter.y += yDelta;
  [self setCenter: newCenter];
}

- (void) fit
{
  [self setBounds: [_structure boundingBox]];
}

- (void) pushTransform: (NSAffineTransform *) transform
{
  [_transformStack addObject: transform];
  DESTROY(_transform);
}

- (NSAffineTransform *) popTransform
{
  NSAffineTransform *result = nil;
  if ([_transformStack count] == 0)
    return nil;
  result = [_transformStack lastObject];
  [_transformStack removeLastObject];
  DESTROY(_transform);
  return result;
}

- (NSAffineTransform *) fittingTransform
{
  return [self _fittingTransform];
}

@end

@implementation GdsViewport (Private)
- (NSAffineTransform *) basicTransform
{
  if (_basicTransform == nil)
    {
      ASSIGN(_basicTransform, [self _lookupTransform]);
    }
  return _basicTransform;
}

- (void) _damageTransform
{
  DESTROY(_basicTransform);
  DESTROY(_transform);
}

- (NSAffineTransform *) _lookupTransform
{
  NSAffineTransform *tx = [NSAffineTransform transform];
  if ([[_structure elements] count] == 0)
    return tx;
  [tx translateXBy: _portSize.width / 2.0 yBy: _portSize.height / 2.0];
  [tx scaleBy: _scale];
  [tx translateXBy: -_center.x yBy: -_center.y];    
  return tx;
}

- (NSAffineTransform *) _fittingTransform
{
  NSAffineTransform *tx = [NSAffineTransform transform];
  if ([[_structure elements] count] == 0)
    return tx;
  CGFloat vw = _portSize.width;
  CGFloat vh = _portSize.height;
  NSRect modelBounds = [_structure boundingBox];
  double hRatio = vw / NSWidth(modelBounds);
  double vRatio = vh / NSHeight(modelBounds);
  double ratio = hRatio < vRatio ? hRatio : vRatio;
  [tx translateXBy: vw / 2.0 yBy: vh / 2.0];
  [tx scaleBy: ratio];
  [tx scaleBy: 0.98];
  [tx translateXBy: -NSMidX(modelBounds) yBy: -NSMidY(modelBounds)];  
  return tx;
}
@end

// vim: ts=2 sw=2 expandtab
