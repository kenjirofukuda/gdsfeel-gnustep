#import <Foundation/Foundation.h>
#import <AppKit/NSColor.h>
#import <GNUstepBase/GSXML.h>
#import "GdsLayer+XML.h"
#import "GdsLibrary.h"

@implementation GdsLayer (XML)
- (id) initWithXMLNode: (GSXMLNode *)node
{
  self = [super init];
  if (self)
    {
      [self loadFromXMLNode: node];
    }
  return self;
}

- (void) loadFromXMLNode: (GSXMLNode *)xmlNode
{
  _visible = [[xmlNode objectForKey: @"visible"] boolValue];
  _selectable = [[xmlNode objectForKey: @"selectable"] boolValue];
  _number = [[xmlNode objectForKey: @"gdsno"] intValue];
  GSXMLNode *node = [xmlNode firstChildElement];
  GSXMLNode *colorNode = nil;
  while (node != nil)
    {
      if ([[node name] isEqualToString: @"color"])
        {
          colorNode = node;
          break;
        }
      node = [node nextElement];
    }
  if (colorNode)
    {
      float a, r, g, b;
      r = [[colorNode objectForKey: @"r"] floatValue];
      g = [[colorNode objectForKey: @"g"] floatValue];
      b = [[colorNode objectForKey: @"b"] floatValue];
      a = [[colorNode objectForKey: @"a"] floatValue];
      ASSIGN(_color, [NSColor colorWithDeviceRed: r green: g blue: b alpha: a]);
    }
}
@end

@implementation GdsLayersXML
- (instancetype) initWithLibrary: (GdsLibrary *)library xmlPath: (NSString *)path 
{
  self = [super initWithLibrary: library];
  if (self)
    {
      ASSIGNCOPY(_xmlPath, path);
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_xmlPath);
  DEALLOC;
}

- (void) loadLayers
{
  NSDebugLog(@"#loadLayers");
  GSXMLParser *parser = [GSXMLParser parserWithContentsOfFile: _xmlPath];
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
      GdsLayer *newLayer;
      newLayer = [[GdsLayer alloc] initWithXMLNode: node];
      if (newLayer != nil)
        {
          [_layerMap
           setValue: newLayer
             forKey: [[NSNumber numberWithInt: [newLayer number]] stringValue]];
        }
      node = [node nextElement];
    }
}

@end

// vim: ts=2 sw=2 expandtab
