//
//  Http.m
//  HttpTest
//
//  Created by shrek on 10-9-9.
//  Copyright 2010 e0571.com. All rights reserved.
//

#import "Http.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSString+Additions.h"


@implementation Http


// http 访问
+ (NSString *)httpGet:(NSString *)urlAddress Error:(NSError **)httpError
{
	NSURL *url=[NSURL URLWithString:[urlAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSString *returnString;
    #if TARGET_IPHONE_SIMULATOR
        NSLog(@"Http Get Method: Url=%@",urlAddress);
    #endif
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	[request addRequestHeader:@"Content-Type" value:@"text/xml;charset=UTF-8"];
	[request addRequestHeader:@"User-Agent" value:@"iPhone"];
	[request addRequestHeader:@"Referer" value:urlAddress];
	[request setRequestMethod:@"GET"];
	[request startSynchronous];
	
	NSError *error=[request error];
	int statusCode = [request responseStatusCode];
	
	if (!error) {
		if (statusCode==200)
		{
            #if TARGET_IPHONE_SIMULATOR
                NSLog(@"httpget success.");
            #endif
			returnString=[request responseString];
            #if TARGET_IPHONE_SIMULATOR
                NSLog(@"Response Content:\n%@",returnString);
            #endif
			return returnString;
		}
		else {
            #if TARGET_IPHONE_SIMULATOR
                NSLog(@"httpget success,but function failured :%d",statusCode);
            #endif
			NSDictionary *errorDetail = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"error:%@",[request responseString]] forKey:NSLocalizedDescriptionKey];
			if (httpError != nil) {
				*httpError= [NSError errorWithDomain:@"http" code:100 userInfo:errorDetail];
			}
			
			return nil;
		}
	}
	else {
        #if TARGET_IPHONE_SIMULATOR
            NSLog(@"httpget failure :%d",statusCode);
        #endif
		if (httpError != nil) {
			*httpError=error;//[error retain];
		}
		return nil;
	}
	return nil;
}

+ (NSString *)httpPost:(NSString *)urlAddress Post:(NSDictionary *)post Error:(NSError **)httpError
{
	NSURL *url=[NSURL URLWithString:[urlAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSString *returnString;
    #if TARGET_IPHONE_SIMULATOR
        NSLog(@"Http Post Method: Url=%@",urlAddress);
    #endif
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:30];//设置超时时间

	// process post information
	NSString *key;
    NSString *value;
	for (key in post) {
        value = (NSString *)[post objectForKey:key];
		[request setPostValue:value  forKey:key];
	}
	[request addRequestHeader:@"Content-Type" value:@"text/xml;charset=UTF-8"];
	[request addRequestHeader:@"User-Agent" value:@"iPhone"];
	[request addRequestHeader:@"Referer" value:urlAddress];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	NSError *error=[request error];
	if (!error) 
	{
		returnString=[request responseString];
		return returnString;
	}
	else {
		if (httpError != nil) {
			*httpError = error;
		}
		return nil;
	}
	return nil;	
}

+(BOOL)httpDownload:(NSString *)urlAddress LocalFolder:(NSString *)LocalFolder
{
	NSURL *url=[NSURL URLWithString:[urlAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
	[request setDownloadDestinationPath:LocalFolder];
	[request startSynchronous];
	NSError *error=[request error];
	if (!error)
	{
		return TRUE;
	}
	else 
	{
		MyNSLog(@"%@",[error localizedDescription]);
		return FALSE;
	}
}
@end
