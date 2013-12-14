//
//  所有操作(查询、更新)数据库的静态方法
//  DataBaseAccess.h

//
//  Created by shengchao yang on 12-3-7.
//  Copyright (c)  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DataBaseAccess : NSObject
+ (id)downloadJSONData:(NSString *)url;
+ (NSString *)getBaiduShortUrl:(NSString *)longUrl;
+(NSString *)getSinaWeiboShortUrl:(NSString *)longUrl withKey:(NSString *)sinaKey;

+ (void)downloadFile:(NSString *)url LocalFilePath:(NSString *)filePath;

+(void) Update:(NSString *)sql;
+(NSMutableArray *) selectMenuHistory:(NSString *)sql;
+(NSMutableDictionary *) selectConfigTxt;
@end