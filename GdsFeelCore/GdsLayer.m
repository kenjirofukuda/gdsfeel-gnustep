#import <Foundation/Foundation.h>
#import <AppKit/NSColor.h>
#import <GNUstepBase/GSXML.h>
#import "GdsLayer.h"
#import "GdsLibrary.h"

@implementation GdsLayer
- (id) init
{
  self = [super init];
  if (self)
    {
      _selectable = NO;
      _visible = NO;
      _number = 0;
      ASSIGNCOPY(_color, [NSColor whiteColor]);
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_color);
  DEALLOC;
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

- (void) setColor: (NSColor *) color
{
  ASSIGNCOPY(_color, color);
}

- (int) number
{
  return _number;
}

- (void) setNumber: (int) number
{
  _number = number;
}
@end

@implementation GdsLayers
- (instancetype) initWithLibrary: (GdsLibrary *)library;
{
  self = [super init];
  if (self)
    {
      _library = library;
      _layerMap = nil; // lazy
    }
  return self;
}

- (void) dealloc
{
  _library = nil;
  RELEASE(_layerMap);
  DEALLOC;
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

- (NSArray *) colorsThisMany: (NSUInteger)count
                         hue: (CGFloat)hue
                  saturation: (CGFloat)saturation
                  brightness: (CGFloat)brightness;
{
  NSMutableArray *colors = [NSMutableArray array];
  CGFloat step = 1.0 / MAX(count, 1);
  for (int i = 0; i < count; i++)
    {
      [colors addObject: [NSColor colorWithCalibratedHue: hue + (i * step)
                                              saturation: saturation
                                              brightness: brightness
                                                   alpha: 1.0]];
    }
  return colors;
}

- (void) loadLayers
{
  NSLog(@"#loadLayers");
  NSArray *layerNumbers = [_library usedLayerNumbers];
  NSArray *colors = [self colorsThisMany: [layerNumbers count]
                                     hue: 0.0
                              saturation: 0.7
                              brightness: 1.0];
  int index = 0;
  for (NSNumber *number in layerNumbers)
    {
      GdsLayer *newLayer = [[GdsLayer alloc] init];
      [newLayer setNumber: [number intValue]];
      [newLayer setColor: [colors objectAtIndex: index]];
      [_layerMap setValue: newLayer forKey: [number stringValue]];
      index++;
    }
}

@end

// vim: ts=2 sw=2 expandtab
