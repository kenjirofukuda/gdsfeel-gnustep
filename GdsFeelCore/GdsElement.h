// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>

@class GdsStructure;

@interface GdsElement : NSObject
{
  int           _keyNumber;
  NSArray      *_coords;
  GdsStructure *_structure;
  NSValue      *_boundingBox;
  NSArray      *_outlinePoints;
  NSMutableDictionary *_extension;
}
- (id) init;
- (void) dealloc;

- (NSArray *) coords;
- (void) setCoords: (NSArray *)points;
- (NSArray *) vertices;
- (NSArray *) outlinePoints;
- (int) keyNumber;
- (NSRect) boundingBox;
- (NSString *) typeName;
- (GdsStructure *) structure;
- (void) setStructure: (GdsStructure *)structure;
- (void) debugLog;
- (BOOL) isReference;

- (NSArray *) lookupOutlinePoints;
- (NSRect) lookupBoundingBox;
- (NSString *) recordDescription;

- (NSMutableDictionary *) extension;
@end

@interface GdsPrimitiveElement : GdsElement
{
  int _layerNumber;
  int _dataType;
}
- (id) init;
- (int) layerNumber;
- (void) setLayerNumber: (int) layerNumber;
- (int) dataType;
- (void) setDataType: (int) dataType;
- (void) debugLog;
@end

@interface GdsBoundary : GdsPrimitiveElement
- (NSString *) typeName;
@end

@interface GdsPath : GdsPrimitiveElement
{
  float _width;
  int   _pathType;
}
- (id) init;
- (NSString *) typeName;
- (float) width;
- (void) setWidth: (float)width;
- (int) pathType;
@end

@interface GdsReferenceElement : GdsElement
{
  NSString          *_referenceName;
  float              _angle;
  float              _mag;
  BOOL               _reflected;
  BOOL               _isAbsMag;
  BOOL               _isAbsAngle;
  GdsStructure      *_referenceStructure;
  NSAffineTransform *_transform;
}
- (id) init;
- (NSString *) referenceName;
- (void) setReferenceName: (NSString *)name;
- (float) angle;
- (void) setAngle: (float)angle;
- (BOOL) isAbsAngle;
- (void) setAbsAngle: (BOOL)absolute;
- (float) mag;
- (void) setMag: (float)magnify;
- (BOOL) isAbsMag;
- (void) setAbsMag: (BOOL)absolute;
- (BOOL) reflected;
- (void) setReflected: (BOOL)reflected;
- (NSPoint) origin;
- (void) setOrigin: (NSPoint)origin;
- (NSArray *) basicOutlinePoints;
- (GdsStructure *) referenceStructure;
- (NSAffineTransform *) transform;
@end

@interface GdsSref : GdsReferenceElement
- (NSString *) typeName;
@end

@interface GdsAref : GdsSref
{
  int      _rowCount;
  int      _columnCount;
  float    _rowSpacing;
  float    _columnSpacing;
  NSArray *_offsetTransforms;
  NSArray *_transforms;
}
- (id) init;
- (void) debugLog;

- (NSString *) typeName;
- (int) rowCount;
- (void) setRowCount: (int)count;
- (int) columnCount;
- (void) setColumnCount: (int)count;
- (float) rowSpacing;
- (void) setRowSpacing: (float)spacing;
- (float) columnSpacing;
- (void) setColumnSpacing: (float)spacing;
- (NSArray *) offsetTransforms;
- (NSArray *) transforms;
@end

// vim: ts=2 sw=2 expandtab filetype=objc
