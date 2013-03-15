//
//  FirstViewController.m
//  DynaFocus
//
//  Created by Marcia  Rozenfeld on 7/10/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "CameraView.h"
#import "FOFPreview.h"
#import "PathView.h"
#import "ASIFormDataRequest.h"
#import "iToast.h"
#import "AppDelegate.h"
#import "ImageUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"
#import "UIDevice+Hardware.h"
#import "DyfocusSettings.h"

@implementation CameraView

@synthesize cameraView, pathView, shootButton, cancelButton, infoButton, infoView, getStartedButton, mFocalPoints, popupCloseButton, popupView, spinner, loadingView, popupDarkView, torchOneButton, torchTwoButton, instructionsImageView;

- (void)updateFocusPoint {
    NSLog(@"UPDATE POINT: %d", mFOFIndex);
    NSError *error = nil;
    
    if ([mCaptureDevice lockForConfiguration:&error]) {
        
        if (mFOFIndex > 0) {
            NSLog(@"On Focus Update - current value for torchOnFocusPoints: %d",torchOnFocusPoints);
            if (torchOnFocusPoints == 2 || torchOnFocusPoints == 3) {
                NSLog(@"Turning freaking torch on!");
                isTorchOn = false;
                [self setTorchOn:!isTorchOn];
            } else {
                NSLog(@"Turning freaking torch off!");
                isTorchOn = true;
                [self setTorchOn:!isTorchOn];
            }
            
            torchOnFocusPoints = 0;
        }
        
    
        if ([mCaptureDevice isExposurePointOfInterestSupported]) {
            [mCaptureDevice setExposurePointOfInterest:[[mFocalPoints objectAtIndex:mFOFIndex] CGPointValue]];
            
        } else {
            [self sendErrorReportWithMessage:@"CameraView.updateFocusPoint - exposure point is not supported!!"];
        }
        
        if ([mCaptureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [mCaptureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            
        } else if ([mCaptureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [mCaptureDevice setFocusMode:AVCaptureExposureModeAutoExpose];
            
        } else {
            [self sendErrorReportWithMessage:@"CameraView.updateFocusPoint - exposure mode is not supported!!"];
        }
        
        if ([mCaptureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [mCaptureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];

        } else {
            //[self sendErrorReportWithMessage:@"CameraView.updateFocusPoint - exposure mode is not supported!!"];
        }
        

        if ([mCaptureDevice isFocusPointOfInterestSupported]) {
            [mCaptureDevice setFocusPointOfInterest:[[mFocalPoints objectAtIndex:mFOFIndex] CGPointValue]];
            
        } else {
            [self sendErrorReportWithMessage:@"CameraView.updateFocusPoint - focus point is not supported!!"];
            [self disablePictureTaking];
        }
        if ([mCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [mCaptureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            
        } else {
            [self sendErrorReportWithMessage:@"CameraView.updateFocusPoint - focus mode is not supported!!"];
            [self disablePictureTaking];
        }
        
        // Releases the lock
        [mCaptureDevice unlockForConfiguration];
    } else {
        [self sendErrorReportWithMessage:@"CameraView.updateFocusPoint - mCaptureDevice couldn't be locked"];
    }

}

- (void)disablePictureTaking {
    if (self.navigationItem.rightBarButtonItem.enabled) {
        [shootButton setEnabled:false];
        [infoButton setEnabled:false];
        [cancelButton setEnabled:false];
        
        [self showOkAlertWithMessage:@"Your device does not support focus point settings." andTitle:@"Sorry"];
    }
}


- (void)startCaptureSession {
	
    // Create Session
    captureSession = [[AVCaptureSession alloc] init];
    
    NSString *device = [[UIDevice currentDevice] platform];
    
    if ([device isEqualToString:@"iPhone1,1"] || [device isEqualToString:@"iPhone1,2"] || [device isEqualToString:@"iPhone2,1"] || [device isEqualToString:@"iPhone3,1"] || [device isEqualToString:@"iPhone3,2"] || [device isEqualToString:@"iPhone3,3"]) {
        
        //Device is older than iPhone 4s
        
        if ([captureSession canSetSessionPreset: AVCaptureSessionPresetHigh]) {
            [captureSession setSessionPreset:AVCaptureSessionPresetHigh];
            captureSession.sessionPreset = AVCaptureSessionPresetHigh;
            
        } else if ([captureSession canSetSessionPreset: AVCaptureSessionPresetMedium]) {
            [captureSession setSessionPreset:AVCaptureSessionPresetMedium];
            captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        }
        
    } else {
        
        // Device is iPhone 4s or 5
        
        if ([captureSession canSetSessionPreset: AVCaptureSessionPreset1920x1080]) {
            [captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
            captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
            
        } else if ([captureSession canSetSessionPreset: AVCaptureSessionPresetHigh]) {
            [captureSession setSessionPreset:AVCaptureSessionPresetHigh];
            captureSession.sessionPreset = AVCaptureSessionPresetHigh;
            
        }
    }
    
    
    // Find CaptureDevice
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices){
        if ([device hasMediaType:AVMediaTypeVideo]){
            if ([device position] == AVCaptureDevicePositionBack) {
                mCaptureDevice = device;
                break;
            }
        }
        
    }
    if (!mCaptureDevice) {
        [self sendErrorReportWithMessage:@"CameraView.startCaptureSession - couldn't find an AVCaptureDevice with AVMediaTypeVideo, AVCaptureDevicePositionBack"];
    }
    
    
    // Set initial focus point
    [self updateFocusPoint];
    
    // Create and add DeviceInput to Session
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:mCaptureDevice error:&error];
    
    if ([captureSession canAddInput:deviceInput]) {
        [captureSession addInput:deviceInput];
    } else {
        [self sendErrorReportWithMessage:@"CameraView.startCaptureSession - couldn't add the device input to the actual AVCaptureSession"];
    }
    
    // Create/add StillImageOutput, get connection and add handler
    NSMutableDictionary *outputSettings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    

    mStillImageOutput = [[AVCaptureStillImageOutput alloc] init];

    [mStillImageOutput setOutputSettings:outputSettings];

    [captureSession addOutput:mStillImageOutput];

    
    
    //Get connection
    mVideoConnection = nil;

    for (AVCaptureConnection *connection in mStillImageOutput.connections) {

        for (AVCaptureInputPort *port in [connection inputPorts]) {

            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {

                mVideoConnection = connection;
                break;
            }
        }
        
        if (mVideoConnection) {break;}
    }
    
    
    if (!mVideoConnection) {
         [self sendErrorReportWithMessage:@"CameraView.startCaptureSession - couldn't get a AVCaptureConnection with a port that is equal to AVMediaTypeVideo"];
    }

    [captureSession startRunning];

    // Showing preview layer
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];

    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    layer.frame = self.cameraView.frame;
    NSLog(@"CameraView is ready");
    [self.cameraView.layer addSublayer:layer];
    NSLog(@"CameraView is added");

    [spinner stopAnimating];
    [loadingView setHidden:YES];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        
        NSLog(@"ADJUSTING FOCUS");
        
        if(!adjustingFocus) {
            NSLog(@"FOCUS IS GOOD");
            
            // Capture with handler
            NSLog(@"TAKING PICTURE...");
            
            [self capture];
            

        }
    }
}


- (void) capture {
    if (mVideoConnection && [mVideoConnection isVideoOrientationSupported]){
        [mVideoConnection setVideoOrientation:[UIDevice currentDevice].orientation];
    }
    
    if (mStillImageOutput) {
        
        [mStillImageOutput captureStillImageAsynchronouslyFromConnection:mVideoConnection completionHandler:
         ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
             
             if (error) {
                 [self sendErrorReportWithMessage:error.localizedDescription];
                 [self showOkAlertWithMessage:@"The app is not ready to take pictures on your device yet, we're releasing an update soon. Please excuse us :( " andTitle:@"Sorry"];
                 
             } else {
                 CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                 
                 if (exifAttachments) {
                     
                     NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                     UIImage *image = [[[UIImage alloc] initWithData:imageData] autorelease];
                     
                     
                     if ((image.size.height == 1920.00 && image.size.width == 1080.00) || (image.size.height == 1080.00 && image.size.width == 1920.00)) {
                        
                         CGRect rect = CGRectMake(155,
                                                  0,
                                                  1475,
                                                  1080);
                         
                         CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
                         image = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:image.imageOrientation];
                         CGImageRelease(imageRef);
                             
                         
                     } else if ((image.size.height == 720.00 && image.size.width == 1280.00) || (image.size.height == 1280.00 && image.size.width == 720.00)) {
                         
                         CGRect rect = CGRectMake(103,
                                                  0,
                                                  983,
                                                  720);

                         
                         CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
                         image = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:image.imageOrientation];
                         CGImageRelease(imageRef);
                         
                     }
                     
                     [image retain];
                     
                     [mFrames addObject:image];
                     
                     NSLog(@"DONE! ");
                     
                     mFOFIndex = mFOFIndex + 1;
                     
                     if (mFOFIndex < [mFocalPoints count]) {
                         [self updateFocusPoint];
                     } else {
                         NSLog(@" FINISHED PICTURE");
                         
                         isTorchOn = true;
                         [self setTorchOn:!isTorchOn];
                         
                         pathView.enabled = true;
                         
                         FOFPreview *FOFpreview = [[FOFPreview alloc] initWithNibName:@"FOFPreview" bundle:nil];
                         
                         FOFpreview.frames = mFrames;
                         FOFpreview.focalPoints = mFocalPoints;
                         
                         for (UIImage *frame in mFrames) {
                             [frame release];
                         }
                         
                         if (isObserving) {
                             [mCaptureDevice removeObserver:self forKeyPath:@"adjustingFocus"];
                             isObserving = NO;
                         }
                         
                         [self.navigationController pushViewController:FOFpreview animated:true];
                         
                         [FOFpreview release];
                     }
                     
                 }
             }
             
         }];
    } else {
        [self sendErrorReportWithMessage:@"CameraView.observeValueForKeyPath - the ImageOutput was null when using it to capture."];
    }
}

-(void) torchToggle {

    isTorchOn = !isTorchOn;
    [self setTorchOn:isTorchOn];
}

// Logic for variable torchOnFocusPoints:
// 0: no torch on any point
// 1: torch on focus point 1
// 2: torch on focus point 2
// 3: torch on both focus points

-(void) toggleTorchForFocusOne {
    if (torchOnFocusPoints == 1 || torchOnFocusPoints == 3) {
        // torch for focus point 1 is on, turn it off immediately
        isTorchOn = true;
        [self setTorchOn:!isTorchOn];
        torchOnFocusPoints -= 1;
    } else if (torchOnFocusPoints == 0 || torchOnFocusPoints == 2) {
        // torch for focus point 1 is off, turn it on immediately
        torchOnFocusPoints += 1;
        isTorchOn = false;
        [self setTorchOn:!isTorchOn];
    } else {
        torchOnFocusPoints = 1;
        isTorchOn = false;
        [self setTorchOn:!isTorchOn];
    }
    NSLog(@"Current value for torchOnFocusPoints: %d",torchOnFocusPoints);
}

-(void) toggleTorchForFocusTwo {
    if (torchOnFocusPoints == 2 || torchOnFocusPoints == 3) {
        // torch for focus point 2 is on, turn it off when taking second pic
        torchOnFocusPoints -= 2;
    } else if (torchOnFocusPoints == 0 || torchOnFocusPoints == 1) {
        // torch for focus point 2 is off, turn it on when taking second pic
        torchOnFocusPoints += 2;
    }
    NSLog(@"Current value for torchOnFocusPoints: %d",torchOnFocusPoints);
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    pathView.enabled = true;
    isObserving = false;
    
//    shootButton.target = self;
//    [shootButton setAction:@selector(addObserverToFocus)];
//    
//    infoButton.target = self;
//    [infoButton setAction:@selector(showInfoView)];
//    
//    cancelButton.target = self;
//    [cancelButton setAction:@selector(goBackToLastController)];

    
    [torchOneButton addTarget:self action:@selector(toggleTorchForFocusOne) forControlEvents:UIControlEventTouchUpInside];
    [torchTwoButton addTarget:self action:@selector(toggleTorchForFocusTwo) forControlEvents:UIControlEventTouchUpInside];
    
    [getStartedButton addTarget:self action:@selector(hideInfoView) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *redButtonImage = [UIImage imageNamed:@"close.png"];
    
    [popupCloseButton setBackgroundImage:redButtonImage forState:UIControlStateNormal];
    [popupCloseButton addTarget:self action:@selector(closePopup) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:)name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [super viewDidLoad];
}

-(void)closePopup {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logEvent:@"Close Pop Up"];
    
    [popupView setHidden:YES];
}

-(void)hideInfoView
{
    [infoView setHidden:YES];
}

-(void)showInfoView
{
    [popupView setHidden:YES];
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logEvent:@"Show Info View Button"];
    
    if (mToastMessage) {
        [mToastMessage removeToast:nil];
        mToastMessage = nil;
    }
    [infoView setHidden:NO];
}

-(void)goBackToLastController
{
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate goBackToLastController];
}

-(void)clearPoints
{
    [pathView clearPoints];
    
//    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
//    [appDelegate logEvent:@"Clear Points Button"];
}

-(void)addObserverToFocus
{
    
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logEvent:@"Capture Button"];
    
    mFocalPoints = [pathView getPoints];
    
    if ([mFocalPoints count] > 1) {

        
        if (mFOFIndex == 0 && ![mCaptureDevice isAdjustingExposure] && ![mCaptureDevice isAdjustingFocus]) {
            [shootButton setEnabled:NO];
            [self capture];
            
            isObserving = YES;
            [mCaptureDevice addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];


        } else {
            [shootButton setEnabled:false];
            [infoButton setEnabled:false];
            [cancelButton setEnabled:false];
            
            pathView.enabled = false;
            
            [self updateFocusPoint];
        
            isObserving = YES;
            [mCaptureDevice addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
        }
        
    } else {
        [appDelegate showAlertBaloon:@"Not enough points" andAlertMsg:@"Select two points on the screen to be focused on." andAlertButton:@"OK" andController:self];
    }
}

-(void)showOkAlertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSString *alertButton = @"OK";
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
    [alert show];

    [alertButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    DyfocusSettings *settings = [DyfocusSettings sharedSettings];
    if(!settings.isFirstLogin && !popupView.isHidden){
        [popupView setHidden:YES];
        settings.isFirstLogin = NO;
    }
    [self.navigationController setNavigationBarHidden:YES animated:FALSE];
    [super viewWillAppear:animated];
    
    [spinner startAnimating];
    [loadingView setHidden:NO];
    
    [infoButton setEnabled:true];
    [cancelButton setEnabled:true];
    
    mFOFIndex = 0;
    
    if (mFocalPoints){
       [mFocalPoints removeAllObjects];
    }
    
    if (!mFrames) {
        mFrames = [[NSMutableArray alloc] init];
    } else {
        [mFrames removeAllObjects];
    }
    
    pathView.cameraViewController = self;
    
    popupDarkView.layer.cornerRadius = 9.0;
    [popupDarkView.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
    popupDarkView.clipsToBounds = YES;
    popupDarkView.layer.masksToBounds = YES;
    [popupDarkView setNeedsDisplay];
    [popupDarkView setNeedsLayout];
    
    [pathView resetOrientations];

}

- (void)viewDidAppear:(BOOL)animated
{
//<<<<<<< HEAD
//    [pathView resetOrientations];
    
    //[TestFlight passCheckpoint:@"CameraView.viewDidAppear - Picture Time!"];
    if(popupView.tag != 420) {
        //mToastMessage = [iToast makeText:NSLocalizedString(@"Place your phone on a steady surface (or hold it really still), touch the screen to add a few focus points an press ""Capture"".", @"")];
        //[[mToastMessage setDuration:iToastDurationNormal] show];
        
        [popupView setHidden:NO];
        [popupView setTag:420];
        
    }
    
//=======
//>>>>>>> fa50715bbb065040e236b2dac1c61aab6130ad23
    [shootButton setEnabled:true];
    
    if (!captureSession) {
        [self startCaptureSession];
    } else {
        [captureSession startRunning];
        
        if (mCaptureDevice) {
            if (![mCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] || ![mCaptureDevice isFocusPointOfInterestSupported]) {
                [self disablePictureTaking];
            }
        }
        
        [spinner stopAnimating];
        [loadingView setHidden:YES];
    }
    
    [super viewDidAppear:animated];

}

- (IBAction)cancelAction:(UIButton *)sender {
    
    NSLog(@"CANCEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEL");

//    UIImage * image = [UIImage imageNamed:@"CameraView-LeftButtonPressed.png"];
//    
//    [cancelButton setImage:image forState:UIControlStateNormal];
    
   [self goBackToLastController];
}

- (IBAction)shootAction:(UIButton *)sender {
    
    NSLog(@"SHOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOTTTTT");
    
//    UIImage * image = [UIImage imageNamed:@"CameraView-ShootButtonPressed.png"];
//
//    [shootButton setImage:image forState:UIControlStateNormal];
    
    [self addObserverToFocus];
}

- (IBAction)helpAction:(UIButton *)sender {
    
    NSLog(@"HEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEELP");
    
//    UIImage * image = [UIImage imageNamed:@"CameraView-RightButtonPressed.png"];
//    
//    [infoButton setImage:image forState:UIControlStateNormal];

    [self showInfoView];
}


- (void)showToast:(NSString *)text {

    iToast *toastMessage = [iToast makeText:NSLocalizedString(text, @"")];
    [[toastMessage setDuration:iToastDurationNormal] show];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (mToastMessage) {
        [mToastMessage removeToast:nil];
    }
    
    [pathView clearPoints];
    
	[super viewWillDisappear:animated];
    [captureSession stopRunning];    
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)sendErrorReportWithMessage:(NSString *)message
{
    //NSString *error = [[NSString alloc] initWithFormat:@"Error: %@.", message];
    //[TestFlight passCheckpoint:error];
    //[error release];
}

-(void)dealloc
{
    [mFocalPoints release];
    [mFrames release];
    [cancelButton release];
    [shootButton release];
    [infoButton release];
    [super dealloc];
}

- (NSUInteger) supportedInterfaceOrientations
{
    //Because your app is only landscape, your view controller for the view in your
    // popover needs to support only landscape
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait ;
//    return UIInterfaceOrientationMaskAll;
}


- (BOOL)shouldAutorotate {
    return YES;
}

- (void) didRotate:(NSNotification *)notification

{
    [pathView checkOrientations];
}

- (void) setTorchOn:(BOOL)isOn
{
    [mCaptureDevice lockForConfiguration:nil]; //you must lock before setting torch mode
    [mCaptureDevice setTorchMode:isOn ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
    [mCaptureDevice unlockForConfiguration];
}


@end
