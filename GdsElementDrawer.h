// -*-Objc-*-
#import <Foundation/Foundation.h>
#import "GdsFeelCore/GdsElement.h"
#import "GdsStructureView.h"

@interface GdsElementDrawer : NSObject
{
  GdsElement *_element;
  GdsStructureView *_structureView;
}
- (id) initWithElement: (GdsElement *) element view: (GdsStructureView *) view;
- (void) dealloc;
- (void) draw;

+ (Class) drawerClassForElement: (GdsElement *) element;
@end

@interface GdsPrimitiveDrawer : GdsElementDrawer
@end

@interface GdsBoundaryDrawer : GdsPrimitiveDrawer
@end

@interface GdsPathDrawer : GdsPrimitiveDrawer
@end

@interface GdsReferenceDrawer : GdsElementDrawer
@end

@interface GdsSrefDrawer : GdsReferenceDrawer
@end

@interface GdsArefDrawer : GdsSrefDrawer
@end

// vim: sw=2 ts=2 expandtab filetype=objc
