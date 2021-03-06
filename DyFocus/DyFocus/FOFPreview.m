
//  FOFPreview.m
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "FOFPreview.h"

@implementation FOFPreview

@synthesize frames, fixedFrames, focalPoints;

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
    
//    DyOpenCv *dyOpenCV = [DyOpenCv alloc];
//    self.fixedFrames = [dyOpenCV antiShake:self.frames];
//    [dyOpenCV release];
    
    [firstImageView setImage: [self.frames objectAtIndex:0]];
    
    if ([self.frames count] > 1) {
        [secondImageView setImage: [self.frames objectAtIndex:1]];
    }
    
    for (UIImage *frame in self.frames) {
        [displayedFrames addObject:frame];
    }
    
    oldFrameIndex = 0;
    timerPause = TIMER_INTERVAL;
    
    [firstTableView setDataSource:self];
    [secondTableView setDataSource:self];
    
    
    //[firstTableView selectRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    
    //[firstTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    //[secondTableView selectRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    [firstTableView setDelegate:self];
    [secondTableView setDelegate:self];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        UITapGestureRecognizer *tapfirstImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fofToFullScreen)];
        [firstImageView addGestureRecognizer:tapfirstImageView];
        [tapfirstImageView release];
        
        UITapGestureRecognizer *tapsecondImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fofToFullScreen)];
        [secondImageView addGestureRecognizer:tapsecondImageView];
        [tapsecondImageView release];
    }
    else{
        UITapGestureRecognizer *tapScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fofToFullScreen)];
        [scrollView addGestureRecognizer:tapScrollView];
        [tapScrollView release];
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //TODO start fade out timer
    timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL/10 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
    [timer fire];
    
    [scrollView setUserInteractionEnabled:YES];
    
    [playPauseButton setImage:[UIImage imageNamed:@"Pause-Button-NoStroke.png"] forState:UIControlStateNormal];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
    } else {
        
        CGSize size = ((UIImage *)[self.frames objectAtIndex:0]).size;
        
        CGFloat height = (size.height/size.width) * firstImageView.frame.size.width;
        
        [scrollView setContentSize:CGSizeMake(screenBounds.size.width, height)];
        
    }
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"FOFPreview.viewDidAppear"];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    timer = nil;
    [super viewWillDisappear:animated];
}

- (void) next
{
    if(!applyingFilter){
        SharingController *sharingController;
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            // code for 4-inch screen
            sharingController = [[SharingController alloc] initWithNibName:@"SharingController_i5" bundle:nil];
        } else {
            // code for 3.5-inch screen
            sharingController = [[SharingController alloc] initWithNibName:@"SharingController" bundle:nil];
        }
        
        sharingController.focalPoints = self.focalPoints;
        sharingController.frames = displayedFrames;
        if(self.fixedFrames)
            sharingController.matrixString = [[self.fixedFrames[2] copy] autorelease];
        
        [self.navigationController pushViewController:sharingController animated:true];
        [sharingController release];
    }
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

-(void)fofToFullScreen
{
    if(self.frames.count > 0){
        
        [scrollView setUserInteractionEnabled:NO];
        
        FullscreenFOFViewController *fullScreenController = [[FullscreenFOFViewController alloc] initWithNibName:@"FullscreenFOFViewController" bundle:nil];
        
        
        fullScreenController.hidesBottomBarWhenPushed = YES;
        
        fullScreenController.frames = displayedFrames;
        
        [UIView beginAnimations:@"View Flip" context:nil];
        [UIView setAnimationDuration:0.80];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [UIView setAnimationTransition:
         UIViewAnimationTransitionFlipFromRight
                               forView:self.navigationController.view cache:NO];
        
        
        [self.navigationController pushViewController:fullScreenController animated:YES];
        [UIView commitAnimations];
        
        
        [fullScreenController release];
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!applyingFilter){
        applyingFilter = true;
        
        if (tableView == firstTableView) {
            UIImage *filteredImage = [UIImage imageWithData:UIImageJPEGRepresentation([FilterUtil filterImage:[self.frames objectAtIndex:0] withFilterId:indexPath.row], 1.0)];
            
            if(displayedFrames[0]){
                [displayedFrames replaceObjectAtIndex:0 withObject:filteredImage];
            }else{
                [displayedFrames setObject:filteredImage atIndexedSubscript:0];
            }
        } else if (tableView == secondTableView) {
            UIImage *filteredImage = [UIImage imageWithData:UIImageJPEGRepresentation([FilterUtil filterImage:[self.frames objectAtIndex:1] withFilterId:indexPath.row], 1.0)];
            if(displayedFrames[1]){
                [displayedFrames replaceObjectAtIndex:1 withObject:filteredImage];
            }else{
                [displayedFrames setObject:filteredImage atIndexedSubscript:1];
            }
        }
        applyingFilter = false;
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIHorizontalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UIHorizontalTableViewCell"];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"UIHorizontalTableViewCell" owner:self options:nil];
        
        // Load the top-level objects from the custom cell XIB.
        cell = [topLevelObjects objectAtIndex:0];
        
        topLevelObjects = nil;
    }
    
    NSString *filterName = [FilterUtil getFilterName:indexPath.row];
    
    NSString *filterImageName = [NSString stringWithFormat:@"Filter_%@.jpg", filterName];

    [cell refreshWithImage:filterImageName andTitle:filterName];
    
    filterName = nil;
    filterImageName = nil;
    
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor colorWithRed:0.28 green:0.28 blue:0.28 alpha:1];
    cell.selectedBackgroundView = myBackView;
    
    [myBackView release];
    
    return cell;
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

- (void)fadeImages
{
    if (firstImageView.alpha >= 1.0) {
        
        if (timerPause > 0) {
            timerPause -= 1;
            
        } else {
            
            timerPause = TIMER_PAUSE;
            
            if (oldFrameIndex >= [self.frames count] - 1) {
                oldFrameIndex = 0;
            } else {
                oldFrameIndex += 1;
            }
            
            [secondImageView setImage:[displayedFrames objectAtIndex:oldFrameIndex]];
            
            [secondImageView setNeedsDisplay];
            
            [firstImageView setAlpha:0.0];
            
            [firstImageView setNeedsDisplay];
            
            int newIndex;
            if (oldFrameIndex == [self.frames count] - 1) {
                newIndex = 0;
            } else {
                newIndex = oldFrameIndex + 1;
            }
            
            [firstImageView setImage: [displayedFrames objectAtIndex:newIndex]];
        }
        
    } else {
        [firstImageView setAlpha:firstImageView.alpha + 0.01];
    }
    
}

- (IBAction)playPauseAction:(UIButton *)sender {
    
    if (timer)
    {
        [timer invalidate];
        timer = nil;
        
        [playPauseButton setImage:[UIImage imageNamed:@"Play-Button-NoStroke.png"] forState:UIControlStateNormal];
    }
    else
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL/10 target:self selector:@selector(fadeImages) userInfo:nil repeats:YES];
        [timer fire];
        
        [playPauseButton setImage:[UIImage imageNamed:@"Pause-Button-NoStroke.png"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
    [playPauseButton release];
    [firstImageView release];
    [secondImageView release];
    [scrollView release];
    
    [firstTableView setDataSource:nil];
    [firstTableView reloadData];
    [firstTableView release];
    firstTableView = nil;
    
    [secondTableView setDataSource:nil];
    [secondTableView reloadData];
    [secondTableView release];
    secondTableView = nil;

    [timer release];
    [fofName release];
    [displayedFrames release];
    
    [frames release];
    [fixedFrames release];
    [focalPoints release];
    
    [super dealloc];
}

@end
