#import <Foundation/Foundation.h>
#import "NSArray+Elements.h"
#import "GdsElement.h"

@implementation NSArray (Elements)
- (void) getPrimitivesOn: (NSMutableArray *) primitives
	    referencesOn: (NSMutableArray *) references
{
  NSEnumerator *iter;
  iter = [self objectEnumerator];
  GdsElement *element;
  while ((element = [iter nextObject]) != nil)
    {
      if ([element isReference])
	{
	  if (references != nil)
	    [references addObject: element];
	}
      else
	{
	  if (primitives != nil)
	    [primitives addObject: element];
	}
    }
}

- (NSArray *) primitives
{
  NSMutableArray *primitives;
  NSMutableArray *references;
  primitives = [[NSMutableArray alloc] init];
  references = nil;
  [self getPrimitivesOn: primitives referencesOn: references];
  NSArray *result = [NSArray arrayWithArray: primitives];
  RELEASE(primitives);
  return result;
}

- (NSArray *) references
{
  NSMutableArray *primitives;
  NSMutableArray *references;
  primitives = nil;
  references = [[NSMutableArray alloc] init];
  [self getPrimitivesOn: primitives referencesOn: references];
  NSArray *result = [NSArray arrayWithArray: references];
  RELEASE(references);
  return result;
}

@end
