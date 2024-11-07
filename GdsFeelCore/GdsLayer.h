// -*-ObjC-*-
#import <Foundation/Foundation.h>
#import <AppKit/NSColor.h>
#import <GNUstepBase/GSXML.h>

@class GdsLibrary;

@interface GdsLayer : NSObject
{
  BOOL     _selectable;
  BOOL     _visible;
  int      _number;
  NSColor *_color;
}
- (id) initWithXMLNode: (GSXMLNode *)node;
- (BOOL) selectable;
- (BOOL) visible;
- (NSColor *) color;
- (int) number;
@end

@interface GdsLayers : NSObject
{
  NSString            *_path;
  GdsLibrary          *_library;
  NSMutableDictionary *_layerMap;
}
- (id) initWithPath: (NSString *)path library: (GdsLibrary *)library;
- (GdsLayer *) layerAtNumber: (int)number;
@end

// vim: filetype=objc ts=2 sw=2 expandtab
