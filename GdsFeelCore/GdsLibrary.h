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
  NSString *_folderPath;
  GdsZipArchiver *_archiver;
  NSMutableArray *_structures;
  NSMutableDictionary *_structureMap;
  NSArray *_structureNames;
  GdsLayers *_layers;
}
- (id) initWithPath: (NSString *) fileName;
- (void) dealloc;

- (NSString *) localName;
- (NSString *) keyName;
- (NSString *) pathToExtract;

- (NSArray *) structureNames;
- (NSArray *) structures;
- (GdsStructure *) structureForKey: (NSString *) keyName;
- (GdsLayers *) layers;

- (BOOL) isOpen;
- (void) openForReading;
- (void) closeForReading;
- (void) debugLog;
+ (BOOL) isValidDatabase: (NSString *)fileName
		   error: (NSError **) outError;
@end
// vim: filetype=objc ts=2 sw=2 expandtab
