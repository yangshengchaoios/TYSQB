//
//  MainViewController.m
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

#import "DataBaseAccess.h"
#import "Singleton.h"
#import "ListViewController.h"

#import "Common.h"
#import "AloneClass.h"
#import "JSON.h"
#import "TopUnSDKUtil.h"
#import "TaobaoKeItem.h"
#import "NSString+Additions.h"

@interface MainViewController ()
- (void)startSearch;
@end

@implementation MainViewController
@synthesize textFieldKeyword;

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
	// Do any additional setup after loading the view.
    [textFieldKeyword becomeFirstResponder];
}
 
- (void)viewDidUnload
{
    [self setTextFieldKeyword:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//查询
- (IBAction)doSearch:(id)sender {
    [textFieldKeyword resignFirstResponder];
    if ([textFieldKeyword.text isEqualToString:@""]) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"查询条件不能为空！"
                                                       delegate:self 
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
    }else{        
        AppSession.searchKeyword = textFieldKeyword.text;
        //启动查询线程
        [self startSearch];
    }
}
//显示历史搜索列表
- (IBAction)popHistorySearch:(id)sender {
    [textFieldKeyword resignFirstResponder];
    if (AppSession.arrayHistory.count==0) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示"
                                                       message:@"历史搜索为空！"
                                                      delegate:self 
                                             cancelButtonTitle:@"返回"
                                             otherButtonTitles: nil];
        alert.tag = TagOfUIAlertView;
        [alert show];
        [alert release];
    }else {
        AppSession.searchKeyword=@"";//清空选择
        //UIAlertTableView在ios6环境下不能显示tableview
//        UIAlertTableView *alert = [[UIAlertTableView alloc] initWithTitle:@"选择历史搜索"
//                                                                  message:@""
//                                                                 delegate:self
//                                                        cancelButtonTitle:@"清空历史"
//                                                        otherButtonTitles:@"确定", nil];
//        alert.tag=TagOfUIAlertView+1;
//        alert.tableHeight = 180;
//        [alert show];
//        [alert release];
        
        SBTableAlert *alert	= [[SBTableAlert alloc] initWithTitle:@"选择历史搜索" cancelButtonTitle:@"取消" messageFormat:nil];
        [alert.view setTag:TagOfUIAlertView+1];
        [alert.view addButtonWithTitle:@"清空历史"];
        [alert setDelegate:self];
        [alert setDataSource:self];
        [alert show];
//        [alert release];//在dismiss方法里调用
    }    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==alertView.cancelButtonIndex) {
        MyNSLog(@"点击了cancel按钮");
    }else if(buttonIndex == 1){
        if(alertView.tag == TagOfUIAlertView+2){
            [DataBaseAccess Update:@"delete from history"];   
            [AppSession initArrayHistory];
        }        
    }
}
- (void)dealloc {
    [textFieldKeyword release];
    [super dealloc];
}
#pragma mark - 弹出进度窗口模态的
- (void)startSearch{
    [DataBaseAccess Update:[NSString stringWithFormat:@"delete from history where keyword='%@'",AppSession.searchKeyword]];
    [DataBaseAccess Update:[NSString stringWithFormat:@"insert into history(keyword) values('%@')",AppSession.searchKeyword]];
    [AppSession initArrayHistory];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = [NSString stringWithFormat:@"正在查询：%@",AppSession.searchKeyword];
    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}
- (void)myTask{    
    NSString *localAbsoluteFolder=[NSString stringWithFormat:@"%@/%@",DocumentPath,AppImgFolder];
    [AppSession.arrayItem removeAllObjects];//清空缓存对象
    [FileManager filesDelete:localAbsoluteFolder];//删除图片目录
    [FileManager folderCreate:localAbsoluteFolder];//创建图片目录
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:AppSession.searchKeyword forKey:@"keyword"];
    [params setObject:ItemFields forKey:@"fields"];
    [params setObject:@"commissionNum_desc" forKey:@"sort"];
    [params setObject:PageSize forKey:@"page_size"];
    [params setObject:@"1" forKey:@"page_no"];
    [params setObject:@"taobao.taobaoke.items.get" forKey:@"method"];
//    [params setObject:@"16" forKey:@"cid"];
    NSDictionary *result = [TopUnSDKUtil Post:[AppSession.dicConfigTxt objectForKey:@"topKey"] 
                                       secret:[AppSession.dicConfigTxt objectForKey:@"topSecret"] params:params];
    NSDictionary *response = result==nil?result:[result objectForKey:@"taobaoke_items_get_response"];
    NSDictionary *items = response==nil?response:[response objectForKey:@"taobaoke_items"];
    NSArray *itemArray = items==nil?items:[items objectForKey:@"taobaoke_item"];
    AppSession.totalResults = response==nil?0:[[response objectForKey:@"total_results"] intValue];//获取总的结果数
    AppSession.resultIndex = 1;//当前显示第一页
    
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

    //pushNextViewController
    UIStoryboard * board=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ListViewController *list=[board instantiateViewControllerWithIdentifier:@"list"];
    [self.navigationController pushViewController:list animated:YES];
}
#pragma mark - MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}




#pragma mark - SBTableAlertDataSource
- (UITableViewCell *)tableAlert:(SBTableAlert *)tableAlert cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if (tableAlert.view.tag == 0 || tableAlert.view.tag == 1) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	} else {
		// Note: SBTableAlertCell
		cell = [[[SBTableAlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	}
	
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[AppSession.arrayHistory objectAtIndex:indexPath.row]];	
	return cell;
}

- (NSInteger)numberOfSectionsInTableAlert:(SBTableAlert *)tableAlert {
	return 1;
}
- (NSInteger)tableAlert:(SBTableAlert *)tableAlert numberOfRowsInSection:(NSInteger)section {
//	if (tableAlert.type == SBTableAlertTypeSingleSelect)
//		return 10;
//	else
//		return 10;
    
    return  [AppSession.arrayHistory count];
}

- (NSString *)tableAlert:(SBTableAlert *)tableAlert titleForHeaderInSection:(NSInteger)section {
	if (tableAlert.view.tag == 3)
		return [NSString stringWithFormat:@"Section Header %d", section];
	else
		return nil;
}

#pragma mark - SBTableAlertDelegate
- (void)tableAlert:(SBTableAlert *)tableAlert didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableAlert.type == SBTableAlertTypeMultipleSelct) {
		UITableViewCell *cell = [tableAlert.tableView cellForRowAtIndexPath:indexPath];
		if (cell.accessoryType == UITableViewCellAccessoryNone)
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		else
			[cell setAccessoryType:UITableViewCellAccessoryNone];
		
		[tableAlert.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}else {
        UITableViewCell *cell = [tableAlert.tableView cellForRowAtIndexPath:indexPath];
        AppSession.searchKeyword = cell.textLabel.text;
        if (![AppSession.searchKeyword isEqualToString:@""]) {
            //启动查询线程
            [self startSearch];
        }
    }    
}

- (void)tableAlert:(SBTableAlert *)tableAlert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示"
                                                       message:@"确定要清空历史？"
                                                      delegate:self 
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确定", nil];
        alert.tag = TagOfUIAlertView+2;
        [alert show];
        [alert release];
    }
	[tableAlert release];
}
@end
