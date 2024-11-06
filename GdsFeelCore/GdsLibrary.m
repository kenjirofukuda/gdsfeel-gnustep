#import <Foundation/Foundation.h>
#import "osxportability.h"
#import "GdsLibrary.h"
#import "GdsLayer.h"
#import "GdsStructure.h"

NSString *const GdsLibraryErrorDomain = @"com.gdsfeel.GdsLibrary.ErrorDomain";

@interface GdsLibrary(Private)
- (NSArray *) lookupStructureNames;
- (void) loadStructures;
@end


@implementation GdsLibrary
- (id) initWithPath: (NSString *)fileName
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


- (id) init
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
  [super dealloc];
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
      ASSIGN(_layers,
             [[GdsLayers alloc] init]);
    }
  return _layers;
}

- (NSArray *) lookupStructureNames;
{
  return [NSArray array];
}

- (void) loadStructures;
{
  // must be overridden
}

- (void) addStructure: (GdsStructure *)newStructure
{
  NSDebugLog(@"%@", @"addStructure");
  [_structures addObject: newStructure];
  [_structureMap setObject: newStructure forKey: [newStructure keyName]];
  [newStructure setLibrary: self];
}

@end


// vim: ts=2 sw=2 expandtab
