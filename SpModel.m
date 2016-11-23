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
  [getArray insertObject:@{
                           @"ip"   : ip,
                           @"port" : port
                           }
                 atIndex:0];
  [userDef setObject:[getArray copy] forKey:@"ConnectHistory"];
  [userDef synchronize];
}

+ (NSArray<NSDictionary*>*)getConnectHistory {
  NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
  NSArray *returnArray = [userDef arrayForKey:@"ConnectHistory"];
  if(returnArray == nil) {
    returnArray = [[NSArray alloc] init];
  }
  return returnArray;
}



+ (void)addSendDataHistoryWithData:(NSString*)string {
  NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
  NSMutableArray *getArray = [[SpModel getSendDataHistory] mutableCopy];
  [getArray insertObject:string atIndex:0];
  [userDef setObject:[getArray copy] forKey:@"SendDataHistory"];
  [userDef synchronize];
}

+ (NSArray<NSString*>*)getSendDataHistory {
  NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
  NSArray *returnArray = [userDef arrayForKey:@"SendDataHistory"];
  if(returnArray == nil) {
    returnArray = [[NSArray alloc] init];
  }
  return returnArray;
}

@end
