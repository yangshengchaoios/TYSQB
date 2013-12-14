//
//  TopUnSDKUtil.m
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopUnSDKUtil.h"
#import "NSString+Additions.h"
#import "Common.h"

@interface TopUnSDKUtil(Private)
+(NSString *)getSign:(NSMutableDictionary *)params withSecret:(NSString *)appSecret;
+(NSString *)getBeforeSign:(NSMutableDictionary *)params;
@end

@implementation TopUnSDKUtil
+(NSDictionary *)Post:(NSString *)appKey secret:(NSString *)appSecret params:(NSMutableDictionary *)params{
    NSString *url=@"";
    if (UseSandBoxUrl) {
        url=SandBoxUrl;
    }else {
        url=TaoBaoUrl;
    }
    
    NSString *timestamp=CurrentTime;
    [params setObject:appKey forKey:@"app_key"];
    [params setObject:@"" forKey:@"session"];
    [params setObject:timestamp forKey:@"timestamp"];
    [params setObject:@"json" forKey:@"format"];
    [params setObject:@"2.0" forKey:@"v"];
    [params setObject:@"md5" forKey:@"sign_method"];
    [params setObject:[self getSign:params withSecret:appSecret ] forKey:@"sign"];
    
    //组装url参数
    url =[url stringByAppendingFormat:@"?"];
    int index=0;
    for (id key in params) {
        index++;
        NSString *tempKey=(NSString *)key;
        NSString *tempValue=(NSString *)[params objectForKey:tempKey];
        if (tempValue != nil && ![tempValue isEqualToString:@""]) {
            tempValue = [tempValue UTF8EncodedString];//UTF-8编码
            if (index==1) {
                url = [url stringByAppendingFormat:@"%@=%@",tempKey, tempValue];
            }else {
                url = [url stringByAppendingFormat:@"&%@=%@",tempKey, tempValue];
            }
        }
    }

    //返回JSON字典
    NSError *error;  
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];  
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];  
    NSDictionary *jsonDict = response==nil?response:[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    return jsonDict;
}
//返回签名字符串
+(NSString *)getSign:(NSMutableDictionary *)params withSecret:(NSString *)appSecret{
    NSString *md5Source = [NSString stringWithFormat:@"%@%@%@",appSecret,[self getBeforeSign:params],appSecret];//前后都加secret
    NSString *md5Target = [md5Source stringFromMD5];
    return md5Target;
}
//可见参数部分生成部分加密串
+(NSString *)getBeforeSign:(NSMutableDictionary *)params{
    NSString *str=@"";
    
    NSArray *myKeys = [params allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (int index=0;index<sortedKeys.count;index++) {
        NSString *tempKey=(NSString *)[sortedKeys objectAtIndex:index];
        NSString *tempValue=(NSString *)[params objectForKey:tempKey];
        if (tempValue != nil && ![tempValue isEqualToString:@""]) {
            str = [str stringByAppendingFormat:@"%@%@",tempKey,tempValue];
        }
    }    
    return str;
}

@end
