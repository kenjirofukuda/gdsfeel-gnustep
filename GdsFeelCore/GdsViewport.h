// -*-Objc-*-
#import <Foundation/Foundation.h>
#import "GdsStructure.h"

@interface GdsViewport : NSObject
{
  GdsStructure *_structure;
  NSMutableArray *_transformStack;
  NSSize _portSize;
  NSPoint _center;
  CGFloat _scale;
  NSAffineTransform *_transform;
}
- (id) initWithStructure: (GdsStructure *) structure;
- (void) dealloc;

- (NSAffineTransform *) transform;

- (void) setPortSize: (NSSize) newSize;
- (NSSize) portSize;

- (NSPoint) center;
- (void) setCenter: (NSPoint) newCenter;
- (void) setScale: (CGFloat) newScale;
- (void) setBounds: (NSRect) worldBounds;

- (void) fit;

- (void) pushTransform: (NSAffineTransform *) transform;
- (NSAffineTransform *) popTransform;

- (NSAffineTransform *) fittingTransform;
@end
