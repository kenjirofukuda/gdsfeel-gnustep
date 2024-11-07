#import <Foundation/Foundation.h>
#import <GNUstepBase/GSXML.h>
#import "GdsStructure.h"
#import "GdsElement.h"
#import "NSArray+Points.h"

@implementation GdsStructure
- (id) initWithLibrary: (GdsLibrary *)library;
{
  self = [super init];
  if (self != nil)
    {
      ASSIGN(_library, library);
      _elements = nil; // lazy
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_library);
  // TODO release each elements
  RELEASE(_elements);
  RELEASE(_name);
  [super dealloc];
}

- (GdsLibrary *) library
{
  return _library;
}

- (void) setLibrary: (GdsLibrary *)library
{
  ASSIGN(_library, library);
}

- (NSString *) name
{
  if (_name == nil)
    {
      ASSIGN(_name, @"");
    }
  return _name;
}

- (void) setName: (NSString *)name
{
  ASSIGNCOPY(_name, name);
}

- (NSString *) keyName
{
  return [[self name] uppercaseString];
}

- (NSArray *) elements
{
  if (_elements == nil)
    {
      _elements = [[NSMutableArray alloc] init];
      [self loadElements];
    }
  //  return [NSArray arrayWithArray: _elements];
  return _elements;
}

- (NSRect) boundingBox
{
  if (_boundingBox == nil)
    {
      ASSIGN(_boundingBox, [NSValue valueWithRect: [self lookupBoundingBox]]);
    }
  return [_boundingBox rectValue];
}

- (void) addElement: (GdsElement *)newElement
{
  NSDebugLog(@"%@", @"addElement");
  [_elements addObject: newElement];
  [newElement setStructure: self];
}

- (void) loadElements
{
  // must be overridden
}

- (void) debugLog
{
  NSDebugLog(@"elements = %@", [self elements]);
}

- (NSRect) lookupBoundingBox
{
  NSEnumerator   *iter = [[self elements] objectEnumerator];
  GdsElement     *element;
  NSMutableArray *points = [NSMutableArray new];
  while ((element = [iter nextObject]) != nil)
    {
      NSRect r = [element boundingBox];
      [points addPointX: NSMinX(r) y: NSMinY(r)];
      [points addPointX: NSMaxX(r) y: NSMaxY(r)];
    }
  return [points lookupBoundingBox];
}

@end

// vim: ts=2 sw=2 expandtab
