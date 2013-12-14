//
//  DetailViewController.m
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "Singleton.h"
#import "RegexKitLite.h"
#import "FileManager.h"
#import "SendWBViewController.h"
#import "DataBaseAccess.h"
#import <ShareSDK/ShareSDK.h>

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize lblLocation;
@synthesize lblNick;
@synthesize imgDetail;
@synthesize lblTitle;
@synthesize lblPrice;
@synthesize lblRate;
@synthesize lblVolume;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    addNObserver(@selector(pushSendWBView), @"SysMsg_DetailViewController_pushSendWBView");
    
    taobaokeitem = (TaobaoKeItem *)[AppSession.arrayItem objectAtIndex:AppSession.arrayItemIndex];
    NSString *tempTitle = [NSString stringWithFormat:@"%@", [taobaokeitem.jsonObject objectForKey:@"title"]];
    tempTitle = [tempTitle stringByReplacingOccurrencesOfRegex:@"<.*?>" withString:@""];//去掉html标记
    CGRect imgFrame = CGRectMake(0, 0, imgDetail.frame.size.width, imgDetail.frame.size.height);
    
    imgDetail.image = [FileManager getImage:[FileManager getGeneralImagePath:taobaokeitem.imgBigPath] withRect: imgFrame];
    lblTitle.text = tempTitle;
    lblPrice.text = [NSString stringWithFormat:@"￥%@", [taobaokeitem.jsonObject objectForKey:@"price"]];
    lblVolume.text=[NSString stringWithFormat:@"%@ 件", [taobaokeitem.jsonObject objectForKey:@"volume"]];
    lblNick.text=[taobaokeitem.jsonObject objectForKey:@"nick"];
    lblLocation.text=[taobaokeitem.jsonObject objectForKey:@"item_location"];
}

- (void)viewDidUnload
{
    [self setImgDetail:nil];
    [self setLblTitle:nil];
    [self setLblPrice:nil];
    [self setLblRate:nil];
    [self setLblVolume:nil];
    [self setLblNick:nil];
    [self setLblLocation:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    removeNObserver(@"SysMsg_DetailViewController_pushSendWBView");
    
    [imgDetail release];
    [lblTitle release];
    [lblPrice release];
    [lblRate release];
    [lblVolume release];
    [lblNick release];
    [lblLocation release];
    [super dealloc];
}
- (IBAction)goBack:(id)sender{
[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] -2)] animated:YES];
}
- (IBAction)shareTo:(id)sender {
//    UIActionSheet *menu = [[UIActionSheet alloc]
//                           initWithTitle: @"选择分享方式"
//                           delegate:self
//                           cancelButtonTitle:@"取消"
//                           destructiveButtonTitle:@"新浪微博"
//                           otherButtonTitles:@"腾讯微博", @"Email", nil];
//    [menu showInView:self.view];
//    [menu release];
    
    NSString *longUrl=[taobaokeitem.jsonObject objectForKey:@"click_url"];
//    NSString *bdShortUrl=[DataBaseAccess getBaiduShortUrl:longUrl];
    id<ISSPublishContent> publishContent = [ShareSDK publishContent:[NSString stringWithFormat:@"大家快来看看这里有个好东东【%@】", longUrl]
                                                     defaultContent:@""
                                                              image:[UIImage imageNamed:@"Icon.png"]
                                                       imageQuality:0.8
                                                          mediaType:SSPublishContentMediaTypeNews
                                                              title:@"ShareSDK"
                                                                url:@"http://www.sharesdk.cn"
                                                       musicFileUrl:nil
                                                            extInfo:nil
                                                           fileData:nil];
    [ShareSDK showShareActionSheet:self
                     iPadContainer:[ShareSDK iPadShareContainerWithView:sender
                                                            arrowDirect:UIPopoverArrowDirectionDown]
                         shareList:ShareList
                           content:publishContent
                     statusBarTips:NO
                        convertUrl:YES      //委托转换链接标识，YES：对分享链接进行转换，NO：对分享链接不进行转换，为此值时不进行回流统计。
                       authOptions:nil
                  shareViewOptions:[ShareSDK defaultShareViewOptionsWithTitle:@"内容分享"
                                                              oneKeyShareList:nil//[NSArray defaultOneKeyShareList]
                                                               qqButtonHidden:NO
                                                        wxSessionButtonHidden:NO
                                                       wxTimelineButtonHidden:NO
                                                         showKeyboardOnAppear:NO]
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"分享成功！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                                    [alert show];
                                    [alert release];
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示"
                                                                                  message:[NSString stringWithFormat:@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]]
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"确定"
                                                                        otherButtonTitles: nil];
                                    [alert show];
                                    [alert release];
                                }
                            }];
}
-(Boolean)checkTime:(NSString *)date
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease]; 
    //注意dateFormatter的格式一定要按字符串的样子来，如果不对，转换出来是nill。
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //设置日期格式
    NSDate *today = [NSDate date]; //当前日期
    NSDate *newDate = [dateFormatter dateFromString:date];  //开始日期，将NSString转为NSDate
    
    NSDate *r = [today laterDate:newDate];  //返回较晚的那个日期
    if([today isEqualToDate:newDate]) {
        NSLog(@"日期相同");
        return false;
    }else{
        if([r isEqualToDate:newDate]) {
            NSLog(@"未过期");
            return true;
        }else{
            NSLog(@"已过期");
            return false;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    MyNSLog(@"click row=%d",buttonIndex);
     NSString *longUrl=[taobaokeitem.jsonObject objectForKey:@"click_url"];  
    AppSession.wbLongUrl=longUrl;
    
    if (buttonIndex ==1 || buttonIndex == 2) {
        NSString *bdShortUrl=[DataBaseAccess getBaiduShortUrl:longUrl];
        AppSession.wbText=[NSString stringWithFormat:@"我喜欢商品【%@】",bdShortUrl];
    }
    
    if (buttonIndex==0) {
        AppSession.wbType=@"sina";
        NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
        if ([info objectForKey:@"sina_access_tokenV2"] != nil && [self checkTime:[info objectForKey:@"SinaLastTime"]]) {//当前session是有效的
            [self pushSendWBView];
        }else {//需要登陆授权
            UIStoryboard * board=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UINavigationController *controller=[board instantiateViewControllerWithIdentifier:@"weibooauthIndentifier"];
            [self presentModalViewController:controller animated:YES];
        }
    }else if(buttonIndex == 1){
        AppSession.wbType=@"tx";
        NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
        if ([info objectForKey:@"TX_access_tokenV2"] != nil) {
            [self pushSendWBView];
        }else {//需要登陆授权
            UIStoryboard * board=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UINavigationController *controller=[board instantiateViewControllerWithIdentifier:@"weibooauthIndentifier"];
            [self presentModalViewController:controller animated:YES];
        }
    }else if(buttonIndex == 2){ //发送带图片的邮件
        UIImage *image = imgDetail.image;
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        NSData *data = UIImagePNGRepresentation(image);
        [composer addAttachmentData:data mimeType:@"image/png" fileName:@"curse"];
        [composer setMessageBody:AppSession.wbText isHTML:NO];
        [self presentModalViewController:composer animated:YES];
        [composer release];
    }
}
-(void) pushSendWBView{
    //push发送页面
    UIStoryboard * board=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SendWBViewController *controller=[board instantiateViewControllerWithIdentifier:@"sendwb"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: failed");
			break;
		default:
			NSLog(@"Result: not sent");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}
@end
