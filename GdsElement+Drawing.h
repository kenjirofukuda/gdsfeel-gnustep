// -*-Objc-*-

#import <Foundation/Foundation.h>
#import <AppKit/NSColor.h>
#import "GdsFeelCore/GdsElement.h"
#import "GdsStructureView.h"

@interface GdsElement (Drawing)
@property (nonatomic) NSColor* frameColor;
- (NSColor *) frameColor2;
- (void) fullDrawOn: (GdsStructureView *) view;
- (void) drawOn: (GdsStructureView *) view;
@end

@interface GdsSref (Drawing)
- (void) drawOn: (GdsStructureView *) view;
@end

@interface GdsAref (Drawing)
- (void) drawOn: (GdsStructureView *) view;
@end

