#import <Foundation/Foundation.h>
#import "GdsFeelCore/osxportability.h"
#import "GdsFeelCore/GdsElement.h"

NSArray *
sampleElements()
{
  NSMutableArray *elements;

  elements = [NSMutableArray new];
  [elements addObject: [GdsBoundary new]];
  [elements addObject: [GdsPath new]];
  [elements addObject: [GdsSref new]];
  [elements addObject: [GdsAref new]];
  return [NSArray arrayWithArray: elements];
}

void
printElements()
{
  NSArray *elements = sampleElements();

  NSEnumerator *iter = [elements objectEnumerator];
  id            elm;
  while ((elm = [iter nextObject]) != nil)
    {
      [elm debugLog];
    }
}

void
logArray(const NSArray *array)
{
  NSEnumerator *iter;
  id            arg;
  iter = [array objectEnumerator];
  while ((arg = [iter nextObject]) != nil)
    {
      NSLog(@"%@", arg);
    }
}

void
printArguments()
{
  NSArray *arguments;

  arguments = [[NSProcessInfo processInfo] arguments];
  logArray(arguments);
  RELEASE(arguments);
}

NSString *
pathToProjectFromArguments(BOOL *ok)
{
  NSArray      *arguments;
  NSEnumerator *iter;
  BOOL          hasProject = NO;
  id            arg;
  NSString     *result = nil;

  arguments = [[NSProcessInfo processInfo] arguments];
  iter = [arguments objectEnumerator];
  while ((arg = [iter nextObject]) != nil)
    {
      if (hasProject == NO)
        {
          if ([arg isEqualToString: @"-project"] == YES)
            {
              hasProject = YES;
              continue;
            }
        }
      if (hasProject == YES)
        {
          result = arg;
          break;
        }
    }

  BOOL dir, exists;
  exists = [[NSFileManager defaultManager] fileExistsAtPath: result
                                                isDirectory: &dir];
  *ok = (exists == YES && dir == YES) ? YES : NO;
  return result;
}

BOOL
isLibrary(NSString *folderPath, NSString *name)
{
  if ([name hasSuffix: @".DB"] == NO)
    return NO;

  NSString *fullName;
  fullName = [[NSArray arrayWithObjects: folderPath, name, nil]
               componentsJoinedByString: @"/"];
  BOOL dir;
  BOOL exists;
  exists = [[NSFileManager defaultManager] fileExistsAtPath: fullName
                                                isDirectory: &dir];
  return (exists == YES && dir == NO) ? YES : NO;
}

void
printLibrary(NSString *path)
{
  NSArray        *names;
  NSMutableArray *dbs;
  NSString       *name;

  names = [[NSFileManager defaultManager] directoryContentsAtPath: path];
  if ([names count] == 0)
    return;
  dbs = [[NSMutableArray alloc] init];
  NSEnumerator *iter = [names objectEnumerator];
  while ((name = [iter nextObject]) != nil)
    {
      if (isLibrary(path, name) == YES)
        {
          [dbs addObject: name];
        }
    }
  logArray([NSArray arrayWithArray: dbs]);
  RELEASE(dbs);
}

int
main(int argc, const char **argv)
{
  CREATE_AUTORELEASE_POOL(arp);
  NSString *programName;
  programName = [NSString stringWithCString: argv[0]
                                   encoding: NSASCIIStringEncoding];
  NSLog(@"program = %@", programName);
  NSLog(@"   argc = %d", argc);
  // printArguments();
  NSString *path;
  BOOL      exist;
  path = pathToProjectFromArguments(&exist);
  if (exist == YES)
    {
      printElements();
      NSLog(@"%@", path);
      printLibrary(path);
    }
  else
    {
      NSWarnLog(@"Project path not found: %@", path);
    }
  RELEASE(arp);
  exit(0);
  return 0;
}

// vim: sw=2 ts=2 expandtab
