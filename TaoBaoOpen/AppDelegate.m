//
//  AppDelegate.m
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "DataBaseAccess.h"
#import "Singleton.h"
#import "Common.h"
#import "AloneClass.h"
#import "JSON.h"
#import "TopUnSDKUtil.h"
#import "TaobaoKeItem.h"
#import "NSString+Additions.h"

#import "WXApi.h"
#import <QQApi/QQApi.h> 
#import <ShareSDK/ShareSDK.h>

@implementation AppDelegate

@synthesize window = _window;
- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /////shareSDKtest//////
    [WXApi registerApp:@"wx48b233acf7c8ac5d"];
//    [QQApi registerPluginWithId:@"QQ075BCD15"];
    [ShareSDK registerApp:@"ec127b8500"];
    /////end///////////
    ////////////FOR TEST/////////////
//    [self testNet];   
    
    ////////////END TEST////////////
    //数据库的初始化
    if (InitDB) {
        [self initDataBase];
    }else{
        if (![FileDefaultManager fileExistsAtPath:DBRealPath]) {
            if ([FileManager fileCopy:DBDemoPath TargetName:DBRealPath]) {
                MyNSLog(@"拷贝数据库文件成功!");
            }else{
                MyNSLog(@"拷贝数据库文件失败!!!");
            }
        }
    }  
    
    [AppSession initDicConfigTxt];//初始化常量字典
    [AppSession initArrayHistory];//初始化数据库里的搜索历史
//    [self checkKeyUpdate];//从网络下载appkey并保存在数据库
    return YES;
}



-(void) checkKeyUpdate{
    NSError *error;  
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:DownloadAppkey]];  
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];  
    NSDictionary *jsonDict = response==nil?response:[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    MyNSLog(@"jsonDict=%@",jsonDict);
//    NSString *s=@"{\"topKey\":\"123\",\"topSecret\":\"123\",\"topCallback\":\"http://www.tysqb.com\",\"sign\":\"d4961dd8b759f13f1052fa1ef61ae3eb\"}";
//    NSDictionary *jsonDict=[s JSONValue];
    
    if (jsonDict != nil && [jsonDict objectForKey:@"sign"]) {//必须有签名字符串
        NSString *sign=[jsonDict objectForKey:@"sign"];
        NSString *signTarget=@"";
        if ([jsonDict objectForKey:@"topKey"]) {
            NSString *temp=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"topKey"]];
            signTarget = [signTarget stringByAppendingString:temp];
        }
        if ([jsonDict objectForKey:@"topSecret"]) {
            NSString *temp=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"topSecret"]];
            signTarget = [signTarget stringByAppendingString:temp];
        }
        if ([jsonDict objectForKey:@"topCallback"]) {
            NSString *temp=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"topCallback"]];
            signTarget = [signTarget stringByAppendingString:temp];
        }
        
        if ([jsonDict objectForKey:@"sinaKey"]) {
            NSString *temp=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"sinaKey"]];
            signTarget = [signTarget stringByAppendingString:temp];
        }
        if ([jsonDict objectForKey:@"sinaSecret"]) {
            NSString *temp=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"sinaSecret"]];
            signTarget = [signTarget stringByAppendingString:temp];
        }
        if ([jsonDict objectForKey:@"sinaCallback"]) {
            NSString *temp=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"sinaCallback"]];
            signTarget = [signTarget stringByAppendingString:temp];
        }
        
        if ([jsonDict objectForKey:@"txKey"]) {
            NSString *temp=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"txKey"]];
            signTarget = [signTarget stringByAppendingString:temp];
        }
        if ([jsonDict objectForKey:@"txSecret"]) {
            NSString *temp=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"txSecret"]];
            signTarget = [signTarget stringByAppendingString:temp];
        }
        if ([jsonDict objectForKey:@"txCallback"]) {
            NSString *temp=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"txCallback"]];
            signTarget = [signTarget stringByAppendingString:temp];
        }
        signTarget = [signTarget stringFromMD5].lowercaseString;
        if ([sign length]>10 && [sign.lowercaseString isEqualToString:signTarget]) {
            //更新淘宝key
            if ([jsonDict objectForKey:@"topKey"] && [jsonDict objectForKey:@"topSecret"] && [jsonDict objectForKey:@"topCallback"]) {
                if (![(NSString *)[jsonDict objectForKey:@"topKey"] isEqualToString:[AppSession.dicConfigTxt objectForKey:@"topKey"]]) {
                    [AppSession updateConfigTxtKey:@"topKey" withValue:[jsonDict objectForKey:@"topKey"]];
                    [AppSession updateConfigTxtKey:@"topSecret" withValue:[jsonDict objectForKey:@"topSecret"]];
                    [AppSession updateConfigTxtKey:@"topCallback" withValue:[jsonDict objectForKey:@"topCallback"]];
                }
            }
            
            //更新新浪key
            if ([jsonDict objectForKey:@"sinaKey"] && [jsonDict objectForKey:@"sinaSecret"] && [jsonDict objectForKey:@"sinaCallback"]) {
                if (![(NSString *)[jsonDict objectForKey:@"sinaKey"] isEqualToString:[AppSession.dicConfigTxt objectForKey:@"sinaKey"]]) {
                    [AppSession updateConfigTxtKey:@"sinaKey" withValue:[jsonDict objectForKey:@"sinaKey"]];
                    [AppSession updateConfigTxtKey:@"sinaSecret" withValue:[jsonDict objectForKey:@"sinaSecret"]];
                    [AppSession updateConfigTxtKey:@"sinaCallback" withValue:[jsonDict objectForKey:@"sinaCallback"]];
                    [AppSession removeSinaRestore];
                }
            }
            //更新腾讯key
            if ([jsonDict objectForKey:@"txKey"] && [jsonDict objectForKey:@"txSecret"] && [jsonDict objectForKey:@"txCallback"]) {
                if (![(NSString *)[jsonDict objectForKey:@"txKey"] isEqualToString:[AppSession.dicConfigTxt objectForKey:@"txKey"]]) {
                    [AppSession updateConfigTxtKey:@"txKey" withValue:[jsonDict objectForKey:@"txKey"]];
                    [AppSession updateConfigTxtKey:@"txSecret" withValue:[jsonDict objectForKey:@"txSecret"]];
                    [AppSession updateConfigTxtKey:@"txCallback" withValue:[jsonDict objectForKey:@"txCallback"]];
                    [AppSession removeTxRestore];
                }
            }
        }        
    }
}
 
-(void) initDataBase{
    //删除数据库文件
    [FileManager fileDelete:DBRealPath];
    
    //历史搜索
    NSString *tableSql_history=@"create table if not exists history( \
    hisId integer primary key autoincrement, \
    keyword text \
    )";
    [DataBaseAccess Update:tableSql_history];
    
    //自定义文字
    NSString *tableSql_ConfigTxt=@"create table if not exists configTxt( \
    txtKey text, \
    txtValue text \
    )";
    [DataBaseAccess Update:tableSql_ConfigTxt];
    
    //淘宝默认key
    [DataBaseAccess Update:@"insert into configTxt(txtKey,txtValue) values('topKey','21290499')"];
    [DataBaseAccess Update:@"insert into configTxt(txtKey,txtValue) values('topSecret','e3fe27df761373f24fcdf903f1417a92')"];
    [DataBaseAccess Update:@"insert into configTxt(txtKey,txtValue) values('topCallback','http://www.tysqb.com')"];
    
    //新浪默认key
    [DataBaseAccess Update:@"insert into configTxt(txtKey,txtValue) values('sinaKey','1111936025')"];
    [DataBaseAccess Update:@"insert into configTxt(txtKey,txtValue) values('sinaSecret','b3d14c2edaf9c960beab97610f80678e')"];
    [DataBaseAccess Update:@"insert into configTxt(txtKey,txtValue) values('sinaCallback','http://www.tysqb.com')"];
    
    //腾讯默认key
    [DataBaseAccess Update:@"insert into configTxt(txtKey,txtValue) values('txKey','801273517')"];
    [DataBaseAccess Update:@"insert into configTxt(txtKey,txtValue) values('txSecret','9e2891121557a6234ee0685e81da4ebe')"];
    [DataBaseAccess Update:@"insert into configTxt(txtKey,txtValue) values('txCallback','http://www.tysqb.com')"];
    
    [AppSession removeSinaRestore];
    [AppSession removeTxRestore];
}
 
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    MyNSLog(@"handleOpenURL");
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
   MyNSLog(@"handleOpenURL sourceApplication");
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
