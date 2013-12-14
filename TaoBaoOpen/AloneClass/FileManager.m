//
//  FileManager.m

//
//  Created by shengchao yang on 12-3-7.
//  Copyright (c)  All rights reserved.
//

#import "FileManager.h"
@interface FileManager(Private)
@end

@implementation FileManager
#pragma mark - 日志记录


#pragma mark - 文件基本操作
//拷贝文件
+ (BOOL)fileCopy:(NSString *)sName TargetName:(NSString *)tName{
    NSError *error=nil;
    BOOL isSucces=NO;
    if (![FileDefaultManager fileExistsAtPath:sName]) {
        MyNSLog(@"要拷贝的源文件不存在!!!sName=%@", sName);
        return NO;
    }
    if ([FileDefaultManager fileExistsAtPath:tName]) {
        MyNSLog(@"要拷贝的目标文件已经存在!!!马上删除之...%@", tName);
        isSucces=[self fileDelete:tName];//如果不删除，后面的拷贝要失败
    }
    
    isSucces=[FileDefaultManager copyItemAtPath:sName toPath:tName error:&error];//调用拷贝方法
    if (error != nil) {
        MyNSLog(@"拷贝文件出错:%@", [error localizedDescription]);
    }else{
        MyNSLog(@"拷贝文件成功！");
    }
    return isSucces; 
}
//删除文件和文件夹
+ (BOOL)fileDelete:(NSString *)filePath{
    NSError *error=nil;
    BOOL isSucces=NO;
    if (![FileDefaultManager fileExistsAtPath:filePath]) {
        MyNSLog(@"要删除的地址不存在!!!filePath=%@", filePath);
        return NO;
    }
    
    isSucces=[FileDefaultManager removeItemAtPath:filePath error:&error];//调用删除方法
    if (error != nil) {
        MyNSLog(@"删除出错:%@", [error localizedDescription]);
    }else{
        MyNSLog(@"删除成功！");
    }
    return isSucces; 
}

//返回目录下所有的文件路径数组
+ (NSArray *)allFilesInFolderPath:(NSString *)folderPath{
	return [FileDefaultManager contentsOfDirectoryAtPath:folderPath error:nil];
}
//删除目录下所有文件和文件夹
+ (void)filesDelete:(NSString *)folderPath{
    NSArray *files = [self allFilesInFolderPath:folderPath];
    MyNSLog(@"files count=%d", [files count]);
    for (NSString *file in files) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:file];//转换成url
        BOOL isDir;//判断该路径是不是文件夹
        BOOL isExists = [FileDefaultManager fileExistsAtPath:filePath isDirectory:&isDir];//返回文件或文件夹是否存在
        if (isExists) {
            [self fileDelete:filePath];
        }
    }
}
//创建文件夹
+ (BOOL)folderCreate:(NSString *)folderPath{
    NSError *error = nil;
    BOOL isSucces=NO;
    BOOL isDir;//判断该路径是不是文件夹
    BOOL isExists = [FileDefaultManager fileExistsAtPath:folderPath isDirectory:&isDir];//返回文件或文件夹是否存在
    if (isExists && isDir) {
        MyNSLog(@"%@文件夹已经存在!不需要创建!",folderPath);
        return YES;
    }
    
    MyNSLog(@"开始创建文件夹%@",folderPath);
    isSucces=[FileDefaultManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        MyNSLog(@"创建出错:%@", [error localizedDescription]);
    }else{
        MyNSLog(@"创建成功！");
    }
    return isSucces;
}
+(NSString *)getVoiceFile:(NSString *)fileName{
    NSString *filePath = [AppResourcePath stringByAppendingFormat:@"/%@/%@",VoiceFolder,fileName];
    return filePath;
}
+(NSString *)getGeneralImagePath:(NSString *)imageName{
    NSString *filePath = [DocumentPath stringByAppendingFormat:@"/%@",imageName];//首先找沙盒路径
    if (![FileDefaultManager fileExistsAtPath:filePath]) {
        filePath = [AppResourcePath stringByAppendingFormat:@"/%@",imageName];//再找程序资源路径
    } 
    if (![FileDefaultManager fileExistsAtPath:filePath]) {
        filePath = [BoundlePath stringByAppendingFormat:@"/%@",imageName];//再找程序根目录
    } 
    if (![FileDefaultManager fileExistsAtPath:filePath]) {
        filePath = [AppResourcePath stringByAppendingPathComponent:@"default.jpg"];//最后是默认图片
    } 
    return filePath;
}
+(UIImage *)getImage:(NSString *)imagePath withRect:(CGRect)rect{
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];      
    if(NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    else {
        UIGraphicsBeginImageContext(rect.size);
    }
    
    //方法一
    [image drawInRect:rect];
    
//    //方法二
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(context, 0.0, rect.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    CGContextSetBlendMode(context, kCGBlendModeCopy);
//    CGContextDrawImage(context, CGRectMake(0.0, 0.0, rect.size.width, rect.size.height), image.CGImage);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
