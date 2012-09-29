#import <Foundation/Foundation.h>
#import "osxportability.h"
#import "GdsElement.h"
#import "GdsStructure.h"
#import "NSArray+Points.h"
#import <math.h>

static int sKeyNumber = 0;

@interface GdsElement (Private)
- (void) debugKeyValueLog;
@end

@implementation GdsElement
- (id) init
{
  return [self initWithXMLNode: nil structure: nil];
}

- (id) initWithXMLNode: (GSXMLNode *) xmlNode 
       structure: (GdsStructure *) structure
{
  self = [super init];
  if (self) 
    {
      _xyArray = [[NSArray alloc] init];
      sKeyNumber++;
      _keyNumber = sKeyNumber;
      _structure = structure;
      if (xmlNode != nil)
        {
          [self loadFromXMLNode: xmlNode];
        }
      return self;
    }
  return nil;
}

- (void) dealloc
{
  _structure = nil;
  RELEASE(_xyArray);
  RELEASE(_boundingBox);
  RELEASE(_outlinePoints);
  [super dealloc];
}

- (BOOL) isReference
{
  return NO;
}

- (GdsStructure *) structure
{
  return _structure;
}

- (NSArray *) vertices
{
  return [NSArray arrayWithArray: _xyArray];
}

- (NSArray *) outlinePoints
{
  if (_outlinePoints == nil)
    {
      ASSIGN(_outlinePoints, [self lookupOutlinePoints]);
    }
  return _outlinePoints;
}

- (NSArray *) lookupOutlinePoints
{
  return [self vertices];
}

static NSPoint pointFromXYstring(NSString *xyExpr)
{
  NSArray *items = [xyExpr componentsSeparatedByString: @" "];
  float x = [[items objectAtIndex: 0] floatValue];
  float y = [[items objectAtIndex: 1] floatValue];
  return NSMakePoint(x, y);
}

- (void) loadFromXMLNode: (GSXMLNode *) xmlNode
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

+ (GdsElement *) elementFromXMLNode: (GSXMLNode *) xmlNode
        structure: (GdsStructure *) structure
{
  NSString *typeName = [xmlNode objectForKey: @"type"];
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
      newElement = [[class alloc]
         initWithXMLNode: xmlNode structure: structure];        
    }
  return newElement;
}

- (int) keyNumber
{
  return _keyNumber;
}

- (NSString *) typeName
{
  return @"ERROR";
}

- (NSRect) boundingBox
{
  if (_boundingBox == nil)
    {
      ASSIGN(_boundingBox, [NSValue valueWithRect: [self lookupBoundingBox]]);
    }
  return [_boundingBox rectValue];
}

- (NSRect) lookupBoundingBox
{
  return [_xyArray lookupBoundingBox];
}

- (void) debugLog
{
  NSDebugLog(@"-------------------------------");
  NSDebugLog(@"type = %@", [self typeName]);
  NSDebugLog(@"description = %@", [self description]);
  NSDebugLog(@"keyNumber = %d", [self keyNumber]);
}
@end

@implementation GdsElement (Private)
- (void) debugKeyValueLog
{
  NSDebugLog(@"type = %@", [self valueForKey:@"typeName"]);
  NSDebugLog(@"keyNumber = %@", [self valueForKey:@"keyNumber"]);
  NSDebugLog(@"bound width = %f", NSWidth([self boundingBox]));
}

@end


@implementation GdsPrimitiveElement
- (id) init
{
  self = [super init];
  if (self != nil)
    {
      _layerNumber = 0;
      _dataType = 0;
      return self;
    }
  return nil;
}

- (void) loadFromXMLNode: (GSXMLNode *) xmlNode
{
  [super loadFromXMLNode: xmlNode];
  _layerNumber = [[xmlNode objectForKey: @"layerNumber"] intValue]; 
  _dataType = [[xmlNode objectForKey: @"datatype"] intValue]; 
}

- (int)layerNumber
{
  return _layerNumber;
}

- (int)dataType
{
  return _dataType;
}

- (void) debugLog
{
  [super debugLog];
  NSDebugLog(@"dataType = %d", [self dataType]);
  NSDebugLog(@"layerNumber = %d", [self layerNumber]);
  NSDebugLog(@"vertices = %@", [self vertices]);
  NSDebugLog(@"boundingBox = %@", [NSValue valueWithRect: [self boundingBox]]);
}
@end


@implementation GdsBoundary
- (NSString *) typeName
{
  return @"BOUNDARY";
}
@end

static double
getAngle(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2)
{
  double angle;

  if (x1 == x2)
    angle =  M_PI_2 * ((y2 > y1) ? 1 : -1);
  else
    {
      angle = atan(fabs(y2 - y1)/fabs(x2 - x1));
    if (y2 >= y1)
      {
  if (x2 >= x1)
    angle += 0;
  else
    angle = M_PI - angle;
      }
    else
      {
  if (x2 >= x1)
    angle = 2 * M_PI - angle;
  else
    angle += M_PI;
      }
    }
  return angle;
}

#define EPS 1e-8

static NSPoint
getDeltaXY(CGFloat hw, NSPoint p1, NSPoint p2, NSPoint p3)
{
  double alpha, beta, theta, r;
  NSPoint pnt;
  alpha = getAngle(p1.x, p1.y, p2.x, p2.y);
  beta = getAngle(p2.x, p2.y, p3.x, p3.y);
  theta = (alpha + beta + M_PI)/2.0;
  if (fabs(cos((alpha - beta) / 2.0)) < EPS)
    {
      NSWarnLog(@"Internal algorithm error: cos((alpha - beta)/2) = 0");
      return NSZeroPoint;
    }
  r = ((double) hw) / cos((alpha - beta) / 2.0); 
  pnt.x = (CGFloat) (r * cos(theta));
  pnt.y = (CGFloat) (r * sin(theta));
  return pnt;
}

static NSPoint
getEndDeltaXY(CGFloat hw, NSPoint p1, NSPoint p2)
{
  double alpha, theta, r;
  NSPoint pnt;
  alpha = getAngle(p1.x, p1.y, p2.x, p2.y);
  theta = alpha;
  r = hw;
  pnt.x = (CGFloat)(-r * sin(theta));
  pnt.y = (CGFloat)( r * cos(theta));
  return pnt;
}

NSArray *PathToBoundary(GdsPath *path)
{
  CGFloat hw = [path width] / 2.0;
  int i, numpoints = [[path vertices] count];
  NSPoint *points, deltaxy;
  int count;

  if (numpoints < 2)
    {
      NSWarnLog(@"PathToBoundary(): don't know to handle wires < 2 pts yet");
      return nil;
    }

  NSPoint *path_points = [[path vertices] asNSPointPtr: &count];
  points = (NSPoint *) malloc(sizeof(NSPoint) * (2 * numpoints + 1));

  deltaxy = getEndDeltaXY(hw, path_points[0], path_points[1]);

  if ([path pathType] == 0) //BUTT_END
    {
      points[0].x = path_points[0].x + deltaxy.x;
      points[0].y = path_points[0].y + deltaxy.y;
      points[2 * numpoints].x = path_points[0].x + deltaxy.x;
      points[2 * numpoints].y = path_points[0].y + deltaxy.y;
      points[2 * numpoints - 1].x = path_points[0].x - deltaxy.x;
      points[2 * numpoints - 1].y = path_points[0].y - deltaxy.y;
    }
  else /* Extended end */
    {
      points[0].x = path_points[0].x + deltaxy.x - deltaxy.y;
      points[0].y = path_points[0].y + deltaxy.y - deltaxy.x;
      points[2 * numpoints].x = path_points[0].x + deltaxy.x - deltaxy.y;
      points[2 * numpoints].y = path_points[0].y + deltaxy.y - deltaxy.x;
      points[2 * numpoints - 1].x = path_points[0].x - deltaxy.x - deltaxy.y;
      points[2 * numpoints - 1].y = path_points[0].y - deltaxy.y - deltaxy.x;
    }

  for (i = 1; i < numpoints - 1; i++)
    {
      deltaxy = getDeltaXY(hw, path_points[i - 1],
         path_points[i], path_points[i + 1]);
      points[i].x = path_points[i].x + deltaxy.x;
      points[i].y = path_points[i].y + deltaxy.y;
      points[2 * numpoints - i - 1].x = path_points[i].x - deltaxy.x;
      points[2 * numpoints - i - 1].y = path_points[i].y - deltaxy.y;
    }

  deltaxy = getEndDeltaXY(hw, path_points[numpoints - 2],
                          path_points[numpoints - 1]);
  if ([path pathType] == 0) // BUTT_END
    {
      points[numpoints - 1].x = path_points[numpoints - 1].x + deltaxy.x;
      points[numpoints - 1].y = path_points[numpoints - 1].y + deltaxy.y;
      points[numpoints].x = path_points[numpoints - 1].x - deltaxy.x;
      points[numpoints].y = path_points[numpoints - 1].y - deltaxy.y;
    }
  else /* Extended end */
    {
      points[numpoints - 1].x = 
        path_points[numpoints - 1].x + deltaxy.x + deltaxy.y;
      points[numpoints - 1].y =
        path_points[numpoints - 1].y + deltaxy.y + deltaxy.x;
      points[numpoints].x = 
        path_points[numpoints - 1].x - deltaxy.x + deltaxy.y;
      points[numpoints].y = 
        path_points[numpoints - 1].y - deltaxy.y + deltaxy.x;
    }
  free(path_points);  
  NSArray *result = [NSArray pointsFromNSPointPtr: points 
                                            count: (numpoints * 2 + 1)];
  return result;
}

@implementation GdsPath
- (id) init
{
  self = [super init];
  if (self != nil) 
    {
      _width = 0.0;
      _pathType = 0;
      return self;
    }
  return nil;
}

- (void) loadFromXMLNode: (GSXMLNode *) xmlNode
{
  [super loadFromXMLNode: xmlNode];
  _width = [[xmlNode objectForKey: @"width"] floatValue]; 
  _pathType = [[xmlNode objectForKey: @"pathtype"] intValue]; 
}

- (NSString *) typeName
{
  return @"PATH";
}

- (float) width
{
  return _width;
}

- (int) pathType
{
  return _pathType;
}

- (NSArray *) lookupOutlinePoints
{
  return PathToBoundary(self);
}

- (void) debugLog
{
  [super debugLog];
  NSDebugLog(@"width = %f", [self width]);
  NSDebugLog(@"pathType = %d", [self pathType]);
}
@end


@implementation GdsReferenceElement
- (id) init
{
  self = [super init];
  if (self != nil) 
    {
      _referenceName = [[NSString alloc] init];
      _angle = 0.0;
      _mag = 1.0;
      _reflected = NO;
      return self;
    }
  return nil;
}

- (BOOL) isReference
{
  return YES;
}

- (NSAffineTransform *) transform
{
  if (_transform == nil)
    {
      ASSIGN(_transform, [[NSAffineTransform alloc] init]);
      [_transform translateXBy: [self origin].x yBy: [self origin].y];
      [_transform rotateByDegrees: _angle];
      if (_reflected)
        {
          [_transform scaleXBy: 1.0 yBy: -1.0];
        }
    }
  return _transform;
}

- (GdsStructure *) referenceStructure
{
  if (_referenceStructure == nil)
    {
      GdsStructure *referenceStructure = nil;
      referenceStructure = 
        [[_structure library] structureForKey: [self referenceName]]; 
      if (referenceStructure == nil)
        {
          NSWarnLog(@"missing strucutre named: %@", [self referenceName]);
        }
      ASSIGN(_referenceStructure, referenceStructure);
    }
  return _referenceStructure;
}

- (NSRect) lookupBoundingBox
{
  return [[self lookupOutlinePoints] lookupBoundingBox];
}

- (NSArray *) basicOutlinePoints
{
  NSRect structureBounds = [[self referenceStructure] boundingBox];
  return  [[NSArray pointsFromNSRect: structureBounds]
      transformedPoints: [self transform]];
}

- (NSArray *) lookupOutlinePoints
{
  return [self basicOutlinePoints];
}

- (void) loadFromXMLNode: (GSXMLNode *) xmlNode
{
  [super loadFromXMLNode: xmlNode];
  ASSIGN(_referenceName, [xmlNode objectForKey: @"sname"]);
  NSDictionary *attr = [xmlNode attributes];
  NSString *valueStr;
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

- (void) dealloc
{
  RELEASE(_referenceName);
  [super dealloc];
}

- (NSString *) referenceName
{
  return _referenceName;
}

- (float) angle
{
  return _angle;
}

- (float) mag;
{
  return _mag;
}

- (BOOL) reflected
{
  return _reflected;
}

- (NSPoint) origin
{
  if ([_xyArray count] > 0)
    {
      return (NSPoint) [[_xyArray objectAtIndex: 0] pointValue];
    }
  return NSMakePoint(0,0); 
}

- (void) debugLog
{
  [super debugLog];
  NSDebugLog(@"referenceName = %@", [self referenceName]);
  NSDebugLog(@"mag = %f", [self mag]);
  NSDebugLog(@"angle = %f", [self angle]);
  NSDebugLog(@"reflected = %@", [self reflected] ? @"YES" : @"NO");
  NSDebugLog(@"origin = %@", NSStringFromPoint([self origin]));
}
@end // GdsPrimitiveElement


@implementation GdsSref
- (NSString *) typeName
{
  return @"SREF";
}
@end 


@implementation GdsAref
- (id) init
{
  self = [super init];
  if (self != nil) 
    {
      _rowCount = 1;
      _columnCount = 1;
      _rowSpacing = 0.0;
      _columnSpacing = 0.0;
      return self;
    }
  return nil;
}

- (void) loadFromXMLNode: (GSXMLNode *) xmlNode
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
  NSString *valueStr;
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

- (NSString *) typeName
{
  return @"AREF";
}

- (int) rowCount
{
  return _rowCount;
}

- (int) columnCount
{
  return _columnCount;
}

- (float) rowSpacing
{
  return _rowSpacing;
}

- (float) columnSpacing
{
  return _columnSpacing;
}

- (NSArray *) offsetTransforms
{
  if (_offsetTransforms == nil)
    {
      int ir, ic;
      NSMutableArray *transforms;
      transforms = [[NSMutableArray alloc] init];
      for (ic = 0; ic < [self columnCount]; ic++)
        {
          for (ir = 0; ir < [self rowCount]; ir++)
            {
              CGFloat xOffset, yOffset;
              xOffset = ic * [self columnSpacing]; 
              yOffset = ir * [self rowSpacing];
              NSAffineTransform *offsetTransform;
              offsetTransform = [NSAffineTransform transform];        
              [offsetTransform translateXBy: xOffset yBy: yOffset];
              [transforms addObject: offsetTransform];
            }
        }
      ASSIGN(_offsetTransforms, [NSArray arrayWithArray: transforms]);
      RELEASE(transforms);
    }
  return _offsetTransforms;
}

- (NSArray *) transforms
{
  if (_transforms == nil)
    {
      NSMutableArray *transforms;
      transforms = [[NSMutableArray alloc] init];
      NSEnumerator *iter = [[self offsetTransforms] objectEnumerator];
      NSAffineTransform *tx;
      while ((tx = [iter nextObject]) != nil)
        {
          NSAffineTransform *newTransform;
          newTransform = [[NSAffineTransform alloc] 
               initWithTransform: [self transform]];
          [newTransform prependTransform: tx];
          [transforms addObject: newTransform];
          RELEASE(newTransform);
        }
      ASSIGN(_transforms, [NSArray arrayWithArray: transforms]);
      RELEASE(transforms);
    }
  return _transforms;
}

- (NSArray *) lookupOutlinePoints
{
  NSRect bounds = [[self referenceStructure] boundingBox];
  CGFloat newWidth, newHeight;
  newWidth = [self columnCount] * [self columnSpacing] + bounds.size.width;
  newHeight = [self rowCount] * [self rowSpacing] + bounds.size.height; 
  return  [[NSArray pointsFromNSRect: bounds]
      transformedPoints: [self transform]];  
}

- (void) debugLog
{
  [super debugLog]; 
  NSDebugLog(@"rowCount = %d", [self rowCount]);
  NSDebugLog(@"columnCount = %d", [self columnCount]);
  NSDebugLog(@"rowSpacing = %f", [self rowSpacing]);
  NSDebugLog(@"columnSpacing = %f", [self columnSpacing]);
}
@end

// vim: sw=2 ts=2 expandtab
