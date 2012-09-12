#import <Foundation/Foundation.h>
#import "osxportability.h"
#import "GdsArchiver.h"
#import "GdsLibrary.h"
#import "GdsLayer.h"
#import "GdsStructure.h"

NSString * const GdsLibraryErrorDomain = @"com.gdsfeel.GdsLibrary.ErrorDomain";

@interface GdsLibrary (Private)
- (NSString *) pathToReaderMarker;
- (NSString *) pathToLayersInformation;
- (void) touchReaderMarker;
- (BOOL) hasReaderMarker;
- (BOOL) isDirectory: (NSString *) fileName;
- (BOOL) isFile: (NSString *) fileName;
- (NSString *) directoryPathForStructureName: (NSString *) structureName;
- (void) loadStructures;
- (NSArray *) lookupStructureNames;
@end

@implementation GdsLibrary
- (id) initWithPath: (NSString *) fileName
{
  self = [super init];
  if (self != nil) 
    {
      ASSIGNCOPY(_path, fileName);
      ASSIGN(_folderPath, [_path stringByDeletingLastPathComponent]);
      _archiver = [[GdsZipArchiver alloc] init];
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_path);
  RELEASE(_archiver);
  RELEASE(_structures);
  RELEASE(_structureNames);
  RELEASE(_structureMap);
  RELEASE(_layers);
  [super dealloc];
}

- (NSString*) localName
{
  return [[self keyName] stringByAppendingPathExtension: @"DB"];
}

- (NSString*) keyName
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
  NSDebugLog(@"folder = %@", _folderPath);
  NSDebugLog(@"keyName = %@", [self keyName]);
  NSDebugLog(@"localName = %@", [self localName]);
  NSDebugLog(@"pathToExtract = %@", [self pathToExtract]);
  NSDebugLog(@"isOpen = %@", [self isOpen] ? @"YES" : @"NO");
}

- (NSString *) pathToExtract
{
  return [NSString pathWithComponents:
           [NSArray arrayWithObjects:
             _folderPath, @".editlibs", [self localName], nil]];
}

- (BOOL) isOpen
{
  BOOL exists = [self isDirectory: [self pathToExtract]];
  return exists;
}

- (void) openForReading
{
  if ([self isOpen] == YES) 
    {
      NSWarnLog(@"Already Opend!");
      return;
    }
  BOOL ok = [[NSFileManager defaultManager]
              createDirectoryAtPath: [self pathToExtract] attributes: nil];

  BOOL exists;
  exists = [self isDirectory: [self pathToExtract]];
  if (exists == NO) 
    {
      NSWarnLog(@"Making directory failed for extract archive");
      return;
    }
  ok = [_archiver extractFile: _path intoDirectory: [self pathToExtract]];  
  if (ok) 
    {
      [self touchReaderMarker];
    }
}

- (void) closeForReading
{
  if ([self hasReaderMarker] == NO)
    return;
  BOOL result =  [[NSFileManager defaultManager] 
		   removeFileAtPath: [self pathToExtract]
		   handler: nil];
  if (result == NO)
    {
      NSWarnLog(@"Can't remove %@", [self pathToExtract]);
    }
}

+ (BOOL) isValidDatabase: (NSString *)fileName
		   error: (NSError **)outError
{
  BOOL enabled = [[GdsZipArchiver defaultArchiver] isZipArchiverEnabled];
  if (enabled == NO)
    return NO;
  BOOL result = [[GdsZipArchiver defaultArchiver] isZipFile:fileName];
  if (result == NO) 
    {
      *outError = 
	[NSError errorWithDomain: GdsLibraryErrorDomain
		 code: -1 // Oh NO
		 userInfo: [NSDictionary
			     dictionaryWithObjectsAndKeys:
			       _(@"Invalid GdsFeel database library format"), 
			     NSLocalizedDescriptionKey,
			     nil]];
    }
  return result;
}

- (NSArray *) structures
{
  [self loadStructures];
  return [NSArray arrayWithArray: _structures];
}

- (GdsStructure *) structureForKey: (NSString *) keyName
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
	     [[GdsLayers alloc] 
	       initWithPath: [self pathToLayersInformation] library: self]);
    }
  return _layers;
}

@end 

@implementation GdsLibrary (Private)
- (void) touchReaderMarker
{
  [[NSString stringWithString: @"touch"]
      writeToFile: [self pathToReaderMarker] atomically: YES];
}

- (NSString *) pathToReaderMarker
{
  NSString *pathToMarker;
  pathToMarker = [NSString pathWithComponents:
    [NSArray arrayWithObjects: [self pathToExtract], @"GNUstep.reader", nil]];
  return pathToMarker;
}

- (NSString *) pathToLayersInformation
{
  NSString *pathToLayers;
  pathToLayers = [NSString pathWithComponents:
    [NSArray arrayWithObjects: [self pathToExtract], @"layers.xml", nil]];
  return pathToLayers;
}

- (BOOL) isDirectory: (NSString *) fileName
{
  BOOL exists, isDir;
  exists = [[NSFileManager defaultManager]
             fileExistsAtPath: fileName isDirectory: &isDir];
  return exists == YES && isDir == YES;
}

- (BOOL) isFile: (NSString *) fileName
{
  BOOL exists, isDir;
  exists = [[NSFileManager defaultManager]
             fileExistsAtPath: fileName isDirectory: &isDir];
  return exists == YES && isDir == NO;
}

- (BOOL) hasReaderMarker
{
  return [self isFile: [self pathToReaderMarker]];
}

- (NSString *) directoryPathForStructureName: (NSString *) structureName
{
   NSString *fullPath;
   fullPath = [NSString pathWithComponents:
			  [NSArray arrayWithObjects: [self pathToExtract], 
				   [structureName stringByAppendingPathExtension: @"structure"], nil]];
   return fullPath;
} 

- (void) loadStructures
{
  if (_structures != nil) 
    {
      return;
    }
  _structures = [[NSMutableArray alloc] init];
  _structureMap = [[NSMutableDictionary alloc] init];
  [self openForReading];
  NSArray *allNames = [[NSFileManager defaultManager]
                        directoryContentsAtPath: [self pathToExtract]];
  NSArray *sortedNames = [allNames sortedArrayUsingSelector: @selector(compare:)];
  NSMutableArray *names = [[NSMutableArray alloc] init];
  NSEnumerator *iter = [sortedNames objectEnumerator];
  NSString *name;
  while ((name = [iter nextObject]) != nil) 
    {
      NSString *fullPath;
      fullPath = [NSString pathWithComponents:
			     [NSArray arrayWithObjects: [self pathToExtract], name, nil]];
    if ([self isDirectory: fullPath] == NO)
      continue;
    if ([[name pathExtension] isEqualToString: @"structure"] == YES) 
      {
	NSString *keyName = [name stringByDeletingPathExtension];
	GdsStructure *newStructure;
	newStructure = [[GdsStructure alloc] 
			 initWithDirectoryPath: fullPath
			 library: self];
	[_structures addObject: newStructure];
	[_structureMap setObject: newStructure forKey: [newStructure keyName]];
	[newStructure debugLog];
      }
    }
}

- (NSArray *) lookupStructureNames
{
  [self loadStructures];
  NSMutableArray *names = [[NSMutableArray alloc] init];
  NSEnumerator *iter = [_structures objectEnumerator];
  GdsStructure *structure;
  while ((structure = [iter nextObject]) != nil) 
    {
      [names addObject: [structure keyName]];
    }
  NSArray *result = [NSArray arrayWithArray: names];
  RELEASE(names);
  return result;
}

@end
// vim: ts=2 sw=2 expandtab
