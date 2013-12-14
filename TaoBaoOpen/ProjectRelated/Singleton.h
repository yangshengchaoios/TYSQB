//  程序在运行过程中的共享域
//  Singleton.h

//
//  Created by shengchao yang on 12-3-7.
//  Copyright (c)  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AVFoundation/AVFoundation.h"
#import "AudioToolbox/AudioToolbox.h"
#import "AsyncUdpSocket.h"

@interface Singleton : NSObject<AVAudioPlayerDelegate>{
    NSString *hotelName;
    NSString *ipadUdid;
    NSString *downloadUrl;
    NSString *supportLangs;
    BOOL isUpdate;
    BOOL isOEMDisplay;
    
    NSString *language;
    NSDictionary *translate;            //图文翻译用字典
    BOOL isAnimating;                   //动画是否正在执行中
    BOOL isViewRemoveFromLeft;          //从左边退出
    UIPopoverController *popController;
}
+(Singleton *)sharedSingleton;
@property (nonatomic, retain) AsyncUdpSocket *udpSocket;
@property (nonatomic, retain) AVAudioPlayer *musicPlayer;
@property (nonatomic, retain) NSMutableDictionary *dicConfigTxt;

@property (nonatomic, retain) NSString *hotelName;
@property (nonatomic, retain) NSString *ipadUdid;
@property (nonatomic, retain) NSString *downloadUrl;
@property (nonatomic, retain) NSString *supportLangs;
@property (nonatomic, retain) NSMutableArray * langsArray;
@property (nonatomic, assign) BOOL isAnimating; 
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSDictionary *translate;         // 图文翻译用字典
@property (nonatomic, retain) UIPopoverController *popController;

@property (nonatomic, retain) NSMutableArray * arrayHistory;
@property (nonatomic, retain) NSMutableArray * arrayItem;//淘宝客商品列表
@property (nonatomic, assign) NSInteger arrayItemIndex;//
@property (nonatomic, retain) NSString *searchKeyword;//点击历史搜索关键词
@property (nonatomic, assign) NSInteger totalResults;//当前查询符合条件的个数
@property (nonatomic, assign) NSInteger resultIndex;//当前结果页数

@property (nonatomic, retain) NSString *wbType;//微博类型：sina tx
@property (nonatomic, retain) NSString *wbText;//微博正文
@property (nonatomic, retain) NSString *wbLongUrl;//有待转换的长链接

//方法
-(void)playMusic:(NSString *) musicPath;
-(void)initArrayHistory;
-(void)initDicConfigTxt;
-(void)updateConfigTxtKey:(NSString *)txtKey withValue:(NSString *)txtValue;

-(void)removeSinaRestore;
-(void)removeTxRestore;
@end
