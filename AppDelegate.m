/**
 
 AppDelegate
 
 @author  王静茜
 @qq      1250020003
 @mail    jancee.wang@qq.com
 */
#import "AppDelegate.h"

@interface AppDelegate (PrivateAPI)

- (void)logError:(NSString *)msg;
- (void)logInfo:(NSString *)msg;
- (void)logMessage:(NSString *)msg;

@end

@interface AppDelegate ()

@property (nonatomic, strong) NSTimer *repeatTimer;

@end


@implementation AppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
}

- (id)init {
  if(self = [super init]) {
    Socket = [[AsyncSocket alloc] initWithDelegate:self];
    
    
    [RACObserve(self, isConnect) subscribeNext:^(id x) {
      BOOL isConnect = [x boolValue];
      [ip_address setEnabled:!isConnect];
      [port       setEnabled:!isConnect];
      [connect    setEnabled:isConnect];
      
      [self.repeatSendButton setEnabled:isConnect];
      [disconnect setEnabled:isConnect];
      [send       setEnabled:isConnect];
    }];
    
    [RACObserve(self.repeatIntervalTextField, integerValue) subscribeNext:^(id x) {
      NSInteger interget = [x integerValue];
      
    }];
    
    
    self.isConnect = @NO;
  }
  return self;
}

//重复发送按钮
- (IBAction)repeatButtonClick:(NSButton *)sender {
  if(![self.isConnect boolValue]) {
    [sender setState:NO];
    return;
  }
  
  if (self.repeatTimer != nil) {
    [self.repeatTimer invalidate];
    self.repeatTimer = nil;
  }
  
  if([sender state]) {
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
}


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
  NSData *data=[[sendmessage stringValue] dataUsingEncoding:NSUTF8StringEncoding];
  [Socket writeData:data withTimeout:-1 tag:0];
}

#pragma mark socket delegate
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
  NSLog(@"%@",host);
}

- (void)onSocket:(AsyncSocket *)sock
     didReadData:(NSData *)data
         withTag:(long)t {
  NSString *str=[NSString stringWithUTF8String:[data bytes]];
  NSLog(@"%@",str);
  //NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
  //NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
  [self logMessage:str];
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


@end
