// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import <GNUstepBase/GSXML.h>
#import "GdsElement.h"

@class GdsStructure;

@interface GdsElement (XML)
- (id) initWithXMLNode: (GSXMLNode *)xmlNode structure: (GdsStructure *)structure;

- (void) loadFromXMLNode: (GSXMLNode *)xmlNode;
+ (GdsElement *) elementFromXMLNode: (GSXMLNode *)xmlNode
                          structure: (GdsStructure *)structure;

@end

@interface GdsPrimitiveElement (XML)
- (void) loadFromXMLNode: (GSXMLNode *)xmlNode;
@end

@interface GdsPath (XML)
- (void) loadFromXMLNode: (GSXMLNode *)xmlNode;
@end

@interface GdsReferenceElement (XML)
- (void) loadFromXMLNode: (GSXMLNode *)xmlNode;
@end

@interface GdsAref (XML)
- (void) loadFromXMLNode: (GSXMLNode *)xmlNode;
@end

// vim: ts=2 sw=2 expandtab filetype=objc
