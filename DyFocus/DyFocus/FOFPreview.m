
//  FOFPreview.m
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "FOFPreview.h"
#import "ASIFormDataRequest.h"
#import "SharingController.h"
#import "AppDelegate.h"
#import "FilterUtil.h"

#import "GPUImage.h"

#define CANCEL 0
@implementation FOFPreview

@synthesize firstImageView,secondImageView, frames, focalPoints, timer, firstTableView, secondTableView, displayedFrames, scrollView;

#define TIMER_INTERVAL 0.1;
#define TIMER_PAUSE 10.0 / TIMER_INTERVAL;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    displayedFrames = [[NSMutableArray alloc] init];
    
    NSString *doneString = @"Next";
	UIBarButtonItem *continueButton = [[UIBarButtonItem alloc]
									   initWithTitle:doneString style:UIBarButtonItemStyleDone target:self action:@selector(next)];
	self.navigationItem.rightBarButtonItem = continueButton;
	[continueButton release];
	[doneString release];
    

    NSString *cancelString = @"Cancel";
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									   initWithTitle:cancelString style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Preview";
    
    [self.firstImageView setImage: [self.frames objectAtIndex:0]];
    [firstImageViewFullScreen setImage:[self.frames objectAtIndex:0]];
    
    if ([self.frames count] > 1) {
        [self.secondImageView setImage: [self.frames objectAtIndex:1]];
    }
    
    for (UIImage *frame in frames) {
        [displayedFrames addObject:frame];
    }
    
    oldFrameIndex = 0;
    timerPause = TIMER_INTERVAL;
    
    [firstTableView setDataSource:self];
    [secondTableView setDataSource:self];
    
    
    //[firstTableView selectRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    
    [firstTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    //[secondTableView selectRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    [firstTableView setDelegate:self];
    [secondTableView setDelegate:self];    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
    } else {
        isFullScreen = false;
        
        tapScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgToFullScreen)];
        tapScrollView.delegate = self;
        
        tapFullScreenView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgToFullScreen)];
        tapFullScreenView.delegate = self;
        
        [scrollView addGestureRecognizer:tapScrollView];
        [scrollView setUserInteractionEnabled:YES];
        [fullScreenView addGestureRecognizer:tapFullScreenView];
        [fullScreenView setUserInteractionEnabled:NO];
    }

}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [FilterUtil getFiltersSize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIHorizontalTableViewCell *cell;
    
    //NSString *cellId = [NSString stringWithFormat:@"FOFTableCell", indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:@"UIHorizontalTableViewCell"];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"UIHorizontalTableViewCell" owner:self options:nil];
        
        // Load the top-level objects from the custom cell XIB.
        cell = [topLevelObjects objectAtIndex:0];
        
    }
    
    //FOF *fof = (FOF *)[FOFArray objectAtIndex:indexPath.row];
    NSString *filterName = [FilterUtil getFilterName:indexPath.row];
    
    NSString *filterImageName = [NSString stringWithFormat:@"Filter_%@.jpg", filterName];

    [cell refreshWithImage:filterImageName andTitle:filterName];
    
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor colorWithRed:0.28 green:0.28 blue:0.28 alpha:1];
    cell.selectedBackgroundView = myBackView;
    [myBackView release];
    
    return cell;

}

- (void) next {
    SharingController *sharingController;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        sharingController = [[SharingController alloc] initWithNibName:@"SharingController_i5" bundle:nil];
    } else {
        // code for 3.5-inch screen
        sharingController = [[SharingController alloc] initWithNibName:@"SharingController" bundle:nil];
    }
    
    sharingController.focalPoints = focalPoints;
    sharingController.frames = displayedFrames;
    
    [self.navigationController pushViewController:sharingController animated:true];
    
    [sharingController release];
}


- (void)fadeImages
{
    if (self.firstImageView.alpha >= 1.0) {
        
        if (timerPause > 0) {
            timerPause -= 1;
            
        } else {
            
            timerPause = TIMER_PAUSE;
            
            if (oldFrameIndex >= [self.displayedFrames count] - 1) {
                oldFrameIndex = 0;
            } else {
                oldFrameIndex += 1;
            }
            
            
            [self.secondImageView setImage:[self.displayedFrames objectAtIndex:oldFrameIndex]];
            [secondImageViewFullScreen setImage:[self.displayedFrames objectAtIndex:oldFrameIndex]];
            
            [self.secondImageView setNeedsDisplay];
            [secondImageViewFullScreen setNeedsDisplay];
            
            [self.firstImageView setAlpha:0.0];
            [firstImageViewFullScreen setAlpha:0.0];
            
            [self.firstImageView setNeedsDisplay];
            [firstImageViewFullScreen setNeedsDisplay];
            
            int newIndex;
            if (oldFrameIndex == [self.displayedFrames count] - 1) {
                newIndex = 0;
            } else {
                newIndex = oldFrameIndex + 1;
            }
            
            [self.firstImageView setImage: [self.displayedFrames objectAtIndex: newIndex]];
            [firstImageViewFullScreen setImage: [self.displayedFrames objectAtIndex: newIndex]];
        }
            
    } else {
        [self.firstImageView setAlpha:self.firstImageView.alpha + 0.01];
        [firstImageViewFullScreen setAlpha:firstImageView.alpha];
    }
    
}

- (void)viewDidUnload
{

    [self dealloc];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
    } else {
        
        CGSize size = ((UIImage *)[frames objectAtIndex:0]).size;
        
        CGFloat height = (size.height/size.width) * firstImageView.frame.size.width;
        
        [scrollView setContentSize:CGSizeMake(320, height + 18)];
    }
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"FOFPreview.viewDidAppear"];
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == firstTableView) {
        
        UIImage *filteredImage = [FilterUtil filterImage:[frames objectAtIndex:0] withFilterId:indexPath.row];
        
        [self.displayedFrames setObject:filteredImage atIndexedSubscript:0];
        
    } else if (tableView == secondTableView) {
        
        UIImage *filteredImage = [FilterUtil filterImage:[frames objectAtIndex:1] withFilterId:indexPath.row];

        
        [self.displayedFrames setObject:filteredImage atIndexedSubscript:1];
        
    }
	
}

- (void) dealloc
{
    //for (UIImage *frame in self.frames) {
    //    [frame release];
    //}
    
    //for (NSValue *point in self.focalPoints) {
    //    [point release];
    //}
    
    [displayedFrames release];
    [frames release];
    [focalPoints release];
    [firstImageView release];
    [secondImageView release];
    [tapScrollView release];
    [tapFullScreenView release];
    [firstImageViewFullScreen release];
    [secondImageViewFullScreen release];
    [scrollView release];
    [fullScreenView release];
    
    [firstTableView release];
    [secondTableView release];
    [timer release];
    [fofName release];

    [super dealloc];
}

- (void) cancel {
	NSString *alertTitle = @"Cancel?";
	NSString *alertMsg =@"You'll lose the picture that you've taken. Are you sure?";
	NSString *alertButton1 = @"Yes";
	NSString *alertButton2 =@"No";
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton1 otherButtonTitles:nil] autorelease];
    // optional - add more buttons:
	[alert setTag:CANCEL];
    [alert addButtonWithTitle:alertButton2];
    [alert show];
	
	[alertTitle release];
	[alertMsg release];
	[alertButton1 release];
	[alertButton2 release];
	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == CANCEL) {
        if (buttonIndex == 0) {
			[self.navigationController popViewControllerAnimated:YES];
        }
    }
}

    

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    //TODO start fade out timer
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
    [timer fire];
    [super viewWillAppear:animated];
//    [fullScreenView setHidden:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    timer = nil;
    [super viewWillDisappear:animated];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    BOOL shouldReceiveTouch = YES;
    
    if (gestureRecognizer == tapScrollView || gestureRecognizer==tapFullScreenView) {
         shouldReceiveTouch = (touch.view == scrollView || touch.view == fullScreenView);
    }
    
    return shouldReceiveTouch;
}

-(void)imgToFullScreen{
    
    if (!isFullScreen) {
            [fullScreenView setHidden:NO];
            [fullScreenView setUserInteractionEnabled:YES];
            isFullScreen = true;
        return;
    }
    else{
            [fullScreenView setHidden:YES];
            [fullScreenView setUserInteractionEnabled:NO];
            isFullScreen = false;;
        return;
    }
}

@end
