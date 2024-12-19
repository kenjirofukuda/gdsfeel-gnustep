// -*-ObjC-*-
#import <Foundation/Foundation.h>
#import <AppKit/NSColor.h>
#import <GNUstepBase/GSXML.h>
#import "GdsLayer.h"

@interface GdsLayer (XML)
- (id) initWithXMLNode: (GSXMLNode *)node;
@end

@interface GdsLayersXML : GdsLayers
{
  NSString *_xmlPath;
}
- (instancetype) initWithLibrary: (GdsLibrary *)library xmlPath: (NSString *)path;
- (void) dealloc;
- (void) loadLayers;
@end

// vim: filetype=objc ts=2 sw=2 expandtab
