#import <Foundation/Foundation.h>
#import <AppKit/NSColor.h>
#import <GNUstepBase/GSXML.h>
#import "GdsLayer.h"
#import "GdsLibrary.h"

@interface GdsLayer (Private)
- (void) loadFromXMLNode: (GSXMLNode *)xmlNode;
@end

@interface GdsLayers (Private)
- (void) loadLayers;
@end

@implementation GdsLayer
- (id) initWithXMLNode: (GSXMLNode *)node
{
  self = [super init];
  if (self)
    {
      _selectable = NO;
      _visible = NO;
      _number = 0;
      ASSIGN(_color, [NSColor whiteColor]);
      [self loadFromXMLNode: node];
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_color);
  [super dealloc];
}

- (BOOL) selectable
{
  return _selectable;
}

- (BOOL) visible
{
  return _visible;
}

- (NSColor *) color
{
  return _color;
}

- (int) number
{
  return _number;
}
@end

@implementation GdsLayers
- (id) initWithPath: (NSString *)path library: (GdsLibrary *)library
{
  self = [super init];
  if (self)
    {
      ASSIGNCOPY(_path, path);
      _library = library;
      _layerMap = nil; // lazy
    }
  return self;
}

- (void) dealloc
{
  _library = nil;
  RELEASE(_path);
  RELEASE(_layerMap);
  [super dealloc];
}

- (GdsLayer *) layerAtNumber: (int)number
{
  NSString *key = [[NSNumber numberWithInt: number] stringValue];
  if (_layerMap == nil)
    {
      _layerMap = [[NSMutableDictionary alloc] init];
      [self loadLayers];
    }
  return [_layerMap valueForKey: key];
}

@end

@implementation GdsLayer (Private)
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

@implementation GdsLayers (Private)
- (void) loadLayers
{
  NSDebugLog(@"#loadLayers");
  GSXMLParser *parser = [GSXMLParser parserWithContentsOfFile: _path];
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
