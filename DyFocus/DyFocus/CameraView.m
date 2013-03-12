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

@implementation CameraView

@synthesize cameraView, pathView, shootButton, clearButton, cancelButton, infoButton, infoView, getStartedButton, mFocalPoints, popupCloseButton, popupView, spinner, loadingView, popupDarkView, torchButton, testInfoView, firstFocusX, firstFocusY, secondFocusX, secondFocusY;

- (void)updateFocusPoint {
    NSLog(@"UPDATE POINT: %d", mFOFIndex);
    NSError *error = nil;
    if ([mCaptureDevice lockForConfiguration:&error]) {
        
    
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
        [clearButton setEnabled:false];
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


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    pathView.enabled = true;
    isObserving = false;
    
    shootButton.target = self;
    [shootButton setAction:@selector(addObserverToFocus)];
    
    
    [torchButton addTarget:self action:@selector(torchToggle) forControlEvents:UIControlEventTouchUpInside];
    
    clearButton.target = self;
    [clearButton setAction:@selector(clearPoints)];
    
    [getStartedButton addTarget:self action:@selector(hideInfoView) forControlEvents:UIControlEventTouchUpInside];
    
    infoButton.target = self;
    [infoButton setAction:@selector(showInfoView)];
    
    cancelButton.target = self;
    [cancelButton setAction:@selector(goBackToLastController)];
    
    
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
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logEvent:@"Clear Points Button"];
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
            [clearButton setEnabled:false];
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


    lastOrientation = [[UIDevice currentDevice] orientation];
    [self resetOrientations];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[TestFlight passCheckpoint:@"CameraView.viewDidAppear - Picture Time!"];
    if(popupView.tag != 420) {
        //mToastMessage = [iToast makeText:NSLocalizedString(@"Place your phone on a steady surface (or hold it really still), touch the screen to add a few focus points an press ""Capture"".", @"")];
        //[[mToastMessage setDuration:iToastDurationNormal] show];
        
        [popupView setHidden:NO];
        [popupView setTag:420];
        
    }
    
    [shootButton setEnabled:true];
    [clearButton setEnabled:true];
    
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
    [firstFocusX release];
    [firstFocusY release];
    [secondFocusX release];
    [secondFocusY release];
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
    
    [self checkOrientations];

}

- (void) resetOrientations
{
    
    NSLog(@"RESEEEEEEEEEEEEEET");

    pathView.firstImage.transform = CGAffineTransformIdentity;
    pathView.secondImage.transform = CGAffineTransformIdentity;
    
    UIImage * portraitImage1 = [UIImage imageNamed:@"1st-focus.png"];
    UIImage * portraitImage2 = [UIImage imageNamed:@"2nd-focus.png"];

    if(lastOrientation == UIDeviceOrientationPortrait)
    {
        
        NSLog(@"PORTRAAAAAAAAAAAAAAAAITEEEEEEEEEEEE");

//        pathView.firstImage.image = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
//                                                               scale: 1.0
//                                                         orientation: UIImageOrientationUp];
//        
//        pathView.secondImage.image = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
//                                                                scale: 1.0
//                                                          orientation: UIImageOrientationUp];
        
        pathView.firstImage.image = portraitImage1;

        pathView.secondImage.image = portraitImage1;

    }
    else if (lastOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        
        pathView.firstImage.image = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
                                                                 scale: 1.0
                                                           orientation: UIImageOrientationDown];

        pathView.secondImage.image = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
                                                               scale: 1.0
                                                         orientation: UIImageOrientationDown];
    }
    else if(lastOrientation == UIDeviceOrientationLandscapeRight)
    {
        
        pathView.firstImage.image = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
                                                               scale: 1.0
                                                         orientation: UIImageOrientationLeft];
        
        pathView.secondImage.image = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
                                                                scale: 1.0
                                                          orientation: UIImageOrientationLeft];
    }
    else if(lastOrientation == UIDeviceOrientationLandscapeLeft ||
            lastOrientation == UIDeviceOrientationFaceUp ||
            lastOrientation == UIDeviceOrientationFaceDown)
    {
        pathView.firstImage.image = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
                                                               scale: 1.0
                                                         orientation: UIImageOrientationRight];
        
        pathView.secondImage.image = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
                                                                scale: 1.0
                                                          orientation: UIImageOrientationRight];
    }
    
}


- (void) checkOrientations
{
    
    NSLog(@"CHEEEEEEEEEEEEEEEEEEEEEEEEEECKKKKKKKKK");
 
    double duration = 0.3;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationRepeatCount:1];

    
    if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-horiz-right-white" ofType:@"png"]];
        
        [instructionsImageView setImage:helpImage];
        
        NSLog(@"ALOOHAAAA1");
        
        
        if(lastOrientation == UIDeviceOrientationPortrait){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationPortraitUpsideDown) {
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, -M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, -M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, -M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationLandscapeRight){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, M_PI);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, M_PI);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, M_PI);
        }
//        else if (lastOrientation == UIDeviceOrientationFaceUp || lastOrientation == UIDeviceOrientationFaceDown){
//            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, 2*M_PI);
//            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, 2*M_PI);
//            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, 2*M_PI);
//        }
        
    }
    
    if (orientation == UIDeviceOrientationLandscapeRight )
    {
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-horiz-left-white" ofType:@"png"]];
        
        [instructionsImageView setImage:helpImage];
        
        NSLog(@"ALOOHAAAA2");
        
        
        if(lastOrientation == UIDeviceOrientationPortrait){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, -M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, -M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, -M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationPortraitUpsideDown){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationLandscapeLeft || lastOrientation == UIDeviceOrientationFaceUp || lastOrientation == UIDeviceOrientationFaceDown){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, -M_PI);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, -M_PI);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, -M_PI);
        } 
        
    }
    
    
    if (orientation == UIDeviceOrientationPortrait)
    {
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-white" ofType:@"png"]];
        
        [instructionsImageView setImage:helpImage];
        
        NSLog(@"ALOOHAAAA3");
        
        
        if(lastOrientation == UIDeviceOrientationLandscapeLeft || lastOrientation == UIDeviceOrientationFaceUp || lastOrientation == UIDeviceOrientationFaceDown){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, -M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, -M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, -M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationLandscapeRight){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationPortraitUpsideDown){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, -M_PI);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, -M_PI);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, -M_PI);
        }         
    }
    
    if (orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-white" ofType:@"png"]];
        
        [instructionsImageView setImage:helpImage];
        
        NSLog(@"ALOOHAAAA4");
        
        
        if(lastOrientation == UIDeviceOrientationLandscapeLeft || lastOrientation == UIDeviceOrientationFaceUp || lastOrientation == UIDeviceOrientationFaceDown){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationLandscapeRight){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, -M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, -M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, -M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationPortrait){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, M_PI);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, M_PI);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, M_PI);
        }
        
    }
    
    if (orientation == UIDeviceOrientationFaceUp){
        
        if(lastOrientation == UIDeviceOrientationPortrait){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationPortraitUpsideDown){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, -M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, -M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, -M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationLandscapeRight){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, -M_PI);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, -M_PI);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, -M_PI);
        }
//        else if(lastOrientation == UIDeviceOrientationLandscapeLeft || lastOrientation == UIDeviceOrientationFaceDown){
//            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, 2*M_PI);
//            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, 2*M_PI);
//            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, 2*M_PI);
//        }
        
    }
    
    if (orientation == UIDeviceOrientationFaceDown){
        
        if(lastOrientation == UIDeviceOrientationPortrait){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationPortraitUpsideDown){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, -M_PI/2);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, -M_PI/2);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, -M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationLandscapeRight){
            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, -M_PI);
            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, -M_PI);
            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, -M_PI);
        }
//        else if(lastOrientation == UIDeviceOrientationLandscapeLeft || lastOrientation == UIDeviceOrientationFaceUp){
//            testInfoView.transform = CGAffineTransformRotate(testInfoView.transform, 2*M_PI);
//            pathView.firstImage.transform = CGAffineTransformRotate(pathView.firstImage.transform, 2*M_PI);
//            pathView.secondImage.transform = CGAffineTransformRotate(pathView.secondImage.transform, 2*M_PI);
//        }
        
    }

    
    [UIView commitAnimations];
    
    lastOrientation = orientation;

    
}

- (void) setTorchOn:(BOOL)isOn
{
    [mCaptureDevice lockForConfiguration:nil]; //you must lock before setting torch mode
    [mCaptureDevice setTorchMode:isOn ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
    [mCaptureDevice unlockForConfiguration];
}


@end
