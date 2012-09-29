// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import <GNUstepBase/GSXML.h>

@class GdsStructure;

@interface GdsElement : NSObject
{
  int _keyNumber;
  NSArray *_xyArray;
  GdsStructure *_structure;
  NSValue *_boundingBox;
  NSArray *_outlinePoints;
}
- (id) init;
- (id) initWithXMLNode: (GSXMLNode *) xmlNode 
             structure: (GdsStructure *) structure;
- (void) dealloc;
- (void) loadFromXMLNode: (GSXMLNode *) xmlNode;

- (NSArray *) vertices;
- (NSArray *) outlinePoints;
- (int) keyNumber;
- (NSRect) boundingBox;
- (NSString *) typeName;
- (GdsStructure *) structure;
- (void) debugLog;
- (BOOL) isReference;

+ (GdsElement *) elementFromXMLNode: (GSXMLNode *) xmlNode
                          structure: (GdsStructure *) structure;

- (NSArray *) lookupOutlinePoints;
- (NSRect) lookupBoundingBox;
@end


@interface GdsPrimitiveElement : GdsElement
{
  int _layerNumber;
  int _dataType;
}
- (id) init;
- (int) layerNumber;
- (int) dataType;
- (void) debugLog;
- (void) loadFromXMLNode: (GSXMLNode *) xmlNode;
@end


@interface GdsBoundary : GdsPrimitiveElement
- (NSString *) typeName;
@end


@interface GdsPath : GdsPrimitiveElement
{
  float _width;
  int _pathType;
}
- (id) init;
- (void) loadFromXMLNode: (GSXMLNode *) xmlNode;
- (NSString *) typeName;
- (float) width;
- (int) pathType;
@end


@interface GdsReferenceElement : GdsElement
{
  NSString *_referenceName;
  float _angle;
  float _mag;
  BOOL _reflected;
  GdsStructure *_referenceStructure;
  NSAffineTransform *_transform;
}
- (id) init;
- (void) loadFromXMLNode: (GSXMLNode *) xmlNode;
- (NSString *) referenceName;
- (float) angle;
- (float) mag;
- (BOOL) reflected;
- (NSPoint) origin;
- (NSArray *) basicOutlinePoints;
- (GdsStructure *) referenceStructure;
- (NSAffineTransform *) transform;
@end

@interface GdsSref : GdsReferenceElement
- (NSString *) typeName;
@end

@interface GdsAref : GdsSref
{
  int _rowCount;
  int _columnCount;
  float _rowSpacing;
  float _columnSpacing;
  NSArray *_offsetTransforms;
  NSArray *_transforms;
}
- (id) init;
- (void) loadFromXMLNode: (GSXMLNode *) xmlNode;
- (void) debugLog;

- (NSString *) typeName;
- (int) rowCount;
- (int) columnCount;
- (float) rowSpacing;
- (float) columnSpacing;
- (NSArray *) offsetTransforms;
- (NSArray *) transforms;
@end

// vim: ts=2 sw=2 expandtab filetype=objc 
