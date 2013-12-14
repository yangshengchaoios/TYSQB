//  全局静态变量和静态方法
//  Common.m

//
//  Created by shengchao yang on 12-3-7.
//  Copyright (c)  All rights reserved.
//

#import "Common.h"
#import "AloneClass.h"
#import "JSON.h"
#import "DataBaseAccess.h"
#import "Singleton.h"

@interface Common(Private)
 
@end

@implementation Common
+(NSString *) translateString:(NSString *)str{
    if (str == nil) {
        return @"";
    }
    if ([AppSession.translate objectForKey:str]) {
        return [self translateImage:str];
    }else {
        return str;
    }
}
+(NSString *) translateImage:(NSString *)img{
   return [[AppSession.translate objectForKey:img] objectForKey:AppSession.language];
}
+(NSString *) jsonfield:(NSString *)des{
    if (des == nil) {
        return @"";
    }
    NSString *searchString      = [NSString stringWithFormat:des] ;
    NSString *regexString       = @"[#'$]" ;  
    NSString *replaceWithString = @"\"" ;  
    NSString *replacedString    = NULL;  
    replacedString = [searchString stringByReplacingOccurrencesOfRegex:regexString withString:replaceWithString];
    
	NSDictionary *tmpDict = [replacedString JSONValue];
	if (tmpDict) {
		if ([tmpDict objectForKey:AppSession.language]) {
            NSString * tempStr = (NSString *)[tmpDict objectForKey:AppSession.language];
			return Trim(tempStr);
		}else {
			return replacedString;
		}
	}else {
		return replacedString;
	}
}
+(NSString *) StringTrim:(NSString *)source{
    if (source == nil) {
        return @"";
    }
    NSString * trimSource = [NSString stringWithFormat:source];
    NSString * des = [trimSource stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [NSString stringWithFormat:des];
}
+(id) DictObject:(NSDictionary *) dict item:(NSString *)itemName {
    if ([dict objectForKey:itemName] == nil) {
        return @"";
    }else {
        return Trim((NSString *)[dict objectForKey:itemName]);
    }
}
+(NSString *) formatNilObject:(NSString *)string{
    if(string == nil){
        return @"";
    }else {
        return Trim(string);
    }
}

//NSDate->NSString
+(NSString *) NSDateToNSString:(NSDate *)date Format:(NSString *) format{    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: format];
    if (date == nil) {
        date = [NSDate date];
    }
    NSString *dateString = [formatter stringFromDate:date];
    [formatter release];
    return dateString;
}

//NSString->NSDate
+(NSDate *) NSStringToNSDate:(NSString *)string Format:(NSString *) format{    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: format];
    NSDate *date = [formatter dateFromString :string];
    [formatter release];
    return date;
}
+(BOOL) checkPointInRange:(CGPoint) point Range:(CGRect) rect{
    if (point.x<rect.origin.x||point.x>rect.origin.x+rect.size.width||
        point.y<rect.origin.y||point.y>rect.origin.y+rect.size.height) {
        return NO;
    }else{
        return YES;
    }
}
@end