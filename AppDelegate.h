/**
 
 AppDelegate
 
 @author  王静茜
 @qq      1250020003
 @mail    jancee.wang@qq.com
 */

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"

@class AsyncSocket;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
  AsyncSocket *Socket;
  
  IBOutlet id ip_address;       //IP地址 Field
  IBOutlet id port;             //断口 Field
  IBOutlet id sendmessage;      //发送 Text
  IBOutlet id receivedmessage;  //接收 Text
  IBOutlet id connect;          //连接Button
  IBOutlet id send;             //发送Button
  IBOutlet id disconnect;       //断开Button
}

@property (nonatomic, strong) NSNumber *isConnect;

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSTextField *connectStatusTextField;
@property (assign) IBOutlet NSComboBox  *historySendDataCB;
@property (assign) IBOutlet NSComboBox  *historyConnectCB;

@property (assign) IBOutlet NSButton    *sendAsciiButton;
@property (assign) IBOutlet NSButton    *sendHexButton;

@property (assign) IBOutlet NSButton    *repeatSendButton;
@property (assign) IBOutlet NSStepper   *repeatIntervalStepper;
@property (assign) IBOutlet NSTextField *repeatIntervalTextField;

@property (assign) IBOutlet NSTextField *rxCountTextField;
@property (assign) IBOutlet NSTextField *txCountField;


- (IBAction)Connect:(id)sender;
- (IBAction)Send:(id)sender;

@end
