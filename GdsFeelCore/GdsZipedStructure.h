// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import "GdsStructure.h"

@interface GdsZipedStructure : GdsStructure
{
  NSString *_directoryPath;
}
- initWithDirectoryPath: (NSString *)directoryPath
                library: (GdsLibrary *)library;
@end
// vim: filetype=objc ts=2 sw=2 expandtab
