// -*- mode: ObjC -*-
#import <Foundation/Foundation.h>
#import "GdsInform.h"
#import "GdsBase.h"

static NSString *InformInspect = @"InformInspect";

@interface GdsInform (Private)
- (void) _handleRecord: (NSData *)record;
+ (GdsElement *) _elementFromStreamRecordType: (int)recType;
@end

@interface NSData (GdsFeel)
- (NSArray *) extractInt2;
- (NSArray *) extractInt4;
- (NSArray *) extractReal8;
- (NSString *) extractAscii;
@end

int
GDSreadInt2(uint8_t *record)
{
  int result;

  result = record[0];
  result <<= 8;
  result += record[1];
  if (result & 0x8000)
    {
      result &= 0x7fff;
      result ^= 0x7fff;
      result += 1;
      result = -result;
    }

  return result;
}

int
GDSreadInt4(uint8_t *record)
{
  int          i;
  unsigned int result;

  for (i = 0, result = 0; i < 4; i++)
    {
      result <<= 8;
      result += record[i];
    }
  if (result & 0x80000000)
    {
      result &= 0x7fffffff;
      result ^= 0x7fffffff;
      result += 1;
      result = -result;
    }

  return result;
}

double
GDSreadReal8(uint8_t *record)
{
  int                i, sign, exponent;
  unsigned long long mantissa_int;
  double             mantissa_float, result;

  sign = record[0] & 0x80;
  exponent = (record[0] & 0x7f) - 64;
  mantissa_int = 0;

  for (i = 1; i < 8; i++)
    {
      mantissa_int <<= 8;
      mantissa_int += record[i];
    }
  mantissa_float = (double) mantissa_int / pow(2, 56);
  result = mantissa_float * pow(16, (float) exponent);
  if (sign)
    result = -result;

  return result;
}

char *
GDSreadString(uint8_t *record, int len)
{
  char *result, string[1024];
  int   i;

  if (len > 1024)
    len = 1024;
  for (i = 0; i < len; i++)
    {
      string[i] = record[i];
      if (record[i] == '\0')
        break;
    }
  string[len] = '\0';

  result = strdup(string);
  return result;
}

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
  NSDebugLLog(InformInspect, @"%@", @"START Inform...");
  _fh = [NSFileHandle fileHandleForReadingAtPath: _filename];
  NSUInteger count = 0;
  while (1)
    {
      NSData *recLenData = [_fh readDataOfLength: 2];
      if ([recLenData length] <= 0)
        {
          NSDebugLLog(InformInspect, @"%@", @ "EMPTY LENGTH found");
          break;
        }
      uint8_t b_len[2];
      bzero(b_len, sizeof(b_len));
      [recLenData getBytes: b_len length: sizeof(b_len)];
      int16_t len = b_len[0] * 256 + b_len[1];
      int16_t len_bytes = len - 2;
      if (len_bytes <= 0)
        break;
      NSDebugLLog(InformInspect, @"[%ld] len_bytes => %d", count, len_bytes);
      NSData *rec = [_fh readDataOfLength: len_bytes];
      if ([rec length] <= 0)
        {
          NSDebugLLog(InformInspect, @"%@", @ "EMPTY REC found");
          break;
        }
      [self _handleRecord: rec];
      count++;
    }
  NSDebugLLog(InformInspect, @"%@", @ "END Inform...");
}
@end

@implementation GdsInform (Private)
- (void) _handleRecord: (NSData *)record
{
  uint8_t buff[2048];
  bzero(buff, sizeof(buff));
  [record getBytes: buff];
  NSDebugLLog(InformInspect, @"record => %@", record);

  NSData *body = [record subdataWithRange: NSMakeRange(2, [record length] - 2)];
  NSDebugLLog(InformInspect, @"body => %@", body);

  NSArray  *dataArray = [NSArray array];
  NSString *dataString = @"";
  switch (buff[1])
    {
    case GDS_INT2:
      {
        dataArray = [body extractInt2];
      }
      break;
    case GDS_INT4:
      {
        dataArray = [body extractInt4];
      }
      break;
    case GDS_REAL8:
      {
        dataArray = [body extractReal8];
      }
      break;
    case GDS_ASCII:
      {
        dataString = [body extractAscii];
      }
    }

  switch (buff[0])
    {
    case BGNLIB:
      {
        ASSIGN(_library, [[GdsLibrary alloc] initWithPath: _filename]);
        NSDebugLLog(@"Record", @"BGNLIB: %@", dataArray);
      }
      break;
    case ENDLIB:
      {
        NSAssert(_structure == nil,
                 @"ENDLIB: Previouse structure not adding library");
      }
      break;
    case LIBNAME:
      {
        NSAssert(_library != nil, @"LIBNAME: Current library not alived");
        NSDebugLLog(@"Record", @"LIBNAME: %@", dataString);
        [_library setName: dataString];
      }
      break;
    case UNITS:
      {
        NSAssert(_library != nil, @"UNITS: Current library not alived");
        NSDebugLLog(@"Record", @"UNITS: %@", dataArray);
        [_library setUserUnit: [[dataArray objectAtIndex: 0] doubleValue]];
        [_library setMeterUnit: [[dataArray objectAtIndex: 1] doubleValue]];
      }
      break;
    case BGNSTR:
      {
        NSAssert(_structure == nil,
                 @"BGNSTR: Previouse structure not adding library");
        ASSIGN(_structure, [[GdsStructure alloc] initWithLibrary: _library]);
        NSDebugLLog(@"Record", @"BGNSTR: %@", dataArray);
      }
      break;
    case ENDSTR:
      {
        NSAssert(_structure != nil, @"ENDSTR: Current structure not alived");
        [_library addStructure: _structure];
        _structure = nil;
      }
      break;
    case STRNAME:
      {
        NSAssert(_structure != nil, @"STRNAME: Current structure not alived");
        NSDebugLLog(@"Record", @"STRNAME: %@", dataString);
        [_structure setName: dataString];
      }
      break;
    case BOUNDARY:
    case PATH:
    case SREF:
    case AREF:
      {
        NSAssert(_element == nil, @"Previouse element not adding structure");
        ASSIGN(_element, [GdsInform _elementFromStreamRecordType: buff[0]]);
      }
      break;
    case ENDEL:
      {
        if (_element != nil)
          {
            [_structure addElement: _element];
            _element = nil;
          }
      }
      break;
    case SNAME:
      {
        NSAssert(_element != nil, @"SNAME: Current element not alived");
        NSDebugLLog(@"Record", @"SNAME: %@", dataString);
        if ([_element isKindOfClass: [GdsSref class]])
          {
            [(GdsSref *) _element setReferenceName: dataString];
          }
      }
      break;
    default:
      // NSDebugLLog (@"Record",  @"Unsupported: %d", buff[0]);
      ;
    }
}

+ (GdsElement *) _elementFromStreamRecordType: (int)recType
{
  GdsElement *newElement = nil;
  Class class = Nil;
  if (recType == BOUNDARY)
    {
      class = [GdsBoundary class];
    }
  if (recType == PATH)
    {
      class = [GdsPath class];
    }
  if (recType == SREF)
    {
      class = [GdsSref class];
    }
  if (recType == AREF)
    {
      class = [GdsAref class];
    }
  if (class != Nil)
    {
      newElement = [[class alloc] init];
    }
  return newElement;
}

@end

@implementation NSData (GdsFeel)

- (NSArray *) extractInt2
{
  NSMutableArray *result = [NSMutableArray array];
  int             len = [self length];
  if (len < 2)
    {
      return result;
    }
  if (len % 2 != 0)
    {
      return result;
    }
  uint8_t record[2048];
  [self getBytes: record];
  int nElements = (len / 2);
  for (int i = 0; i < nElements; i++)
    {
      [result addObject: [NSNumber numberWithShort: (UInt16) GDSreadInt2(
                            &record[i * 2])]];
    }

  return result;
}

- (NSArray *) extractInt4
{
  NSMutableArray *result = [NSMutableArray array];
  int             len = [self length];
  if (len < 4)
    {
      return result;
    }
  if (len % 4 != 0)
    {
      return result;
    }
  uint8_t record[2048];
  [self getBytes: record];
  int nElements = (len / 4);
  for (int i = 0; i < nElements; i++)
    {
      [result addObject: [NSNumber
                          numberWithLong: (UInt32) GDSreadInt4(&record[i * 4])]];
    }
  return result;
}

- (NSArray *) extractReal8
{
  NSMutableArray *result = [NSMutableArray array];
  int             len = [self length];
  if (len < 8)
    {
      return result;
    }
  if (len % 8 != 0)
    {
      return result;
    }
  uint8_t record[2048];
  [self getBytes: record];
  int nElements = (len / 8);
  for (int i = 0; i < nElements; i++)
    {
      [result
       addObject: [NSNumber numberWithDouble: GDSreadReal8(&record[i * 8])]];
    }
  return result;
}

- (NSString *) extractAscii
{
  uint8_t record[2048];
  [self getBytes: record];
  char     *c_str = GDSreadString(record, [self length]);
  NSString *result = [NSString stringWithCString: c_str];
  free(c_str);
  return result;
}

@end
