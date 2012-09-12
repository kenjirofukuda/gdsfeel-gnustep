#import "GdsViewport.h"

@interface GdsViewport (Private)
- (NSAffineTransform *) _lookupTransform;
- (NSAffineTransform *) _fittingTransform;
- (void) _damageTransform;
@end

@implementation GdsViewport
- (id) initWithStructure: (GdsStructure *) structure
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_structure, structure);
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_structure);
  RELEASE(_transform);
  [super dealloc];
}

- (NSAffineTransform *) transform
{
  if (_transform == nil)
    {
      ASSIGN(_transform, [self _lookupTransform]);
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

- (void) fit
{
  [self setBounds: [_structure boundingBox]];
}

- (void) pushTransform: (NSAffineTransform *) transform
{
  // FIXME
}

- (NSAffineTransform *) popTransform
{
  // FIXME
  return nil;
}

- (NSAffineTransform *) fittingTransform
{
  return [self _fittingTransform];
}

@end

@implementation GdsViewport (Private)
- (void) _damageTransform
{
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
