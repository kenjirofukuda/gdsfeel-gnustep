// -*- mode: ObjC -*-
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import "GdsArchiver.h"

@class GdsStructure;
@class GdsLayers;

extern NSString * const GdsLibraryErrorDomain;

@interface GdsLibrary : NSObject
{
  NSString *_path;
  NSString *_keyName;
  NSMutableArray *_structures;
  NSMutableDictionary *_structureMap;
  NSArray *_structureNames;
  GdsLayers *_layers;
}

- (id) initWithPath: (NSString *) fileName;
- (void) dealloc;

- (NSString *) localName;
- (NSString *) keyName;

- (NSArray *) structureNames;
- (NSArray *) structures;
- (GdsStructure *) structureForKey: (NSString *) keyName;
- (GdsLayers *) layers;

- (BOOL) isOpen;
- (void) debugLog;

- (NSArray *) lookupStructureNames;
- (void) loadStructures;

@end

@interface GdsZipedLibrary : GdsLibrary
{
  NSString *_folderPath;
  GdsZipArchiver *_archiver;
}
- (NSString *) pathToExtract;
- (void) openForReading;
- (void) closeForReading;
+ (BOOL) isValidDatabase: (NSString *)fileName
                   error: (NSError **) outError;
@end





// vim: filetype=objc ts=2 sw=2 expandtab
