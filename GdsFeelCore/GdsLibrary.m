#import <Foundation/Foundation.h>
#import "osxportability.h"
#import "GdsLibrary.h"
#import "GdsLayer.h"
#import "GdsStructure.h"

NSString *const GdsLibraryErrorDomain = @"com.gdsfeel.GdsLibrary.ErrorDomain";

@implementation GdsLibrary
- (instancetype) initWithPath: (NSString *)fileName
{
  self = [super init];
  if (self != nil)
    {
      ASSIGNCOPY(_path, fileName);
      _userUnit = 0.0;
      _meterUnit = 0.0;
      _structures = [[NSMutableArray alloc] init];
      _structureMap = [[NSMutableDictionary alloc] init];
      _structureNames = nil;
      _layers = nil;
    }
  return self;
}

- (instancetype) init
{
  return [self initWithPath: @""];
}

- (void) dealloc
{
  RELEASE(_path);
  RELEASE(_structures);
  RELEASE(_structureNames);
  RELEASE(_structureMap);
  RELEASE(_layers);
  DEALLOC;
}

- (NSString *) name
{
  return _name;
}

- (void) setName: (NSString *)name
{
  ASSIGNCOPY(_name, name);
}

- (double) userUnit
{
  return _userUnit;
}

- (void) setUserUnit: (double)unit
{
  _userUnit = unit;
}

- (double) meterUnit
{
  return _meterUnit;
}

- (void) setMeterUnit: (double)unit
{
  _meterUnit = unit;
}

- (NSString *) localName
{
  return [[self keyName] stringByAppendingPathExtension: @"DB"];
}

- (NSString *) keyName
{
  if (_keyName == nil)
    {
      ASSIGN(_keyName, [[[_path lastPathComponent]
                         stringByDeletingPathExtension] uppercaseString]);
    }
  return _keyName;
}

- (void) debugLog
{
  NSDebugLog(@"      keyName = %@", [self keyName]);
  NSDebugLog(@"    localName = %@", [self localName]);
  NSDebugLog(@"       isOpen = %@", [self isOpen] ? @"YES" : @"NO");
}

- (BOOL) isOpen
{
  return NO; // must be overridden
}

- (NSArray *) structures
{
  [self loadStructures];
  return [NSArray arrayWithArray: _structures];
}

- (GdsStructure *) structureForKey: (NSString *)keyName
{
  [self loadStructures];
  return [_structureMap objectForKey: keyName];
}

- (NSArray *) structureNames
{
  if (_structureNames == nil)
    {
      ASSIGN(_structureNames, [self lookupStructureNames]);
    }
  return _structureNames;
}

- (GdsLayers *) layers
{
  if (_layers == nil)
    {
      ASSIGN(_layers, [[GdsLayers alloc] initWithLibrary: self]);
    }
  return _layers;
}

- (void) addStructure: (GdsStructure *)newStructure
{
  NSDebugLog(@"%@", @"addStructure");
  [_structures addObject: newStructure];
  [_structureMap setObject: newStructure forKey: [newStructure keyName]];
  [newStructure setLibrary: self];
}

- (NSArray *) lookupStructureNames
{
  NSMutableArray *names = [[NSMutableArray alloc] init];
  NSEnumerator   *iter = [_structures objectEnumerator];
  GdsStructure   *structure;
  while ((structure = [iter nextObject]) != nil)
    {
      [names addObject: [structure keyName]];
    }
  NSArray *result = [NSArray arrayWithArray: names];
  RELEASE(names);
  return result;
}

- (void) loadStructures
{
}

- (NSArray *) usedLayerNumbers
{
  NSMutableArray *allNumbers = AUTORELEASE([[NSMutableArray alloc] init]);
  for (GdsStructure *s in [self structures])
    {
      for (GdsElement *e in [s elements])
        {
          if (! [e isReference])
            {
              [allNumbers addObject:
                            [NSNumber numberWithInt:
                                        [(GdsPrimitiveElement *)e layerNumber]]];
            }
        }
    }
  NSSet *numberSet = [NSSet setWithArray: allNumbers];
  return [numberSet allObjects];
}
@end

// vim: ts=2 sw=2 expandtab
