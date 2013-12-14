//  程序在运行过程中的共享域
//  Singleton.m

//
//  Created by shengchao yang on 12-3-7.
//  Copyright (c)  All rights reserved.
//

#import "Singleton.h"
#import "DataBaseAccess.h"
#import "NSString+Additions.h"
#import "Common.h"
@interface Singleton(Private)
    - (void)stopMusic;
-(void)openUDPServer;
@end


@implementation Singleton
@synthesize udpSocket;
@synthesize musicPlayer;
@synthesize dicConfigTxt;

@synthesize hotelName;
@synthesize ipadUdid;
@synthesize downloadUrl;
@synthesize supportLangs;
@synthesize langsArray;
@synthesize language;
@synthesize translate;
@synthesize isAnimating;
@synthesize popController;
@synthesize arrayHistory,arrayItem,arrayItemIndex,searchKeyword,totalResults,resultIndex;
@synthesize wbText,wbType,wbLongUrl;

//singleton设计模式
static Singleton *instance;
+(Singleton *)sharedSingleton {
	@synchronized(self)
	{
		if (instance == nil) {
            instance = [[Singleton alloc] init];
		}
		return instance;
	}
}
-(void) setIsAnimating:(BOOL)isAnimating1{
    isAnimating = isAnimating1;
    if (isAnimating1 == NO) {
        MyNSLog(@"isAnimating1 == NO");
    }
}
- (void)playMusic:(NSString *) musicPath{    
	if (self.musicPlayer != nil) {
        if (self.musicPlayer.isPlaying) {
            [self.musicPlayer stop];
        }
	}    
    AVAudioPlayer * soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:musicPath] error:nil];
    self.musicPlayer = soundPlayer;
    [soundPlayer release];
    [self.musicPlayer prepareToPlay];
	self.musicPlayer.numberOfLoops = 0;
	self.musicPlayer.volume = 1;
    self.musicPlayer.delegate = self;
    self.musicPlayer.meteringEnabled = YES;
	
    [self.musicPlayer play];
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {//铃声播放完成后，自动调用的委托方法
	[self stopMusic];
}
- (void)stopMusic{
    if (self.musicPlayer && self.musicPlayer.isPlaying) {
        [self.musicPlayer stop];
	}
}
 

-(void)initArrayHistory{
    if (self.arrayHistory != nil && [self.arrayHistory count]>0) {
        [self.arrayHistory removeAllObjects];
    }
    
    self.arrayHistory = [DataBaseAccess selectMenuHistory:@"select * from history order by hisId desc"];
}
-(void)initDicConfigTxt{
    if (self.dicConfigTxt != nil && [self.dicConfigTxt count]>0) {
        [self.dicConfigTxt removeAllObjects];
    }
    self.dicConfigTxt = [DataBaseAccess selectConfigTxt];
}
-(void)updateConfigTxtKey:(NSString *)txtKey withValue:(NSString *)txtValue {
    if (self.dicConfigTxt != nil && [self.dicConfigTxt objectForKey:txtKey]) {
        [self.dicConfigTxt setObject:txtValue forKey:txtKey];
        [DataBaseAccess Update:[NSString stringWithFormat:@"update ConfigTxt set txtValue='%@' where txtKey='%@'",txtValue,txtKey]];
    }
}
//删除新浪授权信息
-(void)removeSinaRestore{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sina_access_tokenV2"];
}
//删除腾讯授权信息
-(void)removeTxRestore{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TX_access_tokenV2"];
}




/////////////////////////UDP//////////////
#pragma - mark UDP Delegate Methods
//建立基于UDP的Socket连接
-(void)openUDPServer {
    if (self.udpSocket == nil) {
        MyNSLog(@"udpSocket is nil!");
        //初始化udp
        AsyncUdpSocket *tempSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
        self.udpSocket=tempSocket;
        [tempSocket release];
        //绑定端口
        NSError *error = nil;
        [self.udpSocket bindToPort:[[self.dicConfigTxt objectForKey:@"localport"] intValue] error:&error];
        
        //启动接收线程
        [self.udpSocket receiveWithTimeout:-1 tag:0];
    }else {
        MyNSLog(@"udpSocket is not nil!");
    }	
}
//发送一组字符串命令
-(void)sendCommands:(NSMutableArray *)commands{
    //方案一
    NSDictionary *infos = [NSDictionary dictionaryWithObjectsAndKeys:commands, @"commands",nil];
    postNWithInfos(@"SysMsg_RootView_showWithLabel", nil, infos);
    
    //方案二
//    for (int i=0; i<commands.count; i++) {
//        NSString *command = (NSString *)[commands objectAtIndex:i];
//        MyNSLog(@"sending command = %@",command);
//        [self sendCommand:command];//发送一条指令
//    }
}
//发送字符串指令
-(void)sendCommand:(NSString *)cmdStr{
    NSArray *cmdArray = [cmdStr componentsSeparatedByString: @" "];//分解为Byte[]
    NSInteger cmdLen = cmdArray.count;
    MyNSLog(@"cmdLen = %d", cmdLen);
    Byte header = 0xF1;
    Byte length = cmdLen + 4;
    Byte resp = 0x02;//应答字节 固定
    Byte xor = 0x00 ^ length;//初始化校验
    Byte tail = 0xF4;    
    Byte cmdByte[cmdLen + 5];
    cmdByte[0] = header;
    cmdByte[1] = length;
    cmdByte[cmdLen + 5-1] = tail;
    
    for (int i=0;i<cmdArray.count;i++) {
        NSString *tempCmd = (NSString *)[cmdArray objectAtIndex:i];
        int tempRow1=0;
        sscanf([tempCmd cStringUsingEncoding:NSASCIIStringEncoding], "%x", &tempRow1);
        cmdByte[2+i] = tempRow1;
        xor = xor ^ tempRow1;//异或校验
    }   
    xor = xor ^ resp;//结束校验
    cmdByte[cmdLen + 5-2] = xor;
    cmdByte[cmdLen + 5-3] = resp;
    //发送
    [self sendUDPByte:cmdByte length:cmdLen+5];
}
//发送字符串信息
-(void)sendMSG:(NSString *)msgStr{
    [self openUDPServer];
    //开始发送
	BOOL res = [self.udpSocket sendData:[msgStr dataUsingEncoding:NSUTF8StringEncoding]
								 toHost:[self.dicConfigTxt objectForKey:@"serverip"]
								   port:[[self.dicConfigTxt objectForKey:@"serverport"] intValue]
							withTimeout:-1
                                    tag:0];
    
   	if (!res) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
														message:@"发送失败"
													   delegate:self
											  cancelButtonTitle:@"取消"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}
//通过UDP,发送字节数组
-(void)sendUDPByte:(Byte[])cmd length:(NSInteger)len{
    [self openUDPServer];
    MyNSLog(@"serverip=%@,serverport=%@,localport=%@",[self.dicConfigTxt objectForKey:@"serverip"],[self.dicConfigTxt objectForKey:@"serverport"],[self.dicConfigTxt objectForKey:@"localport"]);    
    NSData *sendData = [[NSData alloc] initWithBytes:cmd length:len];
    for (int i=0; i<len;i++) {
        MyNSLog(@"byte[%d]=%d",i,cmd[i]);
    }
    //开始发送
	BOOL res = [self.udpSocket sendData:sendData
								 toHost:[self.dicConfigTxt objectForKey:@"serverip"]
								   port:[[self.dicConfigTxt objectForKey:@"serverport"] intValue]
							withTimeout:-1
                                    tag:0];
    
   	if (!res) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
														message:@"发送失败"
													   delegate:self
											  cancelButtonTitle:@"取消"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    MyNSLog(@"clientIPEndPoint:%@:%d",host,port);
	NSString *info=[[[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding] autorelease];
    MyNSLog(@"接收数据->>%@",info);
    [self.udpSocket receiveWithTimeout:-1 tag:0];//必须留下！实现循环监听
	//已经处理完毕
	return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
	//无法发送时,返回的异常提示信息
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
	//无法接收时，返回异常提示信息
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

 
////////////对象初始化///////
-(id) init{
	self = [super init];
	if (self) {
        isAnimating = NO;
        supportLangs = @"zh-Hans#en";//支持的多语言 最多七种：zh-Hans#zh-Hant#en#ja#ko#ru#fr
        langsArray = [NSMutableArray new];
        arrayItem = [NSMutableArray new];
	}
	return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc{
    [musicPlayer release];
    musicPlayer = nil;
    [dicConfigTxt release];
    dicConfigTxt = nil;
    [hotelName release];
    hotelName = nil;
    [ipadUdid release];
    ipadUdid = nil;
    [downloadUrl release];
    downloadUrl = nil;
    [supportLangs release];
    supportLangs = nil;
    [langsArray release];
    langsArray = nil;
    [language release];
    language = nil;
    [translate release];
    translate = nil;
    [popController release];
    popController = nil;
    
    [arrayHistory release];
    arrayHistory = nil; 
    [arrayItem release];
    arrayItem = nil;
    [searchKeyword release];
    searchKeyword = nil;
    
    [wbText release],wbText=nil;
    [wbType release],wbType=nil;
    [wbLongUrl release],wbLongUrl=nil;
    [super dealloc];
}
@end
