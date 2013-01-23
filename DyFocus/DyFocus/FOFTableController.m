//
//  FOFTableController.m
//  DyFocus
//
//  Created by Victor on 1/5/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "FOFTableController.h"
#import "FOFTableCell.h"
#import "AppDelegate.h"
#import "FOFTableCell.h"

@interface FOFTableController ()

@end

@implementation FOFTableController
@synthesize m_tableView, FOFArray;

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
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    m_tableView.backgroundView = backView;
    
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [backView release];
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIView *haeaderFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
	haeaderFooterView.backgroundColor = [UIColor clearColor];
	[m_tableView setTableHeaderView:haeaderFooterView];
	[m_tableView setTableFooterView:haeaderFooterView];
    
    [m_tableView setDataSource:self];
    [m_tableView setDelegate:self];

    m_tableView.backgroundColor = [UIColor clearColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshImages];
}


-(void) refreshImages {

    NSArray *visibleCells = [m_tableView visibleCells];

    NSLog(@"Going to refresh");
    
    if (visibleCells) {
       
        NSArray *visibleCellsCopy = [[NSArray alloc] initWithArray:visibleCells];
        
        for (FOFTableCell *cell in visibleCellsCopy) {
            
            // TODO CREATE CACHE
            //UIImage *image = [m_imageCache objectForKey:[NSNumber numberWithInt:cell.tag]];
            
            NSLog(@"LOADING IMAGE");
            [cell loadImages];
        }
        
        [visibleCellsCopy release];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return [FOFArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	FOFTableCell *cell = nil;
    
	tableView.backgroundColor = [UIColor clearColor];
	
	NSString *cellId = [NSString stringWithFormat:@"0_%d", indexPath.row];
    cell = [self.m_tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"FOFTableCell" owner:self options:nil];
		
		for(id currentObject in topLevelObjects){
			if ([currentObject isKindOfClass:[FOFTableCell class]]) {
				cell = (FOFTableCell *)currentObject;
				break;
			}
		}
        
    }
    
    //FOF *fof = (FOF *)[FOFArray objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	cell.backgroundColor = [UIColor redColor];
    
    cell.tableView = self;
    
    cell.row = indexPath.row;
    
    FOF *fof = (FOF *) [FOFArray objectAtIndex:indexPath.row];
    
    [cell refreshWithFof:fof];
    
	return cell;
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundView.backgroundColor = [UIColor redColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    NSNumber *height = (NSNumber *)[cellHeightDictionary objectForKey:[NSNumber numberWithInt:indexPath.row]];

    NSLog(@"HEIGHT: %d", [height intValue]);
    
    if ([height intValue] != 0) {
        return [height intValue];
    } else {
        return 334;
    }
    
    return [height intValue];
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self refreshImages];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate == NO) {
		[self refreshImages];
	}
}


-(void) addNewCellHeight:(float)height atRow:(int)row {
    
    if(!cellHeightDictionary) {
        cellHeightDictionary = [[NSMutableDictionary alloc] init];
    }
    
    [cellHeightDictionary setObject:[NSNumber numberWithFloat:height + 122] forKey:[NSNumber numberWithInt:row]];

    NSLog(@"NEWWW CELL HEIGHT! %f", height);
    
    [m_tableView beginUpdates];
    [m_tableView endUpdates];
}

@end