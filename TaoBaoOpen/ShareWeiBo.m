//
//  ShareWeiBo.m
//  webViewDemo
//
//  Created by apple on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareWeiBo.h"
#import "JSON.h"
#import "base64.h"
#import "NSData-AES.h"
#import "Singleton.h"

@implementation ShareWeiBo

static ShareWeiBo *_shareKit;

+ (ShareWeiBo *)mainShare
{
    if (nil == _shareKit) {
        _shareKit = [[ShareWeiBo alloc] init];
    }
    return _shareKit;
}

//获取腾讯返回的字符串  来自腾讯微博SDK
+ (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
	NSString * str = nil;
	NSRange start = [url rangeOfString:needle];
	if (start.location != NSNotFound) {
		NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
		NSUInteger offset = start.location+start.length;
		str = end.location == NSNotFound
		? [url substringFromIndex:offset]
		: [url substringWithRange:NSMakeRange(offset, end.location)];
		str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	
	return str;
}

//计算token过期时间
-(NSString*)countDateTime:(NSTimeInterval)time
{
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeInterval  interval = time; 
    NSDate *date1 = [[[NSDate alloc] initWithTimeIntervalSinceNow:+interval] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date1]];
}

//检查过期时间
-(Boolean)checkTime:(NSString *)date
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease]; 
    //注意dateFormatter的格式一定要按字符串的样子来，如果不对，转换出来是nill。
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //设置日期格式
    NSDate *today = [NSDate date]; //当前日期
    NSDate *newDate = [dateFormatter dateFromString:date];  //开始日期，将NSString转为NSDate
    
    NSDate *r = [today laterDate:newDate];  //返回较晚的那个日期
    if([today isEqualToDate:newDate]) {
        NSLog(@"日期相同");
        return false;
    }else{
        if([r isEqualToDate:newDate]) {
            NSLog(@"未过期");
            return true;
        }else{
            NSLog(@"已过期");
            return false;
        }
    }
}



//AES加密
-(NSString*)encryption:(NSString*)password:(NSString*)Text
{
    NSData *data = [Text dataUsingEncoding: NSASCIIStringEncoding];
	NSData *encryptedData = [data AESEncryptWithPassphrase:password];
	[Base64 initialize];
	NSString *b64EncStr = [Base64 encode:encryptedData];
    return b64EncStr;
}

//AES解密
-(NSString*)Decrypt:(NSString*)password:(NSString*)Text
{
    [Base64 initialize];
    NSData	*b64DecData = [Base64 decode:Text];
	NSData *decryptedData = [b64DecData AESDecryptWithPassphrase:password];
	
	NSString* decryptedStr = [[[NSString alloc] initWithData:decryptedData encoding:NSASCIIStringEncoding] autorelease];
    return decryptedStr;
}




//解析URL  来自腾讯腾讯微博SDK
-(NSString *)generateURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod 
{
	
	NSURL *parsedUrl = [NSURL URLWithString:baseUrl];
	NSString *queryPrefix = parsedUrl.query ? @"&" : @"?";
	
	NSMutableArray* pairs = [NSMutableArray array];
	for (NSString* key in [params keyEnumerator]) 
    {
		if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
			||([[params valueForKey:key] isKindOfClass:[NSData class]])) 
        {
			if ([httpMethod isEqualToString:@"GET"]) 
            {
				NSLog(@"can not use GET to upload a file");
			}
			continue;
		}
		
		NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																					  NULL, 
																					  (CFStringRef)[params objectForKey:key],
																					  NULL, 
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																					  kCFStringEncodingUTF8);
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
		[escaped_value release];
	}
	NSString* query = [pairs componentsJoinedByString:@"&"];
	
	return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}




//发送新浪微博
-(void)postSinaWeiBoAPI
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
    NSString *post=[NSString stringWithFormat:@"source=%@&status=%@&lat=0&long=0&access_token=%@",
                    [AppSession.dicConfigTxt objectForKey:@"sinaKey"],sinaWeiBoText,
                    [self Decrypt:MyPWDKey :[info objectForKey:@"sina_access_tokenV2"]]];
    
    NSData *postData=[post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength=[NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:SINASENDTEXT]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)    
    {
        NSURLResponse *response;
        NSError *error;
        
        NSData *resutlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *resultSting=[[NSString alloc] initWithData:resutlData encoding:NSUTF8StringEncoding];
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[resultSting JSONValue]];
        NSLog(@"%@",dict);
        if ([dict objectForKey:@"error_code"] != nil) {
            int code = [[dict objectForKey:@"error_code"] intValue];
            NSLog(@"code = %d",code);
            if (code == 20019) {
                [self showMessage:@"不能发布相同的微博!"];
            }
            else {
                [self showMessage:@"发送微博失败!"];
            }
        }
        else {
            [self showMessage:@"分享新浪微博成功!"];
        }
        
        [resultSting release];
        [dict release];
    }
    [conn release];
    [request release];
    [pool release];

}

//发送腾讯微博
-(void)postTXWeiBoAPI
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
    NSString *post=[NSString stringWithFormat:@"jing=0&wei=0&clientip=CLIENTIP&format=json&syncflag=0&oauth_version=2.a&scope=all&oauth_consumer_key=%@&openid=%@&access_token=%@&content=%@",
                    [AppSession.dicConfigTxt objectForKey:@"txKey"],[info objectForKey:@"TX_idV2"],[self Decrypt:MyPWDKey :[info objectForKey:@"TX_access_tokenV2"]],txWeiBoText];
    
    NSLog(@"%@",post);
    
    NSData *postData=[post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength=[NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:TXSENDTEXT]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)    
    {
        NSURLResponse *response;
        NSError *error;
        
        NSData *resutlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *resultSting=[[NSString alloc] initWithData:resutlData encoding:NSUTF8StringEncoding];
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[resultSting JSONValue]];
        NSLog(@"%@",dict);
        if ([[dict objectForKey:@"errcode"] intValue]!=0) {
            [self showMessage:@"发送微博失败!"];
        }
        else {
            [self showMessage:@"分享腾讯微博成功!"];
        }
        
        [resultSting release];
        [dict release];
    }
    [conn release];
    [request release];
    [pool release];
    
}

-(void)showMessage:(NSString*)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统提示" message:text delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];  
    [alert release];
    
}








#pragma Sina
//开始授权-sina
-(void)startSinaAuthorize:(UIWebView *)webView
{
    _webView = webView;
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [AppSession.dicConfigTxt objectForKey:@"sinaKey"], @"client_id",
                                   @"code", @"response_type",
                                   @"default", @"display",
                                   [AppSession.dicConfigTxt objectForKey:@"sinaCallback"], @"redirect_uri",
                                   nil];
    NSString *authorizeURL = [SINAOauthRequestBaseURL stringByAppendingString:SINAGETTOKEN];    
    NSString *loadingURL = [self generateURL:authorizeURL params:params httpMethod:nil];    
    MyNSLog(@"loadingURL=%@",loadingURL);
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:loadingURL]];
	[_webView loadRequest:request];  
}


//sina换取accesstoken
- (BOOL)startSinaAccessWithVerifier_V2:(NSString *)_ver
{
    MyNSLog(@"code=%@",_ver);
    BOOL bl = false;
    NSString *post=[NSString stringWithFormat:@"client_id=%@&client_secret=%@&redirect_uri=%@&code=%@&grant_type=authorization_code",
                    [AppSession.dicConfigTxt objectForKey:@"sinaKey"],
                    [AppSession.dicConfigTxt objectForKey:@"sinaSecret"],
                    [AppSession.dicConfigTxt objectForKey:@"sinaCallback"],
                    _ver];
    NSData *postData=[post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength=[NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.weibo.com/oauth2/access_token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)    
    {
        NSURLResponse *response;
        NSError *error;
        
        NSData *resutlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *resultSting=[[NSString alloc] initWithData:resutlData encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dict = [resultSting JSONValue];
        MyNSLog(@"%@",dict);
        //记录获取到的用户信息
        NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
        [info setValue:[self encryption:MyPWDKey :[dict objectForKey:@"access_token"]] forKey:@"sina_access_tokenV2"];
        [info setValue:[dict objectForKey:@"uid"] forKey:@"sina_uidV2"];
        [info setValue:[self countDateTime:[[dict objectForKey:@"expires_in"] intValue]] forKey:@"SinaLastTime"];
        [info synchronize];
        
        if ([dict objectForKey:@"access_token"]!=nil) {
            bl = true;
        }
        [resultSting release];
    }
    [request release];
    [conn release];
    
    return bl;
}


//发送sina微博
-(void)sendSinaText:(NSString*)Text
{
    NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
    
    if ([info objectForKey:@"sina_access_tokenV2"] == nil) {
        [self showMessage:@"请先进行新浪微博授权!"];
        return;
    }
    if (![self checkTime:[info objectForKey:@"SinaLastTime"]]) {
        [self showMessage:@"已超过授权实效，请重新授权!"];      
        return;
    }
    sinaWeiBoText = Text;
    //使用线程进行http同步请求
    NSException *e = [NSException exceptionWithName:@"CCException" reason:@"empty"                                            userInfo:nil];
    @try {
        NSThread *thread;
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(postSinaWeiBoAPI) object:self];
        [thread setStackSize:1024*1024];
        [thread setThreadPriority:0.5];
        
        [thread start];    
        [thread release];
        @throw e;
    }
    @catch (NSException *e) {
        
    }

}



#pragma TX
//开始腾讯微博授权
-(void)startTXAuthorize:(UIWebView *)webView
{
    _webView = webView;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [AppSession.dicConfigTxt objectForKey:@"txKey"], @"client_id",
                                   @"token", @"response_type",
                                   @"2", @"wap",
                                   [AppSession.dicConfigTxt objectForKey:@"txCallback"], @"redirect_uri",
                                   @"ios", @"appfrom",
                                   nil];
    NSString *authorizeURL = [oauthRequestBaseURL stringByAppendingString:authPrefix];
    NSString *loadingURL = [[self generateURL:authorizeURL params:params httpMethod:nil] retain];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:loadingURL]];
	[_webView loadRequest:request];
    [loadingURL release];
}


//发送腾讯微博
-(void)sendTxText:(NSString *)Text
{
    NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
    
    if ([info objectForKey:@"TX_access_tokenV2"] == nil) {
        [self showMessage:@"请先进行腾讯微博授权!"];
        return;
    }

    txWeiBoText = Text;
    //使用线程进行http同步请求
    NSException *e = [NSException exceptionWithName:@"CCException"
                                             reason:@"empty"      
                                           userInfo:nil];
    @try {
        NSThread *thread;
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(postTXWeiBoAPI) object:self];
        [thread setStackSize:1024*1024];
        [thread setThreadPriority:0.5];
        
        [thread start];    
        [thread release];
        @throw e;
    }
    @catch (NSException *e) {
        
    }
}





@end
