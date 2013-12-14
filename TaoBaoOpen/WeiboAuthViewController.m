//
//  WeiboAuthViewController.m
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WeiboAuthViewController.h"
#import "ShareWeiBo.h"
#import "Singleton.h"

@interface WeiboAuthViewController ()

@end

@implementation WeiboAuthViewController
@synthesize webView;
@synthesize indicatorProcessing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([AppSession.wbType isEqualToString:@"sina"]){
        self.navigationItem.title = @"新浪微博授权";
        [[ShareWeiBo mainShare] startSinaAuthorize:webView];
    }else {
        self.navigationItem.title = @"腾讯微博授权";
        [[ShareWeiBo mainShare] startTXAuthorize:webView];
    }
    
    indicatorProcessing.hidden=NO;
    [indicatorProcessing startAnimating];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setIndicatorProcessing:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelOauth:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];//退出登陆页面
}

#pragma WebView
/*
 * 当前网页视图被指示载入内容时得到通知，返回yes开始进行加载
 */
- (BOOL) webView:(UIWebView *)_webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL* url = request.URL;
    MyNSLog(@"requesturl=%@",url);
    
    //新浪微博
    if ([AppSession.wbType isEqualToString:@"sina"]) {
        NSRange start = [[url absoluteString] rangeOfString:@"code="];
        if (start.location != NSNotFound) {
            NSString *code = [[url query] substringWithRange:NSMakeRange([[url query] length]-32, 32)];
            if ([[ShareWeiBo mainShare] startSinaAccessWithVerifier_V2:code]) {
                MyNSLog(@"新浪微博 授权成功！");               
                [self.navigationController dismissModalViewControllerAnimated:YES];//退出登陆页面
                
                //发消息转到发微博界面
                postN(@"SysMsg_ListViewController_pushSendWBView");
            }            
            return NO;
        }else {
            
        }        
    }else{//腾讯微博
        NSRange start = [[url absoluteString] rangeOfString:oauth2TokenKey];
        //如果找到tokenkey,就获取其他key的value值
        if (start.location != NSNotFound)        {
            NSString *accessToken = [ShareWeiBo getStringFromUrl:[url absoluteString] needle:oauth2TokenKey];
            NSString *openid = [ShareWeiBo getStringFromUrl:[url absoluteString] needle:oauth2OpenidKey];
            NSString *openkey = [ShareWeiBo getStringFromUrl:[url absoluteString] needle:oauth2OpenkeyKey];
            NSString *expireIn = [ShareWeiBo getStringFromUrl:[url absoluteString] needle:oauth2ExpireInKey];            
            NSLog(@"token is %@, openid is %@, expireTime is %@", accessToken, openid, expireIn);
            if ((accessToken == (NSString *) [NSNull null]) || (accessToken.length == 0) 
                || (openid == (NSString *) [NSNull null]) || (openkey.length == 0) 
                || (openkey == (NSString *) [NSNull null]) || (openid.length == 0)) {
                //[_OpenSdkOauth oauthDidFail:InWebView success:YES netNotWork:NO];
                MyNSLog(@"oauthDidFail");
            }
            else {
                //记录获取到的用户信息
                NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
                [info setValue:[[ShareWeiBo mainShare] encryption:MyPWDKey :accessToken]  forKey:@"TX_access_tokenV2"];
                [info setValue:openid forKey:@"TX_idV2"];
                [info setValue:openkey forKey:@"TX_keyV2"];
                [info setValue:expireIn forKey:@"TX_expireInV2"];
                [info synchronize];
                
                
                MyNSLog(@"腾讯微博 授权成功！");
                [self.navigationController dismissModalViewControllerAnimated:YES];//退出登陆页面
                
                //发消息转到发微博界面
                postN(@"SysMsg_ListViewController_pushSendWBView");
            }            
            return NO;
        }else{
            start = [[url absoluteString] rangeOfString:@"code="];
            if (start.location != NSNotFound) {
                //[_OpenSdkOauth refuseOauth:url];
            }
        }
    }
    return YES;
}

/*
 * 当网页视图结束加载一个请求后得到通知
 */
- (void) webViewDidFinishLoad:(UIWebView *)_webView {
    NSString *url = _webView.request.URL.absoluteString;
    NSLog(@"web view finish load URL %@", url);
    
    [indicatorProcessing stopAnimating];
    indicatorProcessing.hidden=YES;
}
/*
 * 页面加载失败时得到通知，可根据不同的错误类型反馈给用户不同的信息
 */
- (void)webView:(UIWebView *)_webView didFailLoadWithError:(NSError *)error {
    NSLog(@"no network:errcode is %d, domain is %@", error.code, error.domain);
    
}


- (void)dealloc {
    [webView release];
    [indicatorProcessing release];
    [super dealloc];
}
@end
