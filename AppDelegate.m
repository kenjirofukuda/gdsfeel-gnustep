#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "AppDelegate.h"

@implementation AppDelegate
- (BOOL) applicationShouldOpenUntitledFile:(NSApplication *)sender
{
  return NO;
}

- (void) awakeFromGSMarkup
{
  NSDebugLog(@"#awakeFromGSMarkup");
}

- (void) bundleDidLoadGSMarkup: (NSNotification *)aNotification
{
  NSDebugLog(@"#bundleDidLoadGSMarkup:");
}

@end
// vim: sw=2 ts=2 expandtab
