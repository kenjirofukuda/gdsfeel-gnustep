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
  RELEASE(_elementListDelegate);
  DEALLOC;
}

- (ElementListDelegate *) elementListDelegate
{
  return _elementListDelegate;
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
  NSDebugLog(@"window = %@", [windowController window]);
  [[windowController window]
   setTitle: [NSString stringWithFormat: @"GDSII: %@", [_library keyName]]];
  [self logOutlet];

  [structureListView setDelegate: self];
  [structureListView setDataSource: self];
  [structureListView setDrawsGrid: NO];
  [structureView setInfoBar: infoBarView];

  _elementListDelegate = [[ElementListDelegate alloc] init];
  NSLog(@"elementListView: %@", elementListView);
  [elementListView setDelegate: _elementListDelegate];
  [elementListView setDataSource: _elementListDelegate];
  [elementListView setBackgroundColor: [NSColor redColor]];
  [elementListView setDrawsGrid: YES];
  
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
  [_elementListDelegate setStructure: structure];
  [elementListView setNeedsDisplay: YES];
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
  if (_structure == nil) return nil;
  if ([[aTableColumn identifier] isEqualToString: @"Item"])
    {
      return [[_structure elements] objectAtIndex: rowIndex];
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
