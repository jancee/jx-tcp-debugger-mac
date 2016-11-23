/**
 
 AppDelegate
 
 @author  王静茜
 @qq      1250020003
 @mail    jancee.wang@qq.com
 */
#import "AppDelegate.h"
#import "SpModel.h"

@interface AppDelegate (PrivateAPI)

- (void)logError:(NSString *)msg;
- (void)logInfo:(NSString *)msg;
- (void)logMessage:(NSString *)msg;

@end

@interface AppDelegate ()

@property (nonatomic, strong) NSTimer *repeatTimer;

@property (nonatomic, strong) NSArray *connectHistoryArray;

@end


@implementation AppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
}

- (id)init {
  if(self = [super init]) {
    Socket = [[AsyncSocket alloc] initWithDelegate:self];
    
    //显示历史连接
    self.connectHistoryArray = [SpModel getConnectHistory];
    NSLog(@"找到%@",self.connectHistoryArray);
    [self.historyConnectCB reloadData];
    
    [RACObserve(self, isConnect) subscribeNext:^(id x) {
      BOOL isConnect = [x boolValue];
      [ip_address setEnabled:!isConnect];
      [port       setEnabled:!isConnect];
      [connect    setEnabled:!isConnect];
      [self.historyConnectCB setEnabled:!isConnect];
      
      isConnect ? : [self.repeatIntervalTextField setIntegerValue:0];
      isConnect ? : [self.repeatSendButton setState:NO];
      [self.repeatIntervalTextField setEnabled:isConnect];
      [self.repeatIntervalStepper setEnabled:isConnect];
      [self.repeatSendButton setEnabled:isConnect];
      [disconnect setEnabled:isConnect];
      [send       setEnabled:isConnect];
      
      [self resetRepeatTimer];
    }];
    
    
    [self.repeatIntervalTextField.rac_textSignal subscribeNext:^(id x) {
      NSLog(@"text变化");
    }];
    
    self.isConnect = @NO;
  }
  return self;
}






#pragma mark - base
//显示、发送格式变化
- (IBAction)sendDataFormatClick:(NSButton *)sender {
  if(sender == self.sendAsciiButton) {
    [self.sendHexButton setState:NO];
  } else {
    [self.sendAsciiButton setState:NO];
  }
}
- (IBAction)receiveDataFormatClick:(NSButton *)sender {
  if(sender == self.receiveAsciiButton) {
    [self.receiveHexButton setState:NO];
  } else {
    [self.receiveAsciiButton setState:NO];
  }
}

//重复时间变化
- (void)controlTextDidChange:(NSNotification *)obj {
  [self resetRepeatTimer];
}
- (IBAction)repeatIntervalStepperClick:(NSStepper *)sender {
  static NSInteger beforeValue = 0;
  if(self.repeatIntervalTextField.integerValue == NSNotFound)
    return;
  [self.repeatIntervalTextField setIntegerValue:
   self.repeatIntervalTextField.integerValue + (([sender integerValue] > beforeValue) ? 1 : (self.repeatIntervalTextField.integerValue <= 0 ? 0 : -1))];
  beforeValue = [sender integerValue];
  [self resetRepeatTimer];
}

//重复发送按钮
- (IBAction)repeatButtonClick:(NSButton *)sender {
  if(![self.isConnect boolValue]) {
    [sender setState:NO];
    return;
  }
  
  [self resetRepeatTimer];
}

//重设重复定时器
- (void)resetRepeatTimer {
  if (self.repeatTimer != nil) {
    [self.repeatTimer invalidate];
    self.repeatTimer = nil;
  }
  if([self.repeatSendButton state]) {
    CGFloat interval = self.repeatIntervalTextField.integerValue / 1000.0f;
    self.repeatTimer =
    [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:self
                                   selector:@selector(repeatSendData:)
                                   userInfo:nil
                                    repeats:YES];
  }
}
- (void)repeatSendData:(NSTimer*)t {
  [self sendData];
}


//接收数据窗口
- (void)scrollToBottom {
  NSScrollView *scrollView = [receivedmessage enclosingScrollView];
  NSPoint newScrollOrigin;
  
  if ([[scrollView documentView] isFlipped])
    newScrollOrigin = NSMakePoint(0.0, NSMaxY([[scrollView documentView] frame]));
  else
    newScrollOrigin = NSMakePoint(0.0, 0.0);
  
  [[scrollView documentView] scrollPoint:newScrollOrigin];
}
- (void)logMessage:(NSString *)msg {
  NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
  
  NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
  [attributes setObject:[NSColor blackColor]
                 forKey:NSForegroundColorAttributeName];
  
  NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
  [as autorelease];
  
  [[receivedmessage textStorage] appendAttributedString:as];
  [self scrollToBottom];
}


/**
 连接按钮
 */
- (IBAction)Connect:(id)sender {
  int bind = [port intValue];
  
  if(bind < 0 || bind > 65535) {
    bind = 0;
  }
  NSError *error = nil;
  
  if (![self.isConnect boolValue]) {
    self.isConnect = @YES;
    [Socket connectToHost:[ip_address stringValue] onPort:bind error:&error];
  }
}


/**
 断开按钮
 */
- (IBAction)disconnect:(id)sender {
  if([self.isConnect boolValue]) {
    self.isConnect = @NO;
    [Socket disconnect];
  }
}
/**
 发送按钮
 */
- (IBAction)Send:(id)sender {
  NSLog(@"%@",[sendmessage stringValue]);
  [self sendData];
}

- (void)sendData {
  //统计总tx字节
  [self.txCountField setStringValue:[[NSString alloc] initWithFormat:@"%lu Bytes",(self.txCountField.integerValue + [[sendmessage stringValue] byteLength])]];
  
  //发送
  NSData *data = [[sendmessage stringValue] dataUsingEncoding:NSUTF8StringEncoding];
  [Socket writeData:data withTimeout:-1 tag:0];
}


#pragma mark - socket delegate
- (void)onSocket:(AsyncSocket *)sock
       didSecure:(BOOL)flag {
  if(flag)
    NSLog(@"onSocket:%p didSecure:YES", sock);
  else
    NSLog(@"onSocket:%p didSecure:NO", sock);
}

- (void)onSocket:(AsyncSocket *)sock
willDisconnectWithError:(NSError *)err {
  NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock    //掉线处理
{
  self.isConnect = @NO;
  [self.connectStatusTextField setStringValue:@"连接断开"];
  NSLog(@"onSocketDidDisconnect:%p", sock);
}

- (void)onSocket:(AsyncSocket *)sock
didAcceptNewSocket:(AsyncSocket *)newSocket {
  NSLog(@"%@",@"didAcceptNewSocket");
}

- (void)onSocket:(AsyncSocket *)sock
didConnectToHost:(NSString *)host
            port:(UInt16)port {
  self.isConnect = @YES;
  [self.connectStatusTextField setStringValue:@"已连接"];
  [Socket readDataWithTimeout:-1 tag:0];
  NSLog(@"didConnectToHost ip -> %@",host);
  
  //添加历史
  self.connectHistoryArray = [SpModel getConnectHistory];
  BOOL find = NO;
  for (NSDictionary *forDict in self.connectHistoryArray) {
    if([forDict[@"ip"] isEqualToString:[ip_address stringValue]] &&
       [forDict[@"port"] isEqualToString:[[NSString alloc] initWithFormat:@"%hu",port]]) {
      find = YES;
      break;
    }
  }
  if(!find) {
    [SpModel addConnectHistoryWithIp:[ip_address stringValue]
                                port:[[NSString alloc] initWithFormat:@"%hu",port]];
    [self.historyConnectCB reloadData];
  }
}

- (void)onSocket:(AsyncSocket *)sock
     didReadData:(NSData *)data
         withTag:(long)t {
  NSString *str = [NSString stringWithUTF8String:[data bytes]];
  NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
  NSString *msg = [strData hexadecimalString];
  
  //统计总rx字节
  [self.rxCountTextField setStringValue:[[NSString alloc] initWithFormat:@"%lu Bytes",(self.rxCountTextField.integerValue + [str byteLength])]];
  
  //显示到窗口
  [self logMessage:[self.receiveAsciiButton state] ? str : msg];
  [Socket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock
didReadPartialDataOfLength:(CFIndex)partialLength
             tag:(long)t {
  NSLog(@"%@",@"didReadPartialDataOfLength");
}

- (void)onSocket:(AsyncSocket *)sock
didWriteDataWithTag:(long)t {
  NSLog(@"%@",@"didWriteDataWithTag");
}

- (void)onOpenStreamsAndReturnResult:(BOOL)success {
  if(!success) {
    [self.connectStatusTextField setStringValue:@"连接失败"];
    self.isConnect = @NO;
  }
}


#pragma mark - combox delegate
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
  if(notification.object == self.historyConnectCB) {
    self.connectHistoryArray = [SpModel getConnectHistory];
    NSDictionary *getDict = [self.connectHistoryArray objectAtIndex:[self.historyConnectCB indexOfSelectedItem]];
    [ip_address setStringValue:getDict[@"ip"]];
    [port       setStringValue:getDict[@"port"]];
  } else if(notification.object == self.historySendDataCB) {
  }
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
  NSDictionary *getDict = [self.connectHistoryArray objectAtIndex:index];
  return [[NSString alloc] initWithFormat:@"%@:%@",getDict[@"ip"],getDict[@"port"]];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
  return [self.connectHistoryArray count];
}
@end
