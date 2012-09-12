// -*- mode: ObjC -*-
#ifdef GNUSTEP
#import <Foundation/Foundation.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@interface NSMutableArray(Points)
- (void) addPointX: (CGFloat) x y: (CGFloat) y;
- (void) addPoint: (NSPoint) point;
- (void) addNSPointPtr: (NSPoint *) points count: (int) countPoints;
@end

@interface NSArray (Points)
- (NSRect) lookupBoundingBox;
- (NSPoint *) asNSPointPtr: (int *) outCountPoints;
- (NSArray *) transformedPoints: (NSAffineTransform *) transform;

+ (NSArray *) pointsFromNSPointPtr: (NSPoint *) points 
			     count: (int) countPoints;
+ (NSArray *) pointsFromNSRect: (NSRect) rect;
@end
