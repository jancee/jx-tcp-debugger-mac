//
//  NSString+byteLength.m
//  DXYLED_TELINK
//
//  Created by jancee wang on 16/7/27.
//  Copyright © 2016年 dxytech. All rights reserved.
//

//用于获取字节长度

#import "NSString+byteLength.h"

@implementation NSString (byteLength)

- (NSUInteger)byteLength {
  NSUInteger strlength = 0;
  char* p = (char*)[self cStringUsingEncoding:NSUTF8StringEncoding];
  for (int i = 0 ; i < [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding] ;i++) {
    p++;
    strlength++;
  }
  return strlength;
}

@end
