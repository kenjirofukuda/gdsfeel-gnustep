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
  NSAffineTransform *_basicTransform;
}
- (id) initWithStructure: (GdsStructure *) structure;
- (void) dealloc;

- (NSAffineTransform *) transform;

- (NSPoint) center;
- (NSRect) bounds;
- (NSSize) portSize;
- (CGFloat) scale;

- (void) setPortSize: (NSSize) newSize;
- (void) setCenter: (NSPoint) newCenter;
- (void) setScale: (CGFloat) newScale;
- (void) setBounds: (NSRect) worldBounds;

- (void) viewMoveFractionX: (CGFloat) aXfraction y: (CGFloat) aYfraction;
- (void) fit;

- (void) pushTransform: (NSAffineTransform *) transform;
- (NSAffineTransform *) popTransform;

- (NSAffineTransform *) fittingTransform;
@end

// vim: filetype=objc ts=2 sw=2 expandtab
