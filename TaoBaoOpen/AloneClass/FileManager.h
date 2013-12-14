//
//  FileManager.h

//
//  Created by shengchao yang on 12-3-7.
//  Copyright (c)  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FileManager : NSObject
#pragma mark - 日志记录

#pragma mark - 文件基本操作
+ (BOOL)fileCopy:(NSString *)sName TargetName:(NSString *)tName;
+ (BOOL)fileDelete:(NSString *)filePath;

+ (NSArray *)allFilesInFolderPath:(NSString *)folderPath;
+ (void)filesDelete:(NSString *)folderPath;
+ (BOOL)folderCreate:(NSString *)folderPath;

+(NSString *)getVoiceFile:(NSString *)fileName;
+(NSString *)getGeneralImagePath:(NSString *)imageName;
+(UIImage *)getImage:(NSString *)imagePath withRect:(CGRect)rect;
@end
