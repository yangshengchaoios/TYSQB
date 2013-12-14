//
//  ListViewController.m
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "ItemCell.h"
#import "Singleton.h"
#import "TaobaoKeItem.h"
#import "FileManager.h"
#import "RegexKitLite.h"
#import "Common.h"
#import "DataBaseAccess.h"
#import "TopUnSDKUtil.h"
#import "NSString+Additions.h"

#import "SendWBViewController.h"
#import <ShareSDK/ShareSDK.h>


@interface ListViewController ()
- (void)startDownload;
@end

@implementation ListViewController
@synthesize tableView;


- (void)viewDidLoad{
    [super viewDidLoad];
    
    addNObserver(@selector(pushSendWBView), @"SysMsg_ListViewController_pushSendWBView");
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (AppSession.totalResults == AppSession.arrayItem.count || AppSession.resultIndex >= 10) {//不显示浏览更多
        return AppSession.arrayItem.count;
    }else {
        return AppSession.arrayItem.count+1;
    }    
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{  
    if (indexPath.row == AppSession.arrayItem.count) {
        UIView *tempView=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)] autorelease];
        tempView.backgroundColor=[UIColor clearColor];
        UILabel *tempLbl=[[UILabel alloc] initWithFrame:CGRectMake(60, 22, 200, 24)];
        tempLbl.text=@"点击加载更多...";
        tempLbl.textColor=[UIColor blackColor];
        tempLbl.textAlignment=UITextAlignmentCenter;
        tempLbl.backgroundColor=[UIColor clearColor];
        tempLbl.font=[UIFont fontWithName:@"Arial" size:18.0f];
        [tempView addSubview:tempLbl];
        [tempLbl release];        
        UITableViewCell *loadMoreCell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 88)] autorelease];
        [loadMoreCell.contentView addSubview:tempView];
        return loadMoreCell;
    }else {
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"ItemCellIdentifier"];    
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
        TaobaoKeItem *taobaokeitem = (TaobaoKeItem *)[AppSession.arrayItem objectAtIndex:indexPath.row];
        NSString *tempTitle = [NSString stringWithFormat:@"%@", [taobaokeitem.jsonObject objectForKey:@"title"]];
        tempTitle = [tempTitle stringByReplacingOccurrencesOfRegex:@"<.*?>" withString:@""];//去掉html标记
        CGRect imgFrame = CGRectMake(0, 0, 63, 63);
        [((UILabel *)[cell viewWithTag:TagOfUILabel]) setText:tempTitle];
        [((UILabel *)[cell viewWithTag:TagOfUILabel+1]) setText:[NSString stringWithFormat:@"￥%@", [taobaokeitem.jsonObject objectForKey:@"price"]]];
        [((UILabel *)[cell viewWithTag:TagOfUILabel+2]) setText:[NSString stringWithFormat:@"%@ 件", [taobaokeitem.jsonObject objectForKey:@"volume"]]];
        [((UILabel *)[cell viewWithTag:TagOfUILabel+3]) setText:[taobaokeitem.jsonObject objectForKey:@"item_location"]];
        [((UIImageView *)[cell viewWithTag:TagOfUIImageView]) setImage:[FileManager getImage:[FileManager getGeneralImagePath:taobaokeitem.imgSmallPath] withRect: imgFrame]];
        return cell;
    }
}
 

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==AppSession.arrayItem.count) {
        MyNSLog(@"加载更多...");
        AppSession.resultIndex++;//增加一页
        [self startLoadMore];
    }else {
        AppSession.arrayItemIndex = indexPath.row;    
        TaobaoKeItem *item = (TaobaoKeItem *)[AppSession.arrayItem objectAtIndex:AppSession.arrayItemIndex];
        NSString *bigPath=[NSString stringWithFormat:@"%@/%@",DocumentPath,item.imgBigPath];//大图本地绝对路径
        if (![FileDefaultManager fileExistsAtPath:bigPath]) {//假如图片不存在就下载
            [self startDownload];
        }else {
            //pushNextViewController
            UIStoryboard * board=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            ListViewController *controller=[board instantiateViewControllerWithIdentifier:@"detail"];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath  {  
    if (editingStyle == UITableViewCellEditingStyleDelete)  {  
        [AppSession.arrayItem removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];  
    }  
}  
#pragma mark - 弹出进度窗口模态的
- (void)startDownload {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"正在下载大图...";
    [HUD showWhileExecuting:@selector(downloadingImage) onTarget:self withObject:nil animated:YES];
}
- (void)downloadingImage{    
    TaobaoKeItem *item = (TaobaoKeItem *)[AppSession.arrayItem objectAtIndex:AppSession.arrayItemIndex];
    NSString *bigPath=[NSString stringWithFormat:@"%@/%@",DocumentPath,item.imgBigPath];//大图本地绝对路径
    [DataBaseAccess downloadFile:item.imgBigUrl LocalFilePath:bigPath];//下载图片到本地
        
    //push详细页面
    UIStoryboard * board=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ListViewController *controller=[board instantiateViewControllerWithIdentifier:@"detail"];
    [self.navigationController pushViewController:controller animated:YES];
}

//加载更多
- (void)startLoadMore{    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"正在加载更多...";
    [HUD showWhileExecuting:@selector(loadingMore) onTarget:self withObject:nil animated:YES];
}
- (void)loadingMore {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:AppSession.searchKeyword forKey:@"keyword"];
    [params setObject:ItemFields forKey:@"fields"];
    [params setObject:@"commissionNum_desc" forKey:@"sort"];
    [params setObject:PageSize forKey:@"page_size"];
    [params setObject:[NSString stringWithFormat:@"%d", AppSession.resultIndex] forKey:@"page_no"];
    [params setObject:@"taobao.taobaoke.items.get" forKey:@"method"];
//    [params setObject:@"16" forKey:@"cid"];
    NSDictionary *result = [TopUnSDKUtil Post:[AppSession.dicConfigTxt objectForKey:@"topKey"] 
                                       secret:[AppSession.dicConfigTxt objectForKey:@"topSecret"] params:params];
    NSDictionary *response = result==nil?result:[result objectForKey:@"taobaoke_items_get_response"];
    NSDictionary *items = response==nil?response:[response objectForKey:@"taobaoke_items"];
    NSArray *itemArray = items==nil?items:[items objectForKey:@"taobaoke_item"];
    
    if (itemArray!=nil && itemArray.count>0) {
        for (id item in itemArray) {
            NSDictionary *dicItem=(NSDictionary *)item;
            NSString *smallName=[[NSString stringWithFormat:@"%@small",[dicItem objectForKey:@"pic_url"]] stringFromMD5];//小图名称
            NSString *smallPath=[NSString stringWithFormat:@"%@/%@/%@.jpg",DocumentPath,AppImgFolder,smallName];//小图本地绝对路径
            NSString *smallUrl=[NSString stringWithFormat:@"%@_100x100.jpg", [dicItem objectForKey:@"pic_url"]];//小图网络地址
            
            NSString *bigName=[[NSString stringWithFormat:@"%@big",[dicItem objectForKey:@"pic_url"]] stringFromMD5];//大图名称
//            NSString *bigPath=[NSString stringWithFormat:@"%@/%@/%@.jpg",DocumentPath,AppImgFolder,bigName];//大图本地绝对路径
            NSString *bigUrl=[NSString stringWithFormat:@"%@_b.jpg", [dicItem objectForKey:@"pic_url"]];//大图网络地址
            [DataBaseAccess downloadFile:smallUrl LocalFilePath:smallPath];//下载图片到本地
            
            TaobaoKeItem *taobaokeitem=[[TaobaoKeItem new] autorelease];
            taobaokeitem.imgSmallPath = [NSString stringWithFormat:@"%@/%@.jpg",AppImgFolder,smallName];//小图本地相对路径
            taobaokeitem.imgSmallUrl = smallUrl;
            taobaokeitem.imgBigPath = [NSString stringWithFormat:@"%@/%@.jpg",AppImgFolder,bigName];//大图本地相对路径
            taobaokeitem.imgBigUrl = bigUrl;
            taobaokeitem.jsonObject = dicItem;
            [AppSession.arrayItem addObject:taobaokeitem];
        }
    }
    
    [self.tableView reloadData];
}
#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

#pragma mark - 分享功能
- (IBAction)doSharing:(id)sender {
//    UIActionSheet *menu = [[UIActionSheet alloc]
//                           initWithTitle: @"选择分享方式"
//                           delegate:self
//                           cancelButtonTitle:@"取消"
//                           destructiveButtonTitle:@"新浪微博"
//                           otherButtonTitles:@"腾讯微博", @"Email", nil];
//    [menu showInView:self.view];
//    [menu release];
    
    id<ISSPublishContent> publishContent = [ShareSDK publishContent:[NSString stringWithFormat:@"大家快来看看这里有很多好东东【%@】",[self getListUrl]]
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
- (IBAction)goBack:(id)sender{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] -2)] animated:YES];
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

- (NSString *)getListUrl{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:AppSession.searchKeyword forKey:@"q"];
    [params setObject:@"taobao.taobaoke.listurl.get" forKey:@"method"];
    NSDictionary *result = [TopUnSDKUtil Post:[AppSession.dicConfigTxt objectForKey:@"topKey"] 
                                       secret:[AppSession.dicConfigTxt objectForKey:@"topSecret"] params:params];
    NSDictionary *response = result==nil?result:[result objectForKey:@"taobaoke_listurl_get_response"];
    NSDictionary *item = response==nil?response:[response objectForKey:@"taobaoke_item"];
    NSString *listUrl = item==nil?item:[item objectForKey:@"keyword_click_url"];
    return listUrl;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    MyNSLog(@"click row=%d",buttonIndex);
    if (buttonIndex != 3) {
        NSString *longUrl=[self getListUrl];
        AppSession.wbLongUrl=longUrl;
        
        if (buttonIndex != 0) {
            NSString *bdShortUrl=[DataBaseAccess getBaiduShortUrl:longUrl];
            AppSession.wbText=[NSString stringWithFormat:@"我喜欢商品列表【%@】",bdShortUrl];
        }
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
//        UIImage *image = [UIImage imageNamed:@"myImage.png"];
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
//        NSData *data = UIImagePNGRepresentation(image);
//        [composer addAttachmentData:data mimeType:@"image/png" fileName:@"curse"];
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

- (void)dealloc {
    removeNObserver(@"SysMsg_ListViewController_pushSendWBView");
    [tableView release];
    [super dealloc];
}

@end
