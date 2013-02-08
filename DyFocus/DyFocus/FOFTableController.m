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
#import "JSON.h"

@interface FOFTableController ()

@end

@implementation FOFTableController
@synthesize m_tableView, FOFArray, shouldHideNavigationBar, refreshString, userFacebookId;

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
    
    if (refreshHeaderView == nil) {
        
        refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - m_tableView.bounds.size.height, 320.0f, m_tableView.bounds.size.height)];
        
        refreshHeaderView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        refreshHeaderView.bottomBorderThickness = 1.0;
        
        [refreshHeaderView setCurrentDate];
        
        [m_tableView addSubview:refreshHeaderView];
        m_tableView.showsVerticalScrollIndicator = YES;
        
        [refreshHeaderView release];
    }
    
    [backView release];
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIView *haeaderFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)] autorelease];
	haeaderFooterView.backgroundColor = [UIColor clearColor];
	[m_tableView setTableHeaderView:haeaderFooterView];
	[m_tableView setTableFooterView:haeaderFooterView];
    
    [m_tableView setDataSource:self];
    [m_tableView setDelegate:self];

    m_tableView.backgroundColor = [UIColor clearColor];
    
    [self.navigationController setNavigationBarHidden:shouldHideNavigationBar];
    
    if (!(FOFArray && [FOFArray count] > 0)) {
        [m_tableView setHidden:YES];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [m_tableView reloadData];
    
    [self refreshCellsImageSizes];
    [self refreshImages];
}

-(void) refreshCellsImageSizes {
        
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

-(void) refreshImages {

    NSArray *visibleCells = [m_tableView visibleCells];
    
    if (visibleCells) {
    
        NSArray *visibleCellsCopy = [[NSArray alloc] initWithArray:visibleCells];
        
        for (FOFTableCell *cell in visibleCellsCopy) {
            
            [cell refreshImageSize];
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
	
	//NSString *cellId = [NSString stringWithFormat:@"FOFTableCell", indexPath.row];
    cell = [self.m_tableView dequeueReusableCellWithIdentifier:@"FOFTableCell"];
    
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"FOFTableCell" owner:self options:nil];
		
        // Load the top-level objects from the custom cell XIB.
        cell = [topLevelObjects objectAtIndex:0];
        
    }
    
    //FOF *fof = (FOF *)[FOFArray objectAtIndex:indexPath.row];
    

    cell.tableView = self;
    
    cell.row = indexPath.row;

    FOF *fof = (FOF *) [self.FOFArray objectAtIndex:indexPath.row];
    
    [cell refreshWithFof:fof];
    
    [cell refreshImageSize];
    
	return cell;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundView.backgroundColor = [UIColor redColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    NSNumber *height = (NSNumber *)[cellHeightDictionary objectForKey:[NSNumber numberWithInt:indexPath.row]];
    
    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)dataSourceDidFinishLoadingNewData{
    
	_reloading = NO;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[m_tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
    
	[refreshHeaderView setState:EGOOPullRefreshNormal];
    [refreshHeaderView setCurrentDate];
}

- (void) reloadTableViewDataSource {
    
	NSLog(@"Please override reloadTableViewDataSource");
    
    [self refreshWithAction:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self refreshCellsImageSizes];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate == NO) {
		[self refreshCellsImageSizes];
	}
    
    if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		m_tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
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

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	refreshHeaderView=nil;
}

-(void) refreshWithAction:(BOOL)isAction {
    
    if (!isAction) {
        [refreshHeaderView setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        m_tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:refreshString]];
    
    NSMutableDictionary *jsonRequestObject = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if (userFacebookId) {
        [jsonRequestObject setObject:userFacebookId forKey:@"user_facebook_id"];
        
    } else {
        [jsonRequestObject setObject:[delegate.myself objectForKey:@"id"] forKey:@"user_facebook_id"];
    }

    
    
    NSString *json = [(NSObject *)jsonRequestObject JSONRepresentation];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[NSString stringWithFormat:@"json=%@",
                           json] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if(!error && data) {
                                   
                                   NSString *stringReply = [(NSString *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                   
                                   NSLog(@"stringReply: %@", stringReply);
                                   
                                   NSDictionary *jsonValues = [stringReply JSONValue];
                                   
                                   if (jsonValues) {
                                       NSDictionary * jsonFOFs = [jsonValues valueForKey:@"fof_list"];
                                       
                                    
                                       
                                       NSMutableArray *fofs = [NSMutableArray array];
                                       
                                       for (int i = 0; i < [jsonFOFs count]; i++) {
                                           
                                           NSDictionary *jsonFOF = [jsonFOFs objectAtIndex:i];
                                           
                                           FOF *fof = [[FOF fofFromJSON:jsonFOF] autorelease];
                                           
                                           [fofs addObject:fof];
                                           
                                       }
                                       
                                       [self.FOFArray removeAllObjects];
                                       [self.FOFArray addObjectsFromArray:fofs];
                                       
                                       
                                       [refreshHeaderView setCurrentDate];
                                       
                                       //if (isAction) {
                                       [self dataSourceDidFinishLoadingNewData];
                                       
                                       [m_tableView reloadData];
                                       [self refreshCellsImageSizes];
                                   }
                               }
                           }];
    
}

@end
