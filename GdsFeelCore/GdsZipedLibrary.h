// -*- mode: ObjC -*-
#import "GdsArchiver.h"
#import "GdsLibrary.h"

@interface GdsZipedLibrary : GdsLibrary
{
  NSString       *_folderPath;
  GdsZipArchiver *_archiver;
}
- (NSString *) pathToExtract;
- (void) openForReading;
- (void) closeForReading;
+ (BOOL) isValidDatabase: (NSString *)fileName error: (NSError **)outError;
@end

// vim: filetype=objc ts=2 sw=2 expandtab
