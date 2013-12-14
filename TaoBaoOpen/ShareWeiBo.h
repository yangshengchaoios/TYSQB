//
//  ShareWeiBo.h
//  webViewDemo
//
//  Created by apple on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBBase.h"

@interface ShareWeiBo : NSObject<UIWebViewDelegate>
{
    IBOutlet UIWebView *_webView;
    
    NSString *sinaWeiBoText;
    NSString *txWeiBoText;
    BOOL sendWeiBo;
}

+ (ShareWeiBo *)mainShare;
/*
 * 在返回url中提取指定参数的值
 */
+ (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle;
//加密
-(NSString*)encryption:(NSString*)password:(NSString*)Text;
//解密
-(NSString*)Decrypt:(NSString*)password:(NSString*)Text;

/*
    Sina 新浪Oauth2.0需要先获取code，然后使用code换取access_token
*/
//获取code
-(void)startSinaAuthorize:(UIWebView *)webView;
//使用code换取access_token
-(BOOL)startSinaAccessWithVerifier_V2:(NSString *)_ver;
//发送微博信息
-(void)sendSinaText:(NSString*)Text;


/*
    TX 腾讯Oauth2.0直接使用webView获取access_token
*/
//获取token值
-(void)startTXAuthorize:(UIWebView *)webView;
//发腾讯微博
-(void)sendTxText:(NSString *)Text;

@end
