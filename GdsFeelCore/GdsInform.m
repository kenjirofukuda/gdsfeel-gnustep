// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import "GdsInform.h"

@implementation GdsInform
- (instancetype) initWithFilename: (NSString *)filename
{
  self = [super init];
  if (self != nil)
    {
      ASSIGNCOPY(_filename, filename);
    }
  return self;
}

- (void) run
{
  NSLog(@"%@", @"START Inform...");
  _fh = [NSFileHandle fileHandleForReadingAtPath: _filename];
  NSUInteger count = 0;
  while (1)
    {
      NSData *recLenData = [_fh readDataOfLength: 2];
      if ([recLenData length] <= 0)
        {
          NSLog(@"%@", @ "EMPTY LENGTH found");
          break;
        }
      uint8_t b_len[2];
      bzero(b_len, sizeof(b_len));
      [recLenData getBytes: b_len length: sizeof(b_len)];
      int16_t len = b_len[0] * 256 + b_len[1];
      int16_t len_bytes = len - 2;
      if (len_bytes <= 0)
        break;
      NSLog(@"[%ld] len_bytes => %d", count, len_bytes);
      NSData *rec = [_fh readDataOfLength: len_bytes];
      if ([rec length] <= 0)
        {
          NSLog(@"%@", @ "EMPTY REC found");
          break;
        }
      NSLog(@"rec => %@", rec);
      count++;
    }
  NSLog(@"%@", @ "END Inform...");
}
@end
