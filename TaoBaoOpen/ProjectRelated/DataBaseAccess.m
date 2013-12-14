//
//  DataBaseAccess.m

//
//  Created by shengchao yang on 12-3-7.
//  Copyright (c)  All rights reserved.
//

#import "DataBaseAccess.h"
#import "Common.h"
#import "FileManager.h"
#import "Http.h"
#import "NSString+Additions.h"
#import "RegexKitLite.h"
#import "JSON.h"

@implementation DataBaseAccess
+ (id)downloadJSONData:(NSString *)url{
	NSString *response = @"";
    response = [Http httpGet:url Error:nil];
//    response = [response replaceFrom:@"\\" To:@""];
//    response = [response stringByReplacingOccurrencesOfRegex:@"<[[^>]*]>" withString:@""];//去掉html标记
//    response = [response stringByReplacingOccurrencesOfRegex:@"([{,]{1})(\\w+)(:)" withString:@"$1\"$2\"$3"];
	return [response JSONValue];
}
//获取短网址
+ (NSString *)getBaiduShortUrl:(NSString *)longUrl{
    NSDictionary *postData=[[NSDictionary alloc] initWithObjectsAndKeys:longUrl,@"url", nil];
    NSString *resultStr=[Http httpPost:@"http://dwz.cn/create.php" Post:postData Error:nil];
    NSDictionary *resultDic = resultStr==nil?nil:[resultStr JSONValue];
    NSString *status = resultDic==nil?@"":[NSString stringWithFormat:@"%@",[resultDic objectForKey:@"status"]];
    if ([status isEqualToString:@"0"]) {
        return [resultDic objectForKey:@"tinyurl"];
    }else {
        NSString *errMsg=[[resultDic objectForKey:@"err_msg"] UTF8DecodedString];
        MyNSLog(@"errMsg=%@",errMsg);
        return @"";
    }
}
+(NSString *)getSinaWeiboShortUrl:(NSString *)longUrl withKey:(NSString *)sinaKey{
    NSString *tempUrl=[NSString stringWithFormat:@"https://api.weibo.com/2/short_url/shorten.json?source=%@&url_long=%@",sinaKey,[longUrl UTF8EncodedString]];
    MyNSLog(@"tempUrl=%@",tempUrl);
    //返回JSON字典
    NSError *error;  
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:tempUrl]];  
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];  
    NSDictionary *jsonDict = response==nil?response:[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];   
    MyNSLog(@"jsonDict=%@",jsonDict);
    NSArray *array=jsonDict==nil?jsonDict:[jsonDict objectForKey:@"urls"];
    MyNSLog(@"array count=%d",array.count);
    if (array && array.count>0) {
        NSDictionary *tempDic=[array objectAtIndex:0];
        return [tempDic objectForKey:@"url_short"];
    }else {
        return @"";
    }
}

+ (void)downloadFile:(NSString *)url LocalFilePath:(NSString *)filePath{
	[Http httpDownload:url LocalFolder:filePath];

    //判断文件大小
    NSDictionary *fileAttributes1 = [FileDefaultManager attributesOfItemAtPath:filePath error:nil];
    if (fileAttributes1 != nil) {
        NSNumber *size = [fileAttributes1 objectForKey:NSFileSize];
        if ([size intValue] < 1800) {
            [FileManager fileDelete:filePath];
        }
    }
}



+(void) Update:(NSString *)sql{
    FMDatabase *db =[FMDatabase databaseWithPath:DBRealPath];
    if (![db open]) {
        MyNSLog(@"could not open db");
        return;
    }
    [db executeUpdate:sql];
    [db close]; 
}

+(NSMutableArray *) selectMenuHistory:(NSString *)sql{
    FMDatabase *db =[FMDatabase databaseWithPath:DBRealPath];
    if (![db open]) {
        MyNSLog(@"could not open db");
        return nil;
    }    
    FMResultSet *rs=[db executeQuery:sql];
    NSMutableArray *result=[[NSMutableArray new] autorelease];
    while ([rs next]) {
        NSString *temp=[NSString stringWithFormat:@"%@", FormatNilObject([rs stringForColumn:@"keyword"])];//FormatNilObject
        [result addObject:temp];
    }
    [rs close];
    [db close];
    return result;
}


+(NSMutableDictionary *) selectConfigTxt{
    FMDatabase *db =[FMDatabase databaseWithPath:DBRealPath];
    if(![db open]) {
        MyNSLog(@"could not open db");
        return nil;
    }
    
    FMResultSet *rs=[db executeQuery:@"select * from ConfigTxt"];
    NSMutableDictionary *result=[[NSMutableDictionary new] autorelease];
    while ([rs next]) {
        NSString *tempKey=FormatNilObject([rs stringForColumn:@"txtKey"]); 
        NSString *tempValue=FormatNilObject([rs stringForColumn:@"txtValue"]);
        [result setObject:tempValue forKey:tempKey];
    }
    [rs close];
    [db close];
    return result;
}
@end
