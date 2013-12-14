//
//  NSString+Additions.m
//  X-Touch 2.0
//
//  Created by shengchao yang on 12-3-6.
//  Copyright (c) 2012年 home user. All rights reserved.
//

#import "NSString+Additions.h"
#import <CommonCrypto/CommonDigest.h>  

@implementation NSString (Additions)
- (BOOL)isContainString:(NSString *)searchKey{
    NSRange range = [self rangeOfString:searchKey];
	return range.location != NSNotFound;
}

-(NSString *) replaceFrom:(NSString *)fromstr To:(NSString *)tostr{
//    NSString * result = [self stringByReplacingOccurrencesOfString:fromstr withString:tostr];
//    return [result autorelease];
    return [self stringByReplacingOccurrencesOfString:fromstr withString:tostr];
}

#pragma mark UTF8编码解码
- (NSString *)UTF8EncodedString{    
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    return [result autorelease];
}
- (NSString*)UTF8DecodedString{
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)self,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    return [result autorelease];
}
- (NSString *) stringFromMD5{  
    if(self == nil || [self length] == 0)  
        return nil;  
    const char *value = [self UTF8String];  
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];  
    CC_MD5(value, strlen(value), outputBuffer);  
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];  
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){  
        [outputString appendFormat:@"%02X",outputBuffer[count]];  
    }  
    return [outputString autorelease];
}  
@end
