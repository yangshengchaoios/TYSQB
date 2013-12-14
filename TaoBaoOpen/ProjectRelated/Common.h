//  全局静态变量和静态方法
//  Common.h

//
//  Created by shengchao yang on 12-3-7.
//  Copyright (c)  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Common : NSObject
+(NSString *) translateString:(NSString *)str;
+(NSString *) translateImage:(NSString *)img;
+(NSString *) jsonfield:(NSString *)des;
+(id) DictObject:(NSDictionary *) dict item:(NSString *)itemName;
+(NSString *) StringTrim:(NSString *)source;
+(NSString *) formatNilObject:(NSString *)string;
+(NSString *) NSDateToNSString:(NSDate *)date Format:(NSString *) format;
+(NSDate *) NSStringToNSDate:(NSString *)string Format:(NSString *) format;
 

+(BOOL) checkPointInRange:(CGPoint) point Range:(CGRect) rect;
@end
