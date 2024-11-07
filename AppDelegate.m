#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "AppDelegate.h"

@implementation AppDelegate
- (BOOL) applicationShouldOpenUntitledFile: (NSApplication *)sender
{
  return NO;
}

/**
 * Invoked on notification that application will become active.
 */
- (void) applicationWillFinishLaunching: (NSNotification *)aNotification
{
  NSDebugLog(@"#applicationWillFinishLaunching");
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
