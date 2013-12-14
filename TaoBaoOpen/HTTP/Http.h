//
//  Http.h
//  HttpTest
//
//  Created by shrek on 10-9-9.
//  Copyright 2010 e0571.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Http : NSObject 
+ (NSString *)httpGet:(NSString *)urlAddress Error:(NSError **)httpError;
+ (NSString *)httpPost:(NSString *)urlAddress Post:(NSDictionary *)post Error:(NSError **)httpError;
+ (BOOL)httpDownload:(NSString *)urlAddress LocalFolder:(NSString *)LocalFolder;
@end
