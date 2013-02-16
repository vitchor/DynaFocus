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

@synthesize cameraView, pathView, shootButton, clearButton, cancelButton, infoButton, infoView, getStartedButton, mFocalPoints, popupCloseButton, popupView, spinner, loadingView, popupDarkView;

- (void)updateFocusPoint {
    NSLog(@"UPDATE POINT: %d", mFOFIndex);
    NSError *error = nil;
    if(!mCaptureDevice)
        mCaptureDevice = [videoProcessor videoDeviceWithPosition:AVCaptureDevicePositionBack];
    
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


-(void)setInitialFocusPoint:(CGPoint)point {
    NSLog(@"Setting initial focus point1");
    NSError *error = nil;
    if(!mCaptureDevice)
        mCaptureDevice = [videoProcessor videoDeviceWithPosition:AVCaptureDevicePositionBack];
    if ([mCaptureDevice lockForConfiguration:&error]) {
        
        
        if ([mCaptureDevice isExposurePointOfInterestSupported]) {
            [mCaptureDevice setExposurePointOfInterest:point];
    NSLog(@"Setting initial focus point2");
        } else {
            [self sendErrorReportWithMessage:@"CameraView.updateFocusPoint - exposure point is not supported!!"];
        }
        
               
        if ([mCaptureDevice isFocusPointOfInterestSupported]) {
            [mCaptureDevice setFocusPointOfInterest:point];
                NSLog(@"Setting initial focus point3");
            
        } else {
            [self sendErrorReportWithMessage:@"CameraView.updateFocusPoint - focus point is not supported!!"];
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

/*- (void)setupCaptureSession {
	
    // Create Session
    captureSession = [[AVCaptureSession alloc] init];
    
   
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self videoDeviceWithPosition:AVCaptureDevicePositionBack] error:nil];
    if ([captureSession canAddInput:videoIn])
        [captureSession addInput:videoIn];
	[videoIn release];
    
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    
    
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

    //[captureSession startRunning];

    // Showing preview layer
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];

    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    layer.frame = self.cameraView.frame;
    NSLog(@"CameraView is ready");
    [self.cameraView.layer addSublayer:layer];
    NSLog(@"CameraView is added");

    [spinner stopAnimating];
    [loadingView setHidden:YES];
    
}*/




-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        
        NSLog(@"ADJUSTING FOCUS");
        
        if(!adjustingFocus) {
            NSLog(@"FOCUS IS GOOD");
            
            // Capture with handler
            NSLog(@"TAKING PICTURE...");
            
            
            //[self capture];
            mFOFIndex = mFOFIndex + 1;
            
            if (mFOFIndex < [mFocalPoints count]) {
                [self updateFocusPoint];
            } else {
                // STOP REORDING
                [videoProcessor stopRecording];
//                videoProcessor s
                NSLog(@" FINISHED PICTURE");
            }

        }
    }
}


/*- (void) capture {
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
}*/

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    
    //Vieo setup
    
    [super viewDidLoad];
    
    // Initialize the class responsible for managing AV capture session and asset writer
    videoProcessor = [[RosyWriterVideoProcessor alloc] init];
	videoProcessor.delegate = self;
    
    // Keep track of changes to the device orientation so we can update the video processor
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // Setup and start the capture session
    [videoProcessor setupAndStartCaptureSession];
    

    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:videoProcessor.captureSession];
    
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    layer.frame = self.cameraView.frame;
    NSLog(@"CameraView is ready");
    [self.cameraView.layer addSublayer:layer];

    
    
    pathView.enabled = true;
    isObserving = false;
    
    shootButton.target = self;
    [shootButton setAction:@selector(addObserverToFocus)];
    
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

- (void)cleanup
{
	//[oglView release];
	//oglView = nil;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
	[notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    // Stop and tear down the capture session
	[videoProcessor stopAndTearDownCaptureSession];
	videoProcessor.delegate = nil;
    [videoProcessor release];
}

- (void)applicationDidBecomeActive:(NSNotification*)notifcation
{
	// For performance reasons, we manually pause/resume the session when saving a recording.
	// If we try to resume the session in the background it will fail. Resume the session here as well to ensure we will succeed.
	[videoProcessor resumeCaptureSession];
}

// UIDeviceOrientationDidChangeNotification selector
- (void)deviceOrientationDidChange
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	// Don't update the reference orientation when the device orientation is face up/down or unknown.
	if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) )
		[videoProcessor setReferenceOrientation:orientation];
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
    
    if(!mCaptureDevice)
        mCaptureDevice = [videoProcessor videoDeviceWithPosition:AVCaptureDevicePositionBack];
    
    mFocalPoints = [pathView getPoints];
    
    if ([mFocalPoints count] > 0) {

        if (mFOFIndex == 0 && ![mCaptureDevice isAdjustingExposure] && ![mCaptureDevice isAdjustingFocus]) {
            
            [videoProcessor startRecording];
            //[self capture];
            
            mFOFIndex = mFOFIndex + 1;
            
            if (mFOFIndex < [mFocalPoints count]) {
                isObserving = YES;
                [self updateFocusPoint];
                [mCaptureDevice addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
            } else {
                // STOP REORDING
                [videoProcessor stopRecording];
                //                videoProcessor s
                NSLog(@" FINISHED PICTURE");
            }

        } else {
            [shootButton setEnabled:false];
            [clearButton setEnabled:false];
            [infoButton setEnabled:false];
            [cancelButton setEnabled:false];
            
            pathView.enabled = false;
            
            [self updateFocusPoint];
        
            isObserving = YES;
            [videoProcessor startRecording];
            [mCaptureDevice addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
        }
        
    } else {
        [appDelegate showAlertBaloon:@"No Focus Points" andAlertMsg:@"Tap the screen to add focus points." andAlertButton:@"OK" andController:self];
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
    
	[self cleanup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:FALSE];
    [super viewWillAppear:animated];
    
    //[spinner startAnimating];
    //[loadingView setHidden:NO];
    
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
    /*
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
    }*/
    
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
	[self cleanup];    
    [mFocalPoints release];
    [mFrames release];
    [super dealloc];
}


- (NSUInteger) supportedInterfaceOrientations
{
    //Because your app is only landscape, your view controller for the view in your
    // popover needs to support only landscape
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotate {
    return YES;
}

- (void) didRotate:(NSNotification *)notification

{
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-horiz-right-white" ofType:@"png"]];
        
        [instructionsImageView setImage:helpImage];
        
    }
    
    if (orientation == UIDeviceOrientationLandscapeRight )
    {
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-horiz-left-white" ofType:@"png"]];
        
        [instructionsImageView setImage:helpImage];
        
    }
    

    if (orientation == UIDeviceOrientationPortrait)
    {
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-white" ofType:@"png"]];
        
        [instructionsImageView setImage:helpImage];
        
    }
    

}

#pragma mark Error Handling

- (void)showError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}


#pragma mark RosyWriterVideoProcessorDelegate

- (void)recordingWillStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		//[[self recordButton] setEnabled:NO];
		//[[self recordButton] setTitle:@"Stop"];
        
		// Disable the idle timer while we are recording
		[UIApplication sharedApplication].idleTimerDisabled = YES;
        
		// Make sure we have time to finish saving the movie if the app is backgrounded during recording
		if ([[UIDevice currentDevice] isMultitaskingSupported])
			backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	});
}

- (void)recordingDidStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		//[[self recordButton] setEnabled:YES];
	});
}

- (void)recordingWillStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Disable until saving to the camera roll is complete
		//[[self recordButton] setTitle:@"Record"];
		//[[self recordButton] setEnabled:NO];
		
		// Pause the capture session so that saving will be as fast as possible.
		// We resume the sesssion in recordingDidStop:
		[videoProcessor pauseCaptureSession];
	});
}

- (void)recordingDidStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		//[[self recordButton] setEnabled:YES];
		
		[UIApplication sharedApplication].idleTimerDisabled = NO;
        
		[videoProcessor resumeCaptureSession];
        
		if ([[UIDevice currentDevice] isMultitaskingSupported]) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
			backgroundRecordingID = UIBackgroundTaskInvalid;
		}
	});
}

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer
{
	// Don't make OpenGLES calls while in the background.
	//if ( [UIApplication sharedApplication].applicationState != UIApplicationStateBackground )
	//	[oglView displayPixelBuffer:pixelBuffer];
}

@end
