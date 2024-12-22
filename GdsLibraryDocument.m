#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "GdsLibraryDocument.h"
#import "GdsFeelCore/GdsInform.h"

@interface GdsLibraryDocument (Private)
- (void) logOutlet;
@end

@interface GdsLibraryDocument (Actions)
- (IBAction) showStructures: (id)sender;
- (IBAction) hideStructures: (id)sender;
@end

@implementation GdsLibraryDocument
- (NSString *) windowNibName
{
  return @"Window";
}

- (void) dealloc
{
  DESTROY(_library);
  RELEASE(elementListDelegate);
  DEALLOC;
}

- (ElementListDelegate *) elementListDelegate
{
  return elementListDelegate;
}

- (void) close
{
  [_library closeForReading];
  [super close];
}

- (BOOL) readFromURL: (NSURL *)absoluteURL
              ofType: (NSString *)typeName
               error: (NSError **)outError
{
  NSString *fileName = [absoluteURL path];
  NSLog(@"absoluteURL => %@", absoluteURL);
  NSLog(@"   fileName => %@", fileName);
  NSLog(@"   typeName => %@", typeName);

  if ([typeName isEqualToString: @"gds"])
    {
      GdsInform *inform = [[GdsInform alloc] initWithFilename: fileName];
      [inform run];
      ASSIGN(_library, [inform library]);
      NSDebugLLog(@"Record",  @"structures = %@", [[_library structureNames] description]);
      NSLog(@"usedLayerNumbers = %@", [_library usedLayerNumbers]);
      return YES;
    }

  BOOL valid = [GdsZipedLibrary isValidDatabase: fileName error: outError];
  if (valid == NO)
    {
      return NO;
    }

  _library = [[GdsZipedLibrary alloc] initWithPath: fileName];
  [_library openForReading];
  NSDebugLog(@"structures = %@", [[_library structureNames] description]);
  return YES;
}

- (void) windowControllerDidLoadNib: (NSWindowController *)windowController
{
  [super windowControllerDidLoadNib: windowController];
  NSDebugLog(@"#windowControllerDidLoadNib:");
  NSDebugLog(@"windowController = %@", windowController);
  NSDebugLog(@"          window = %@", [windowController window]);
  [[windowController window]
   setTitle: [NSString stringWithFormat: @"GDSII: %@", [_library keyName]]];
  [self logOutlet];

  NSAssert(structureListView != nil, @"structureListView != nil");
  [structureListView setDelegate: self];
  [structureListView setDataSource: self];
  [structureView setInfoBar: infoBarView];

  elementListDelegate = [[ElementListDelegate alloc] init];
  NSAssert(elementListView != nil, @"elementListView != nil");
  [elementListView setDelegate: elementListDelegate];
  [elementListView setDataSource: elementListDelegate];
}

@end

@implementation GdsLibraryDocument (TableView)
- (NSInteger) numberOfRowsInTableView: (NSTableView *)aTableView
{
  if (_library == nil)
    {
      return 0;
    }
  return [[_library structureNames] count];
}

- (id)          tableView: (NSTableView *)aTableView
objectValueForTableColumn: (NSTableColumn *)aTableColumn
                      row: (NSInteger)rowIndex
{
  if ([[aTableColumn identifier] isEqualToString: @"Name"])
    {
      return [[_library structureNames] objectAtIndex: rowIndex];
    }
  return nil;
}
@end

@implementation GdsLibraryDocument (TableViewDelegate)
- (void) tableViewSelectionDidChange: (NSNotification *)aNotification
{
  NSDebugLog(@"#tableViewSelectionDidChange: %@", aNotification);
  NSInteger rowIndex = [structureListView selectedRow];
  if (rowIndex < 0) return;
  NSString *structureName = [[_library structureNames] objectAtIndex: rowIndex];
  GdsStructure *structure = [_library structureForKey: structureName];
  [structureView setStructure: structure];
  [elementListDelegate setStructure: structure];
  [elementListView reloadData];
  NSDebugLog(@"structure = %@", structure);
}
@end

@implementation GdsLibraryDocument (Private)
- (void) logOutlet
{
  NSDebugLog(@"      infoBarView = %@", infoBarView);
  NSDebugLog(@"    structureView = %@", structureView);
  NSDebugLog(@"structureListView = %@", structureListView);
}
@end

@implementation GdsLibraryDocument (Actions)
- (void) setStructuresVisible: (BOOL)state
{
  NSView *view = structuresArea;
  NSLog(@"view: %@", view);

  [view setHidden: ! state];
  [view setNeedsDisplay: YES];
  [[view superview] layout];
}

- (IBAction) showStructures: (id)sender
{
  NSLog(@"showStructures: %@", sender);
  [self setStructuresVisible: YES];
}

- (IBAction) hideStructures: (id)sender
{
  NSLog(@"hideStructures: %@", sender);
  [self setStructuresVisible: NO];
}
@end


@implementation ElementListDelegate
- (instancetype) init
{
  self = [super init];
  if (self != nil)
    {
      _structure = nil;
    }
  return self;
}

- (void) dealloc
{
  TEST_RELEASE(_structure);
  DEALLOC;
}

- (void) setStructure: (GdsStructure *)structure
{
  ASSIGN(_structure, structure);
  NSLog(@"_structure: %@", _structure);
}

@end

@implementation ElementListDelegate (TableView)
- (NSInteger) numberOfRowsInTableView: (NSTableView *)aTableView
{
  if (_structure == nil)
    {
      return 0;
    }
  return [[_structure elements] count];
}

- (id)          tableView: (NSTableView *)aTableView
objectValueForTableColumn: (NSTableColumn *)aTableColumn
                      row: (NSInteger)rowIndex
{
  if ([[aTableColumn identifier] isEqualToString: @"Item"])
    {
      return [[[_structure elements] objectAtIndex: rowIndex] recordDescription];
    }
  return nil;
}
@end

@implementation ElementListDelegate (TableViewDelegate)
- (void) tableViewSelectionDidChange: (NSNotification *)aNotification
{
  NSLog(@"tableViewSelectionDidChange: %@", aNotification);
}
@end

// vim: sw=2 ts=2 expandtab filetype=objc
