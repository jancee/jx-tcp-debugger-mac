
#import <Foundation/Foundation.h>

@interface NSData(Hex)
- (NSString *)hexadecimalString;
+ (NSData *)dataWithHexString:(NSString *)hexstring;
@end
