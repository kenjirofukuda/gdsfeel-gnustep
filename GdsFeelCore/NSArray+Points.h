// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>

@interface NSMutableArray (Points)
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

// vim: filetype=objc ts=2 sw=2 expandtab
