#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Renaissance/Renaissance.h>
#import "GdsLibraryDocument.h"

@interface GdsLibraryDocument (Private)
- (void) logOutlet;
@end

@implementation GdsLibraryDocument
- (NSString *) windowNibName
{
  return @"Window";
}

- (void) dealloc
{
  DESTROY(_library);
  [super dealloc];
}

- (void) close
{
  [_library closeForReading];
  [super close];
}

- (BOOL) readFromURL: (NSURL *) absoluteURL 
              ofType: (NSString *) typeName 
               error: (NSError **) outError
{
  NSString *fileName = [absoluteURL path];
  NSDebugLog(@"open => %@", fileName);
  BOOL valid = [GdsLibrary isValidDatabase: fileName error: outError];
  if (valid == NO)
    {
      return NO;
    }

  _library = [[GdsLibrary alloc] initWithPath: fileName];
  [_library openForReading];
  NSDebugLog(@"structures = %@", [[_library structureNames] description]);
  return YES;
}

- (void) windowControllerDidLoadNib: (NSWindowController*) windowController
{
  [super windowControllerDidLoadNib: windowController];
  NSDebugLog(@"#windowControllerDidLoadNib:");
  NSDebugLog(@"windowController = %@", windowController);
  NSDebugLog(@"window = %@", [windowController window]);
  [[windowController window] setTitle: [NSString 
                     stringWithFormat: @"GDSII: %@", [_library keyName]]];
  [self logOutlet];
  [structureListView setDataSource: self];
  [structureListView setDelegate: self];
  [structureView setInfoBar: infoBarView];
  NSDebugLog(@"#windowControllerDidLoadNib: ca");
}
@end


@implementation GdsLibraryDocument (TableView)
- (NSInteger) numberOfRowsInTableView: (NSTableView*)aTableView
{
  if (_library == nil)
    {
      return 0;
    }
  return [[_library structureNames] count];
}

- (id)          tableView: (NSTableView*)aTableView 
objectValueForTableColumn: (NSTableColumn*)aTableColumn 
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
- (void) tableViewSelectionDidChange: (NSNotification*)aNotification
{
  NSDebugLog(@"#tableViewSelectionDidChange: %@", aNotification);
  NSString *structureName;
  structureName = [[_library structureNames] 
        objectAtIndex: [structureListView selectedRow]];
  GdsStructure *structure;
  structure = [_library structureForKey: structureName];
  [structureView setStructure: structure];
  NSDebugLog(@"structure = %@", structure);
}
@end


@implementation GdsLibraryDocument (Private)
- (void) logOutlet
{
  NSDebugLog(@"infoBarView = %@", infoBarView);
  NSDebugLog(@"structureView = %@", structureView);
  NSDebugLog(@"structureListView = %@", structureListView);
}
@end

// vim: sw=2 ts=2 expandtab filetype=objc
