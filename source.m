#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MyDelegate : NSObject
{
  NSWindow *_window;
}

- (void) printHello: (id)sender;
- (void) dealloc;
- (void) createMenu;
- (void) createWindow;
- (void) applicationWillFinishLaunching: (NSNotification *) notification;
- (void) applicationDidFinishLaunching: (NSNotification *) notification;
@end

@implementation MyDelegate
- (void) dealloc
{
  [_window release];
  _window = nil;
  [super dealloc];
}

- (void) printHello: (id)sender
{
  printf("Hello!\n");
}


- (void) applicationWillFinishLaunching: (NSNotification *) notification
{
  [self createMenu];
  [self createWindow];
}

- (void) createMenu
{
  NSMenu *menu;
  NSMenu *infoMenu;
  NSMenuItem *menuItem;

  infoMenu = AUTORELEASE([NSMenu new]);

  [infoMenu addItemWithTitle: @"Info Panel..."
                      action: @selector(orderFrontStandardInfoPanel:)
               keyEquivalent: @""];

  [infoMenu addItemWithTitle: @"Help..."
                      action: @selector(orderFrontHelpPanel:)
               keyEquivalent: @"?"];

  menu = AUTORELEASE([NSMenu new]);

  menuItem = [menu addItemWithTitle: @"Info..."
                             action: (SEL) nil 
                      keyEquivalent: @""];
  [menu setSubmenu: infoMenu forItem: menuItem];

  [menu addItemWithTitle: @"Print Hello"
                  action: @selector(printHello:)
           keyEquivalent: @""];

  [menu addItemWithTitle: @"Quit"
                  action: @selector(terminate:)
           keyEquivalent: @"q"];

  [NSApp setMainMenu: menu];
}


- (void) createWindow
{
  NSButton *button;
  NSSize buttonSize;

  button = [[NSButton new] autorelease];
  [button setTitle: @"Print Hello"];
  [button sizeToFit];
  [button setTarget: self];
  [button setAction: @selector(printHello:)];

  buttonSize = [button frame].size;

  NSRect rect = NSMakeRect(100, 100, buttonSize.width, buttonSize.height);
  unsigned int styleMask = NSTitledWindowMask | NSMiniaturizableWindowMask;

  _window = [NSWindow alloc];
  _window = [_window initWithContentRect: rect
                               styleMask: styleMask
                                 backing: NSBackingStoreBuffered
                                   defer: NO];
  [_window setTitle: @"GDSII"];
  [_window setContentView: button];
}

- (void) applicationDidFinishLaunching: (NSNotification *) notification
{
  [_window makeKeyAndOrderFront: nil];
}
@end

int
main(int argc, const char **argv)
{
  [NSApplication sharedApplication];
  [NSApp setDelegate: [MyDelegate new]];
  return NSApplicationMain(argc, argv);
}

// vim: sw=2 ts=2 expandtab
