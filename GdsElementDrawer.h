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
