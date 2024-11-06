#import <Foundation/Foundation.h>
#import "osxportability.h"
#import "GdsZipedLibrary.h"
#import "GdsLayer.h"
#import "GdsZipedStructure.h"


@interface GdsZipedLibrary(Private)
- (NSString *) pathToReaderMarker;
- (NSString *) pathToLayersInformation;
- (void) touchReaderMarker;
- (BOOL) hasReaderMarker;
- (BOOL) isDirectory: (NSString *)fileName;
- (BOOL) isFile: (NSString *)fileName;
- (NSString *) directoryPathForStructureName: (NSString *)structureName;
- (void) loadStructures;
@end


@implementation GdsZipedLibrary
- (id) initWithPath: (NSString *)fileName
{
  self = [super initWithPath: fileName];
  if (self != nil)
    {
      ASSIGN(_folderPath, [_path stringByDeletingLastPathComponent]);
      _archiver = [[GdsZipArchiver alloc] init];
    }
  return self;
}


- (void) dealloc
{
  RELEASE(_archiver);
  [super dealloc];
}


- (BOOL) isOpen
{
  BOOL exists = [self isDirectory: [self pathToExtract]];
  return exists;
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


- (void) debugLog
{
  [super debugLog];
  NSDebugLog(@"       folder = %@", _folderPath);
  NSDebugLog(@"pathToExtract = %@", [self pathToExtract]);
}


- (NSString *) pathToExtract
{
  return [NSString pathWithComponents:
                   [NSArray arrayWithObjects:
                    _folderPath, @".editlibs", [self localName], nil]];
}

- (void) openForReading
{
  if ([self isOpen] == YES)
    {
      NSWarnLog(@"Already Opend!");
      return;
    }
#ifdef __MINGW__
  BOOL ok = [[NSFileManager defaultManager]
             createDirectoryAtPath: [self pathToExtract] attributes: nil];
#else
  NSMutableDictionary *attr;
  attr = [[NSMutableDictionary alloc] init];
  [attr setValue: [NSNumber numberWithShort: 0755] forKey: NSFilePosixPermissions];

  NSError *theError = nil;
  BOOL ok = [[NSFileManager defaultManager]
                   createDirectoryAtPath: [self pathToExtract]
             withIntermediateDirectories: YES
                              attributes: attr
                                   error: &theError];
  if (theError)
    {
      NSDebugLog(@"%@", [theError localizedDescription]);
    }
#endif
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
  BOOL result = [[GdsZipArchiver defaultArchiver] isZipFile: fileName];
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

@end

@implementation GdsZipedLibrary(Private)
- (void) touchReaderMarker
{
  [@"touch" writeToFile: [self pathToReaderMarker] atomically: YES];
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

- (BOOL) isDirectory: (NSString *)fileName
{
  BOOL exists, isDir;
  exists = [[NSFileManager defaultManager]
            fileExistsAtPath: fileName isDirectory: &isDir];
  return exists == YES && isDir == YES;
}

- (BOOL) isFile: (NSString *)fileName
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

- (NSString *) directoryPathForStructureName: (NSString *)structureName
{
  NSString *fullPath;
  fullPath = [NSString pathWithComponents:
                       [NSArray arrayWithObjects: [self pathToExtract],
                        [structureName stringByAppendingPathExtension: @"structure"], nil]];
  return fullPath;
}

- (void) loadStructures
{
  if ([_structures count] > 0)
    {
      return;
    }
  [self openForReading];
  NSArray *allNames = [[NSFileManager defaultManager]
                       directoryContentsAtPath: [self pathToExtract]];
  NSArray *sortedNames = [allNames sortedArrayUsingSelector: @selector(compare:)];
  //NSMutableArray *names = [[NSMutableArray alloc] init];
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
          //NSString *keyName = [name stringByDeletingPathExtension];
          GdsStructure *newStructure;
          newStructure = [[GdsZipedStructure alloc]
                          initWithDirectoryPath: fullPath
                                        library: self];
          [self addStructure: newStructure];
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
