// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>

@interface GdsZipArchiver : NSObject
- (NSString *) pathToZipCommand;
- (NSString *) pathToUnzipCommand;
- (BOOL) isZipArchiverEnabled;
- (BOOL) isZipFile: (NSString *)fileName;
- (BOOL) extractFile: (NSString *)fileName
       intoDirectory: (NSString *)directoryName;

+ (GdsZipArchiver *) defaultArchiver;
@end
// vim: filetype=objc ts=2 sw=2 expandtab
