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
#import "UIImage+fixOrientation.h"
#import "iToast.h"
#import "AppDelegate.h"

@implementation CameraView

@synthesize cameraView, pathView, shootButton, clearButton, cancelButton, infoButton;

- (void)updateFocusPoint {
    NSLog(@"UPDATE POINT: %d", mFOFIndex);
    NSError *error = nil;
    if ([mCaptureDevice lockForConfiguration:&error]) {
        NSLog(@"UPDATE POINT, DONE");
        
    
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
    
    if ([captureSession canSetSessionPreset: AVCaptureSessionPresetPhoto]) {
        [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
        
    } else {
        [self sendErrorReportWithMessage:@"CameraView.startCaptureSession - captureSession can't set preset AVCaptureSessionPresetPhoto"];
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
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    

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
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        
        if(!adjustingFocus) {
            NSLog(@"FOCUS IS GOOD");
            
            // Capture with handler
            NSLog(@"TAKING PICTURE...");
            
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
                             UIImage *image = [[UIImage alloc] initWithData:imageData];
                             
                             /*CGRect cropRect = CGRectMake((image.size.width-3000)/2,(image.size.width-3000)/2, 3000, 3000);
                             CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
                             UIImage *correctImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:image.imageOrientation];
                             [mFrames addObject:[correctImage retain]];*/
                             
                             //UIImage *correctImage = [[image fixOrientation] retain];
                             
                             //[image release];
                             //image = nil;
                             UIImage *correctImage = [[UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:image.imageOrientation] retain];
                             
                             [mFrames addObject:correctImage];
                             
                             NSLog(@"DONE! ");
                             
                             mFOFIndex = mFOFIndex + 1;
                             
                             if (mFOFIndex < [mFocalPoints count]) {
                                 [self updateFocusPoint];
                             } else {
                                 NSLog(@" FINISHED PICTURE");
                                 
                                 [mCaptureDevice removeObserver:self forKeyPath:@"adjustingFocus"];

                                 pathView.enabled = true;
                                 
                                 FOFPreview *FOFpreview = [[FOFPreview alloc] initWithNibName:@"FOFPreview" bundle:nil];
                                 
                                 FOFpreview.frames = mFrames;
                                 FOFpreview.focalPoints = mFocalPoints;
                                 
                                 for (UIImage *frame in mFrames) {
                                     [frame release];
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
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    pathView.enabled = true;
    
    shootButton.target = self;
    [shootButton setAction:@selector(addObserverToFocus)];
    
    clearButton.target = self;
    [clearButton setAction:@selector(clearPoints)];    
    
    cancelButton.target = self;
    [cancelButton setAction:@selector(goBackToLastController)];
    
    [super viewDidLoad];
}

-(void)goBackToLastController
{
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate goBackToLastController];
}

-(void)clearPoints
{
    [pathView clearPoints];
}

-(void)addObserverToFocus
{
    mFocalPoints = [pathView getPoints];
    
    if ([mFocalPoints count] > 0) {
        
        [shootButton setEnabled:false];
        [clearButton setEnabled:false];
        [infoButton setEnabled:false];
        [cancelButton setEnabled:false];
        
        pathView.enabled = false;
        
        [self updateFocusPoint];
        
        [mCaptureDevice addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
        
    } else {
        NSString *alertTitle = @"No Focus Points";
        NSString *alertMsg = @"Tap the screen to add focus points.";
        NSString *alertButton = @"OK";
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:self cancelButtonTitle:alertButton otherButtonTitles:nil] autorelease];
        [alert show];
        
        [alertTitle release];
        [alertMsg release];
        [alertButton release];
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
    
    [shootButton setEnabled:true];
    [clearButton setEnabled:true];
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
    
    if (!captureSession) {
        [self startCaptureSession];
    } else {
        [captureSession startRunning];
        
        if (mCaptureDevice) {
            if (![mCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] || ![mCaptureDevice isFocusPointOfInterestSupported]) {
                [self disablePictureTaking];
            }
        }
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    //[TestFlight passCheckpoint:@"CameraView.viewDidAppear - Picture Time!"];
    mToastMessage = [iToast makeText:NSLocalizedString(@"Hold your phone still while taking pictures.", @"")];
    [[mToastMessage setDuration:iToastDurationNormal] show];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (mToastMessage) {
        [mToastMessage removeToast:nil];
        mToastMessage = nil;
    }
    
	[super viewWillDisappear:animated];
    [captureSession stopRunning];    
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
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
    [super dealloc];
}

- (NSUInteger) supportedInterfaceOrientations
{
    //Because your app is only landscape, your view controller for the view in your
    // popover needs to support only landscape
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}


- (BOOL)shouldAutorotate {
    return YES;
}



@end
