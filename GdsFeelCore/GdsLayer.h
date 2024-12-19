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
- (id) init;
- (BOOL) selectable;
- (BOOL) visible;
- (NSColor *) color;
- (void) setColor: (NSColor *) color;
- (int) number;
- (void) setNumber: (int) number;
@end

@interface GdsLayers : NSObject
{
  GdsLibrary          *_library;
  NSMutableDictionary *_layerMap;
}
- (instancetype) initWithLibrary: (GdsLibrary *)library;
- (GdsLayer *) layerAtNumber: (int)number;
- (void) loadLayers;
@end

// vim: filetype=objc ts=2 sw=2 expandtab
