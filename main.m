#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "AppDelegate.h"

/* Important - on Windows we need to reference something from the
 * Renaissance.dll else it will not be linked in.
 *
 * Here is our random useless dummy reference.
 */
#ifdef __MINGW__
int (*linkRenaissanceIn)(int, const char **) = GSMarkupApplicationMain;
#endif

#ifdef GNUSTEP
  #define MENU_RESOURCE @"Menu-GNUstep"
#else
  #define MENU_RESOURCE @"Menu-OSX"
#endif

int
main(int argc, const char **argv)
{
  CREATE_AUTORELEASE_POOL(pool);
  AppDelegate *delegate;

  [NSApplication sharedApplication];
  delegate = [AppDelegate new];

  [NSBundle loadGSMarkupNamed: MENU_RESOURCE owner: delegate];

  [NSApp setDelegate: delegate];
  RELEASE(pool);
  return NSApplicationMain(argc, argv);
}

// vim: sw=2 ts=2 expandtab
