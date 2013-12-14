//
//  ListViewController.h
//  TaoBaoOpen
//
//  Created by shengchao yang on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface ListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, MBProgressHUDDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate>{
    MBProgressHUD *HUD;
}
- (IBAction)doSharing:(id)sender;
- (IBAction)goBack:(id)sender;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@end
