
//经测试 ios6环境下不能显示table!!!


#import <UIKit/UIKit.h>

@class UIAlertView;

@interface UIAlertTableView : UIAlertView <UITableViewDataSource,UITableViewDelegate>{
	UITableView *tableView;
	int tableHeight;
	int tableExtHeight;
	
	id<UITableViewDataSource> dataSource;
	id<UITableViewDelegate> tableDelegate;
}

@property (nonatomic, assign) id dataSource;
@property (nonatomic, assign) id tableDelegate;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, assign) int tableHeight;

- (void)prepare;

@end

