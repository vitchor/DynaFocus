//
//  SharingController.m
//  DyFocus
//
//  Created by Victor Oliveira on 8/29/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "SharingController.h"
#import <FacebookSDK/FacebookSDK.h>
#import"AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "LoadView.h"
#import "UIImage+fixOrientation.h"

@interface SharingController ()

@end

@implementation SharingController

@synthesize facebookSwitch, isPrivate, activityIndicator, commentField, frames, focalPoints, spinner, backButton, fofName, fofUserFbId, titleMessage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction) toggleEnabledForSwitch: (id) sender{

    if (facebookSwitch.on) {
        [commentField setHidden:NO];
        [placeHolderLabel setHidden:NO];
    }else{
        [placeHolderLabel setHidden:YES];
        [commentField setHidden:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    [delegate logEvent:@"SharingController.viewDidAppear"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Share";
 
    NSString *share = @"Save";
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:share style:UIBarButtonItemStyleDone target:self action:@selector(share)];
	self.navigationItem.rightBarButtonItem = shareButton;
	[shareButton release];
	[share release];
    
    backButton = self.navigationItem.leftBarButtonItem;
    commentField.layer.cornerRadius = 6.0;
    [placeHolderLabel setHidden:YES];
    [commentField setHidden:YES];
}


- (void) share {
    self.fofName = [[NSString alloc] initWithFormat:@"%f",CACurrentMediaTime()];
    
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    [self showLoading];
        
    [self upload];
}

- (void) showLoading {
    [activityIndicator setHidden:NO];
    [self.view bringSubviewToFront:activityIndicator];
    [spinner startAnimating];
}

-(void)shareWithFacebook {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    NSString *urlLink = [[NSString alloc] initWithFormat:@"%@/uploader/%@/share_fof/", dyfocus_url, fofName];
    
    NSString *message = self.commentField.text;
    
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"http://s3.amazonaws.com/dyfocus/%ld_%@_0.jpeg",appDelegate.myself.uid, fofName];
    
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
            facebookSwitch.on = false;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) upload
{// unregister for keyboard notifications while not visible.

    
    [commentField resignFirstResponder]; // hides keyboard
    
    NSURL *webServiceUrl = [NSURL URLWithString:[[[NSString alloc] initWithFormat: @"%@/uploader/upload_private_image/", dyfocus_url] autorelease]];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    NSString *fof_size = [[[NSString alloc] initWithFormat:@"%d",[self.frames count]] autorelease];
    NSString *userId = [NSString stringWithFormat:@"%ld",appDelegate.myself.uid];
    
    request = [[ASIFormDataRequest requestWithURL:webServiceUrl] retain];
    [request setDelegate:self];
    
    [request setPostValue:fofName forKey:@"fof_name"];
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
        
        CGPoint touchPoint = [(NSValue *)[focalPoints objectAtIndex:i] CGPointValue];
        
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
        [commentField setHidden:NO];
        [self shareWithFacebook];
    } else {
        //[self.navigationController popViewControllerAnimated:YES];
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate loadFeedTab];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
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

-(void)viewWillAppear:(BOOL)animated{
    
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSString *facebookId = delegate.myself.facebookId;
    
   if (facebookId == (id)[NSNull null] || facebookId.length == 0) {
       
       [shareLabel setHidden:YES];
       [facebookSwitch setHidden:YES];
       
       [titleMessage setText:@"The option to synchronize your account to social medias is coming soon, stay tuned."];
       
   }
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];    
}

-(void)hidesKeyboard{
    self.commentField.text = @"";
    
    CGRect myTextViewFrame = [self.commentField frame];
    myTextViewFrame.origin.y -= -230;
    myTextViewFrame.origin.x -= -25;
    myTextViewFrame.size.height -= 90 ;
    myTextViewFrame.size.width -= 50 ;
    
    [self.commentField setFrame:myTextViewFrame];
    
    [commentField resignFirstResponder]; // hides keyboard
    self.navigationItem.leftBarButtonItem = backButton;
    
    [facebookSwitch setHidden:NO];
    [isPrivate setHidden:NO];
    [shareLabel setHidden:NO];
    [placeHolderLabel setHidden:NO];
}

-(void)keyboardWillShow:(NSNotification*)aNotification{
    
    [placeHolderLabel setHidden:YES];
    [facebookSwitch setHidden:YES];
    [isPrivate setHidden:YES];
    [shareLabel setHidden:YES];
    
    self.commentField.text = @"";
    
    CGRect myTextViewFrame = [self.commentField frame];
    myTextViewFrame.origin.y += -230;
    myTextViewFrame.origin.x += -25;
    myTextViewFrame.size.height += 90 ;
    myTextViewFrame.size.width += 50 ;
    
    [self.commentField setFrame:myTextViewFrame];
    
    NSString *cancel = @"Cancel";
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:cancel style:UIBarButtonSystemItemCancel target:self action:@selector(hidesKeyboard)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];    
    if (request) {
        [request setDelegate:nil];
        [request cancel];
        [request release];
    }
}

-(void) facebookError
{
    facebookSwitch.on = false;
    NSString *alertTitle = @"Connection Error";
    NSString *alertMsg = @"Failed to connect to Facebook.";
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];
    
    [alertTitle release];
    [alertMsg release];
    [alertButton release];
    
}

-(void)dealloc
{
    [frames release];
    [focalPoints release];
    [fofName release];
    [shareLabel release];
    [facebookSwitch release];
    [isPrivate release];
    [activityIndicator release];
    [spinner release];
    [commentField release];
    [placeHolderLabel release];
    [super dealloc];
}

@end
