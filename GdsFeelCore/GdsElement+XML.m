#import <Foundation/Foundation.h>
#import "osxportability.h"
#import "GdsElement+XML.h"
#import "GdsStructure.h"
#import "GdsBase.h"
#import "NSArray+Points.h"
#import <math.h>

@implementation GdsElement (XML)
- (id) initWithXMLNode: (GSXMLNode *)xmlNode structure: (GdsStructure *)structure
{
  self = [super init];
  if (self)
    {
      ASSIGN(_structure, structure);
      if (xmlNode != nil)
        {
          [self loadFromXMLNode: xmlNode];
        }
      return self;
    }
  return nil;
}

static NSPoint
pointFromXYstring(NSString *xyExpr)
{
  NSArray *items = [xyExpr componentsSeparatedByString: @" "];
  float    x = [[items objectAtIndex: 0] floatValue];
  float    y = [[items objectAtIndex: 1] floatValue];
  return NSMakePoint(x, y);
}

- (void) loadFromXMLNode: (GSXMLNode *)xmlNode
{
  _keyNumber = [[xmlNode objectForKey: @"keyNumber"] intValue];
  GSXMLNode *node = [xmlNode firstChildElement];
  GSXMLNode *verticesNode = nil;
  while (node != nil)
    {
      if ([[node name] isEqualToString: @"vertices"])
        {
          verticesNode = node;
          break;
        }
      node = [node nextElement];
    }
  if (verticesNode == nil)
    {
      NSWarnLog(@"missing vertices node");
      return;
    }
  node = [verticesNode firstChildElement];
  NSMutableArray *xyArray = [[NSMutableArray alloc] init];
  while (node != nil)
    {
      if ([[node name] isEqualToString: @"xy"])
        {
          [xyArray addPoint: pointFromXYstring([node content])];
        }
      node = [node nextElement];
    }
  ASSIGN(_xyArray, [NSArray arrayWithArray: xyArray]);
  RELEASE(xyArray);
}

+ (GdsElement *) elementFromXMLNode: (GSXMLNode *)xmlNode
                          structure: (GdsStructure *)structure
{
  NSString   *typeName = [xmlNode objectForKey: @"type"];
  GdsElement *newElement = nil;
  Class class = Nil;
  if ([typeName isEqualToString: @"boundary"])
    {
      class = [GdsBoundary class];
    }
  if ([typeName isEqualToString: @"path"])
    {
      class = [GdsPath class];
    }
  if ([typeName isEqualToString: @"sref"])
    {
      class = [GdsSref class];
    }
  if ([typeName isEqualToString: @"aref"])
    {
      class = [GdsAref class];
    }
  if (class != Nil)
    {
      newElement = [[class alloc] initWithXMLNode: xmlNode structure: structure];
    }
  return newElement;
}

@end

@implementation GdsPrimitiveElement (XML)
- (void) loadFromXMLNode: (GSXMLNode *)xmlNode
{
  [super loadFromXMLNode: xmlNode];
  _layerNumber = [[xmlNode objectForKey: @"layerNumber"] intValue];
  _dataType = [[xmlNode objectForKey: @"datatype"] intValue];
}
@end

@implementation GdsPath (XML)
- (void) loadFromXMLNode: (GSXMLNode *)xmlNode
{
  [super loadFromXMLNode: xmlNode];
  _width = [[xmlNode objectForKey: @"width"] floatValue];
  _pathType = [[xmlNode objectForKey: @"pathtype"] intValue];
}
@end

@implementation GdsReferenceElement (XML)
- (void) loadFromXMLNode: (GSXMLNode *)xmlNode
{
  [super loadFromXMLNode: xmlNode];
  ASSIGN(_referenceName, [xmlNode objectForKey: @"sname"]);
  NSDictionary *attr = [xmlNode attributes];
  NSString     *valueStr;
  valueStr = [attr valueForKey: @"mag"];
  if (valueStr == nil)
    {
      valueStr = @"1.0";
    }
  _mag = [valueStr floatValue];
  valueStr = [attr valueForKey: @"angle"];
  if (valueStr == nil)
    {
      valueStr = @"0.0";
    }
  _angle = [valueStr floatValue];
  valueStr = [attr valueForKey: @"reflected"];
  if (valueStr == nil)
    {
      valueStr = @"false";
    }
  else
    {
      if ([valueStr isEqualToString: @"true"])
        {
          valueStr = @"true";
        }
      else if ([valueStr isEqualToString: @"false"])
        {
          valueStr = @"false";
        }
      else
        {
          valueStr = @"false";
        }
    }
  _reflected = [valueStr isEqualToString: @"true"] == YES;
}
@end // GdsPrimitiveElement

@implementation GdsAref (XML)
- (void) loadFromXMLNode: (GSXMLNode *)xmlNode
{
  [super loadFromXMLNode: xmlNode];
  GSXMLNode *node = [xmlNode firstChildElement];
  GSXMLNode *ashapeNode = nil;
  while (node != nil)
    {
      if ([[node name] isEqualToString: @"ashape"])
        {
          ashapeNode = node;
          break;
        }
      node = [node nextElement];
    }
  if (ashapeNode == nil)
    {
      NSWarnLog(@"missing aref node");
      return;
    }
  NSDictionary *attr = [ashapeNode attributes];
  NSString     *valueStr;
  valueStr = [attr valueForKey: @"rows"];
  if (valueStr == nil)
    {
      valueStr = @"1";
    }
  _rowCount = [valueStr intValue];

  valueStr = [attr valueForKey: @"cols"];
  if (valueStr == nil)
    {
      valueStr = @"1";
    }
  _columnCount = [valueStr intValue];

  valueStr = [attr valueForKey: @"row-spacing"];
  if (valueStr == nil)
    {
      valueStr = @"0.0";
    }
  _rowSpacing = [valueStr floatValue];

  valueStr = [attr valueForKey: @"column-spacing"];
  if (valueStr == nil)
    {
      valueStr = @"0.0";
    }
  _columnSpacing = [valueStr floatValue];
}
@end

// vim: sw=2 ts=2 expandtab
