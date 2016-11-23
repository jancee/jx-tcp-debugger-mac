//
//  SpModel.m
//  JanceeTCPDebuggerTool
//
//  Created by jancee wang on 2016/11/23.
//
//

#import "SpModel.h"

@implementation SpModel

+ (void)addConnectHistoryWithIp:(NSString*)ip port:(NSString*)port {
  NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
  NSMutableArray *getArray = [[SpModel getConnectHistory] mutableCopy];
  [getArray addObject:@{
                        @"ip"   : ip,
                        @"port" : port
                        }];
  [userDef setObject:[getArray copy] forKey:@"ConnectHistory"];
  [userDef synchronize];
}

+ (NSArray*)getConnectHistory {
  NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
  NSArray *returnArray = [userDef arrayForKey:@"ConnectHistory"];
  if(returnArray == nil) {
    returnArray = [[NSArray alloc] init];
  }
  return returnArray;
}

@end
