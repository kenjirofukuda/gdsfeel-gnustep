#import <Foundation/Foundation.h>
#import "osxportability.h"
#import "GdsArchiver.h"

static GdsZipArchiver *sDefaultArchiver = nil;

@interface GdsZipArchiver (Private)
- (NSString *) execArguments: (NSArray *) arguments
                     extract: (BOOL) extract
                    exitCode: (int *) code;
@end

@implementation GdsZipArchiver
- (NSString*) pathToZipCommand
{
#ifdef __MINGW32__
  return @"C:/Program Files/GnuWin32/bin/zip.exe";
#else
  return @"/usr/bin/zip";
#endif
}

- (NSString*) pathToUnzipCommand
{
#ifdef __MINGW32__
  return @"C:/Program Files/GnuWin32/bin/unzip.exe";
#else
  return @"/usr/bin/unzip";
#endif
}

- (BOOL) isZipArchiverEnabled
{
  BOOL exists, isDir;
  NSMutableArray *paths = [NSMutableArray new];
  exists = [[NSFileManager defaultManager]
             fileExistsAtPath: [self pathToZipCommand] isDirectory: &isDir];
  if (exists == NO || isDir == YES)
    {
      [paths addObject: [self pathToZipCommand]];
    }

  exists = [[NSFileManager defaultManager]
             fileExistsAtPath: [self pathToUnzipCommand] isDirectory: &isDir];
  if (exists == NO || isDir == YES)
    {
      [paths addObject: [self pathToUnzipCommand]];
    }
  if ([paths count] > 0)
    {
//    NSRunAlertPanel(@"Configuration Error",
//                    @"zip or unzip command not specified",
//                    nil, nil, nil);
      RELEASE(paths);
      return NO;
    }

  RELEASE(paths);
  return YES;
}

- (BOOL) isZipFile: (NSString*) fileName
{
  NSString *resultString;
  int code;
  resultString = [self execArguments:
                    [NSArray arrayWithObjects: @"-t", fileName, nil]
                             extract: YES
				                    exitCode: &code];
  NSDebugLog(resultString);
  return code == 0;
}

- (BOOL) extractFile: (NSString*) fileName
       intoDirectory: (NSString*) directoryName 
{
  NSString *resultString;
  int code;
  resultString = [self execArguments:
    [NSArray arrayWithObjects: fileName, @"-d", directoryName, nil]
                             extract: YES
 				            exitCode: &code];
  NSDebugLog(resultString);
  return code == 0;
}

+ (GdsZipArchiver*) defaultArchiver
{
  if (sDefaultArchiver == nil)
    {
      sDefaultArchiver = [[GdsZipArchiver alloc] init];
    }
  return sDefaultArchiver;
}
@end

@implementation GdsZipArchiver (Private)
- (NSString *) execArguments: (NSArray *) arguments
                     extract: (BOOL) extract
                    exitCode: (int *) code
{
  NSTask *task = [NSTask new];
  NSPipe *readPipe = [NSPipe pipe];
  NSFileHandle *readHandle = [readPipe fileHandleForReading];

  [task setLaunchPath:
     extract ? [self pathToUnzipCommand] : [self pathToZipCommand]];
  [task setArguments: arguments];
  [task setStandardOutput: readPipe];
  [task launch];

  NSData *data = [readHandle readDataToEndOfFile];
  [task waitUntilExit];

  NSString *resultString = AUTORELEASE([[NSString alloc] initWithData: data
                                         encoding: NSUTF8StringEncoding]);
  if (code != 0)
    {
      *code = [task terminationStatus];
    }
  RELEASE(task);
  return resultString;
}
@end

// vim: ts=2 sw=2 expandtab