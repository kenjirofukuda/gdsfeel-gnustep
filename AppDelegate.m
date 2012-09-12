#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "AppDelegate.h"

@implementation MyDelegate
- (BOOL) applicationShouldOpenUntitledFile:(NSApplication *)sender
{
  return NO;
}

@end
// vim: sw=2 ts=2 expandtab
