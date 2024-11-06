#import <Foundation/Foundation.h>
#import <GNUstepBase/GSXML.h>
#import "GdsZipedStructure.h"
#import "GdsElement+XML.h"
#import "NSArray+Points.h"

@interface GdsZipedStructure(Private)
- (int) lastRevisionNumber;
- (NSString *) pathWithRevisionNumber: (int)revision;
- (void) changePermissions;
@end


@implementation GdsZipedStructure
- initWithDirectoryPath: (NSString *)directoryPath
                library: (GdsLibrary *)library
{
  self = [super initWithLibrary: library];
  if (self != nil)
    {
      ASSIGNCOPY(_directoryPath, directoryPath);
      [self changePermissions];
    }
  return self;
}


- (void) dealloc
{
  RELEASE(_directoryPath);
  [super dealloc];
}


- (NSString *) name
{
  if (_name == nil)
    {
      ASSIGN(_name, [[_directoryPath lastPathComponent]
                     stringByDeletingPathExtension]);
    }
  return _name;
}

@end


@implementation GdsZipedStructure(Private)
- (int) lastRevisionNumber
{
  NSMutableArray *revisions = [NSMutableArray new];
  NSArray *allNames = [[NSFileManager defaultManager]
                       directoryContentsAtPath: _directoryPath];
  NSString *name;
  NSEnumerator *iter = [allNames objectEnumerator];
  while ((name = [iter nextObject]) != nil)
    {
      NSArray *items = [name componentsSeparatedByString: @"."];
      NSDebugLog(@"%@", [items description]);
      if ([items count] < 3)
        {
          NSWarnLog(@"Invarid structure format");
          continue;
        }
      // NSString *structureName = [items objectAtIndex: 0];
      NSString *rev = [items objectAtIndex: 1];
      NSNumber *revision = [NSNumber numberWithInt: [rev intValue]];
      [revisions addObject: revision];
      // NSString *extension = [items objectAtIndex: 2];
    }

  if ([revisions count] == 0)
    return -1;
  NSArray *sorted = [revisions sortedArrayUsingSelector: @selector(compare:)];
  return [[sorted objectAtIndex: [revisions count] - 1] intValue];
}

- (NSString *) pathWithRevisionNumber: (int)revision
{
  NSString *fileName;
  fileName = [[NSArray arrayWithObjects:
               [self name],
               [[NSNumber numberWithInt: [self lastRevisionNumber]]
                stringValue],
               @"gdsfeelbeta", nil]
               componentsJoinedByString: @"."];

  return [NSString pathWithComponents:
                   [NSArray arrayWithObjects:
                    _directoryPath, fileName, nil]];
}

- (void) changePermissions
{
  NSUInteger perm;
  NSMutableDictionary *fileAttributes;
  fileAttributes = [[[NSFileManager defaultManager]
                     fileAttributesAtPath: _directoryPath
                     traverseLink: YES] mutableCopy];

  perm = [fileAttributes filePosixPermissions];
  if (perm == NSNotFound)
    {
      NSWarnLog(@"directory node found");
      return;
    }
  NSDebugLog(@"before perm = %lo", perm);
  if ((perm & 0100) == 0)
    {
      [[NSFileManager defaultManager]
       changeFileAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithUnsignedInt: (perm | 0700)],
        NSFilePosixPermissions, nil]
                     atPath: _directoryPath];
    }
  RELEASE(fileAttributes);
  fileAttributes = [[[NSFileManager defaultManager]
                     fileAttributesAtPath: _directoryPath
                     traverseLink: YES] mutableCopy];
  perm = [fileAttributes filePosixPermissions];
  NSDebugLog(@"after  perm = %lo", perm);
  RELEASE(fileAttributes);
}


- (void) loadElements
{
  NSDebugLog(@"#loadElements");
  if ([self lastRevisionNumber] <= 0)
    {
      NSWarnLog(@"empty structure");
      return;
    }
  [self changePermissions];
  NSString *pathToData = [self pathWithRevisionNumber:
                               [self lastRevisionNumber]];
  GSXMLParser *parser = [GSXMLParser parserWithContentsOfFile: pathToData];
  if (parser == nil)
    {
      NSWarnLog(@"parser get fail");
      return;
    }
  if ([parser parse] == NO)
    {
      NSWarnLog(@"parse error");
      return;
    }
  GSXMLDocument *doc = [parser document];
  if (doc == nil)
    {
      NSWarnLog(@"document get fail");
      return;
    }
  GSXMLNode *rootNode = [doc root];
  GSXMLNode *node = [rootNode firstChildElement];
  while (node != nil)
    {
      NSDebugLog(@"node = %@", node);
      GdsElement *newElement;
      newElement = [GdsElement elementFromXMLNode: node structure: self];
      if (newElement != nil)
        {
          [self addElement: newElement];
          [newElement debugLog];
        }
      node = [node nextElement];
    }
}
@end


// vim: ts=2 sw=2 expandtab
