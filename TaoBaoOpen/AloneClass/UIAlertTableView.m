

#import "UIAlertTableView.h"
#import "Singleton.h"

#define kTablePadding 8.0f


@interface UIAlertView (private)
- (void)layoutAnimated:(BOOL)fp8;
@end

@implementation UIAlertTableView

@synthesize dataSource;
@synthesize tableDelegate;
@synthesize tableHeight;
@synthesize tableView;

- (void)layoutAnimated:(BOOL)fp8 {
    NSLog(@"layoutAnimated");
	[super layoutAnimated:fp8];
	[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y - tableExtHeight/2, self.frame.size.width, self.frame.size.height + tableExtHeight)];
	
	// We get the lowest non-control view (i.e. Labels) so we can place the table view just below
	UIView *lowestView;
	int i = 0;
	while (![[self.subviews objectAtIndex:i] isKindOfClass:[UIControl class]]) {
		lowestView = [self.subviews objectAtIndex:i];
        NSLog(@"layoutAnimated ->%d",i);
		i++;
	}
	
	CGFloat tableWidth = 262.0f;
	tableView.frame = CGRectMake(11.0f, lowestView.frame.origin.y + lowestView.frame.size.height + 2 * kTablePadding, tableWidth, tableHeight);
	
	for (UIView *sv in self.subviews) {
		// Move all Controls down
		if ([sv isKindOfClass:[UIControl class]]) {
			sv.frame = CGRectMake(sv.frame.origin.x, sv.frame.origin.y + tableExtHeight, sv.frame.size.width, sv.frame.size.height);
		}
	}
	
}
NSIndexPath	* lastIndexPath;
- (void)show{    
    NSLog(@"show");
	[self prepare];
    [super show];
}

- (void)prepare {
      NSLog(@"prepare");
	if (tableHeight == 0) {
		tableHeight = 150.0f;
	}
	
	tableExtHeight = tableHeight + 2 * kTablePadding;
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStylePlain];
	tableView.backgroundColor = [UIColor orangeColor];
	tableView.delegate = self;
	tableView.dataSource = self;	
	
	[self insertSubview:tableView atIndex:0];
	[self setNeedsLayout];
}

- (void)dealloc {
	[tableView release];
    [super dealloc];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    lastIndexPath=nil;
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [AppSession.arrayHistory count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
	
	NSUInteger row = [indexPath row];
	NSUInteger oldRow = [lastIndexPath row];
	cell.textLabel.text = [NSString stringWithFormat:@"%@",[AppSession.arrayHistory objectAtIndex:row]];
	cell.accessoryType = (row == oldRow && lastIndexPath != nil) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //	NSInteger row=[indexPath row];
    //	if (row==0) {
    //		cell.accessoryType = UITableViewCellAccessoryCheckmark;
    //		cell.textLabel.textColor=[UIColor redColor];
    //	}
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	return indexPath;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}


- (void) tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int newRow = [indexPath row];
	int oldRow = [lastIndexPath row];
    
	if ((lastIndexPath==nil) || (newRow != oldRow)){
		UITableViewCell *newCell = [_tableView cellForRowAtIndexPath:indexPath];
		newCell.accessoryType = UITableViewCellAccessoryCheckmark;
		newCell.textLabel.textColor=[UIColor redColor];
		
		UITableViewCell *oldCell = [_tableView cellForRowAtIndexPath: lastIndexPath]; 
		oldCell.accessoryType = UITableViewCellAccessoryNone;
		oldCell.textLabel.textColor=[UIColor blackColor];
		lastIndexPath = [indexPath retain];	
		
        AppSession.searchKeyword = newCell.textLabel.text;
		NSLog(@"-----text---,%@",newCell.textLabel.text);
	}else {
        UITableViewCell *newCell = [_tableView cellForRowAtIndexPath: lastIndexPath]; 
		newCell.accessoryType = UITableViewCellAccessoryNone;
		newCell.textLabel.textColor=[UIColor blackColor];		
        AppSession.searchKeyword = @"";
    }
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
