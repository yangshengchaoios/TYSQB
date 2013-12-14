//
//  NSDictionary+Additions.m
//  X-Touch 2.0
//
//  Created by shengchao yang on 12-3-6.
//  Copyright (c) 2012年 home user. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)
-(id)findAtPath:(NSString*)aPath
{
	NSArray *chunks = [aPath componentsSeparatedByString: @"/"];
	NSDictionary * res = [self copy];
	NSInteger iIndex =0;
	while (iIndex < [chunks count]) {
		res =[res objectForKey:[chunks objectAtIndex:iIndex]];
		iIndex++;
	}  
	return res ;
}

-(BOOL)getBoolValAtPath:(NSString*)aPath
{
	NSArray *chunks = [aPath componentsSeparatedByString: @"/"];
	NSDictionary * res = [self copy];
	NSInteger iIndex =0;
	while (iIndex < [chunks count]-1) {
		res =[res objectForKey:[chunks objectAtIndex:iIndex]];
		iIndex++;
	}  
	return [[res objectForKey:[chunks objectAtIndex:[chunks count]-1]] boolValue];
}

-(NSString*)getStringValueAtPath:(NSString*)aPath
{
	NSArray *chunks = [aPath componentsSeparatedByString: @"/"];
	NSDictionary * res = [self copy];
	NSInteger iIndex =0;
	while (iIndex < [chunks count]-1) {
		res =[res objectForKey:[chunks objectAtIndex:iIndex]];
		iIndex++;
	}  
	if (res) {
		return [res objectForKey:[chunks objectAtIndex:[chunks count]-1]];
	}else {
		return aPath;
	}
}
//禁用--有内存问题
-(id)findWithKey:(NSString*)aKey
{
	id res = nil;
	NSDictionary* copySlef = [self copy];
	NSArray* keys = [copySlef allKeys]; 
	for (NSString* key in keys){
		if ([key isEqualToString:aKey]) {
			res = [self objectForKey:aKey];
			break;
		}
	}
	if (res) {
		return res;
	}
	else {
		for (NSString* key in keys){ 
			if (![NSStringFromClass([[copySlef objectForKey:key] class]) isEqualToString:@"__NSCFDictionary"] ) {
				continue;
			} 
			id res2 =  [copySlef findWithKey:aKey];
			
			if (res2) {
				return res2;
			}  
		}
	}
	return res;
}
@end
