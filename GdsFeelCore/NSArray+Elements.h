// -*-Objc-*-
#import <Foundation/Foundation.h>
#import "GdsElement.h"

@interface NSArray (Elements)
- (void) getPrimitivesOn: (NSMutableArray *) primitives
	    referencesOn: (NSMutableArray *) references;
- (NSArray *) references;
- (NSArray *) primitives;
@end
