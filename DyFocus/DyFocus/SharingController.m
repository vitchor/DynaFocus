//
//  SharingController.m
//  DyFocus
//
//  Created by Victor Oliveira on 8/29/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "SharingController.h"

@implementation SharingController

@synthesize frames, focalPoints, fofName;

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
    
    self.navigationItem.title = @"Share";
    [self showSaveButton];
    commentField.layer.cornerRadius = 6.0;
}

-(void)viewWillAppear:(BOOL)animated{
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSString *facebookId = delegate.myself.facebookId;
    
    if (facebookId == (id)[NSNull null] || facebookId.length == 0) {
        
        [titleWithoutFb setHidden:NO];
        [shareOnFbLabel setEnabled:NO];
        [facebookSwitch setEnabled:NO];
    }
    else
    {
        [titleWithFb setHidden:NO];
    }
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate logEvent:@"SharingController.viewDidAppear"];
}

-(void)showSaveButton{
    
    NSString *save = @"Save";
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:save style:UIBarButtonItemStyleDone target:self action:@selector(save)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	[save release];
}

- (void) save {
    
    self.fofName = [NSString stringWithFormat:@"%f",CACurrentMediaTime()];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self showLoading];
    [self upload];
}

- (void) showLoading {
    [activityIndicator setHidden:NO];
    [self.view bringSubviewToFront:activityIndicator];
    [spinner startAnimating];
}

- (void) upload
{// unregister for keyboard notifications while not visible.
    
    NSURL *webServiceUrl = [NSURL URLWithString:[[[NSString alloc] initWithFormat: @"%@/uploader/upload_private_image/", dyfocus_url] autorelease]];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    NSString *fof_size = [[[NSString alloc] initWithFormat:@"%d",[self.frames count]] autorelease];
    NSString *userId = [NSString stringWithFormat:@"%ld",appDelegate.myself.uid];
    
    request = [[ASIFormDataRequest requestWithURL:webServiceUrl] retain];
    [request setDelegate:self];
    
    [request setPostValue:self.fofName forKey:@"fof_name"];
    [request setPostValue:fof_size forKey:@"fof_size"];
    [request setPostValue:userId forKey:@"user_id"];
    [request setPostValue:[NSNumber numberWithBool:isPrivate.on] forKey:@"is_private"];
    
    for (int i = 0; i < [self.frames count]; i++)
    {
        UIImage *image = [[self.frames objectAtIndex:i] fixOrientation];
        
        NSLog(@"Uploading image %d with size: %f %f ", i, image.size.width, image.size.height);
        
        
        NSString *imagePath = [[NSString alloc] initWithFormat:@"Documents/image_%d.jpg", i];
        
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:imagePath];
        
        // Write a UIImage to JPEG with minimum compression (best quality)
        [UIImageJPEGRepresentation(image, 0.5) writeToFile:jpgPath atomically:YES];
        
        NSString *photoPath = [NSHomeDirectory() stringByAppendingPathComponent:imagePath];
        
        
        // Add all the post values
        
        CGPoint touchPoint = [(NSValue *)[self.focalPoints objectAtIndex:i] CGPointValue];
        
        NSNumber *pointX = [[NSNumber alloc] initWithInt:touchPoint.x*100];
        NSNumber *pointY = [[NSNumber alloc] initWithInt:touchPoint.y*100];
        
        NSString *frameFocalPointX = [[NSString alloc] initWithFormat:@"frame_focal_point_x_%d", i];
        NSString *frameFocalPointY = [[NSString alloc] initWithFormat:@"frame_focal_point_y_%d", i];
        
        [request setPostValue:pointX forKey:frameFocalPointX];
        [request setPostValue:pointY forKey:frameFocalPointY];
        
        [pointX release];
        [pointY release];
        
        NSString *fileName = [[NSString alloc] initWithFormat:@"image_%d.jpeg", i];
        NSString *keyName = [[NSString alloc] initWithFormat:@"apiupload_%d", i];
        
        // Add the image file to the request
        [request setFile:photoPath withFileName:fileName andContentType:@"Image/jpeg" forKey:keyName];
        
        [fileName release];
        [keyName release];
        [frameFocalPointX release];
        [frameFocalPointY release];
        [imagePath release];
        //[fof_size release];
        
    }
    
    [request startAsynchronous];
    
    //request.responseString
    
    NSLog(@"MESSAGE %@",request.responseString);
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"REQUEST FINISHED");
    
    if (facebookSwitch.on) {
        [self shareWithFacebook];
    } else {
        //[self.navigationController popViewControllerAnimated:YES];
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate loadFeedTab];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [activityIndicator setHidden:YES];
    NSLog(@"REQUEST FAILED");
    
    self.navigationItem.rightBarButtonItem.enabled = true;
    
    NSString *alertTitle = @"Request Failed";
    NSString *alertMsg = @"Check your internet connection and try again.";
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertTitle release];
    [alertMsg release];
    [alertButton release];
}

- (void)requestRedirected:(ASIHTTPRequest *)request {
    [activityIndicator setHidden:YES];
    NSLog(@"REQUEST REDIRECTED");
}

-(void)shareWithFacebook {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    NSString *urlLink = [[NSString alloc] initWithFormat:@"%@/uploader/%@/share_fof/", dyfocus_url, self.fofName];
    
    NSString *message = commentField.text;
    
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"http://s3.amazonaws.com/dyfocus/%ld_%@_0.jpeg",appDelegate.myself.uid, self.fofName];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   urlLink, @"link",
                                   message,@"message",
                                   imageUrl,@"picture",
                                   nil];
    [urlLink release];
    [imageUrl release];
    
    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        [activityIndicator setHidden:YES];
        
        if (!error) {
            //[self.navigationController popViewControllerAnimated:YES];
            AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate loadFeedTab];
        } else {
            NSString *alertTitle = @"Connection Error";
            NSString *alertMsg = @"Failed to share link on your Facebook wall.";
            NSString *alertButton = @"OK";
            
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
            [alert show];
            
            [alertTitle release];
            [alertMsg release];
            [alertButton release];
            
        }
    }];    
    
}

-(void)keyboardWillShow:(NSNotification*)aNotification{
    
    [placeHolderLabel setHidden:YES];
    
    NSString *done = @"Done";
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:done style:UIBarButtonItemStyleDone target:self action:@selector(hidesKeyboard)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    [done release];
}

-(void)hidesKeyboard{
    [commentField resignFirstResponder]; // hides keyboard
    [self showSaveButton];
    
    if ([commentField.text  isEqual: @""]) {
        [placeHolderLabel setHidden:NO];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([self.navigationItem.rightBarButtonItem.title isEqual:@"Done"])
        [self hidesKeyboard];
    
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (request) {
        [request setDelegate:nil];
        [request cancel];
    }
}

-(void)dealloc
{
    [activityIndicator release];
    [spinner release];
    [commentField release];
    [placeHolderLabel release];
    [titleWithFb release];
    [titleWithoutFb release];
    [shareOnFbLabel release];
    [facebookSwitch release];
    [isPrivate release];
    
    [request release];
    
    [frames release];
    [focalPoints release];
    [fofName release];
    
    [super dealloc];
}

@end
