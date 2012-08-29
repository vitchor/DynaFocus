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

@implementation CameraView

@synthesize cameraView, pathView, shootButton, clearButton;

- (void)updateFocusPoint {
    NSLog(@"UPDATE POINT: %d", mFOFIndex);
    NSError *error = nil;
    if ([mCaptureDevice lockForConfiguration:&error]) {
        NSLog(@"UPDATE POINT, DONE");
        // adjusts exposure first
        [mCaptureDevice setExposurePointOfInterest:[[mFocalPoints objectAtIndex:mFOFIndex] CGPointValue]];
        [mCaptureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        
        // then the focus
        [mCaptureDevice setFocusPointOfInterest:[[mFocalPoints objectAtIndex:mFOFIndex] CGPointValue]];
        [mCaptureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        
        // releases the lock
        [mCaptureDevice unlockForConfiguration];
    }
}
- (void)startCaptureSession {
	
    // Create Session
    captureSession = [[AVCaptureSession alloc] init];
    
    if ([captureSession canSetSessionPreset: AVCaptureSessionPresetPhoto]) {
        
        [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
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
    
    // Set initial focus point
    [self updateFocusPoint];
    
    
    // Create and add DeviceInput to Session
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:mCaptureDevice error:&error];
    
    if ([captureSession canAddInput:deviceInput]) {
        [captureSession addInput:deviceInput];
    }
    
    
    // Create/add StillImageOutput, get connection and add handler
    mStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    
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
    
    [captureSession startRunning];
    
    // Showing preview layer
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.cameraView.frame;
    
    [self.cameraView.layer addSublayer:layer];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        
        if(!adjustingFocus) {
            
            NSLog(@"FOCUS IS GOOD");
            
            // Capture with handler
            NSLog(@"TAKING PICTURE...");
            [mStillImageOutput captureStillImageAsynchronouslyFromConnection:mVideoConnection completionHandler:
             ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                 
                 CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                 
                 
                 if (exifAttachments) {
                     
                     NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                     UIImage *image = [[UIImage alloc] initWithData:imageData];
                     
                     /*CGRect cropRect = CGRectMake((image.size.width-3000)/2,(image.size.width-3000)/2, 3000, 3000);
                     
                     CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
                     

                     UIImage *correctImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:image.imageOrientation];
                     
                     [mFrames addObject:[correctImage retain]];
                     */
                     
                     UIImage *correctImage = [[image fixOrientation] retain];
                     
                     [image release];
                     image = nil;
                     //UIImage *correctImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:image.imageOrientation];
                     
                     [mFrames addObject:correctImage];
                     
                     NSLog(@"DONE! ");
                     
                     mFOFIndex = mFOFIndex + 1;
                     
                     if (mFOFIndex < [mFocalPoints count]) {
                         [self updateFocusPoint];
                     } else {
                         NSLog(@" FINISHED PICTURE");
                         
                         [mCaptureDevice removeObserver:self forKeyPath:@"adjustingFocus"];
                         
                         FOFPreview *FOFpreview = [[FOFPreview alloc] initWithNibName:@"FOFPreview" bundle:nil];
                         
                         FOFpreview.frames = mFrames;
                         FOFpreview.focalPoints = [pathView getPoints];
                         
                         for (UIImage *frame in mFrames) {
                             [frame release];
                         }
                         
                         [self.navigationController pushViewController:FOFpreview animated:true];
                         
                         [FOFpreview release];
                     }   
                     
                 }
                 
             }];
        }
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{   
    NSString *doneString = @"Shoot";
	UIBarButtonItem *continueButton = [[UIBarButtonItem alloc]
									   initWithTitle:doneString style:UIBarButtonItemStyleDone target:self action:@selector(addObserverToFocus)];
	self.navigationItem.rightBarButtonItem = continueButton;
	[continueButton release];
	[doneString release];
    
    NSString *removePoints = @"Clear";
	UIBarButtonItem *removePointsButton = [[UIBarButtonItem alloc]
									   initWithTitle:removePoints style:UIBarButtonItemStyleBordered target:self action:@selector(clearPoints)];
	self.navigationItem.leftBarButtonItem = removePointsButton;
	[removePointsButton release];
	[removePoints release];
    
    [super viewDidLoad];
}

-(void)clearPoints
{
    [pathView clearPoints];
}

-(void)addObserverToFocus
{
    mFocalPoints = [pathView getPoints];
    [self updateFocusPoint];
    [mCaptureDevice addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    mFOFIndex = 0;
    
    if (mFrames){
        
        [mFrames release];
        mFrames = nil;
    }

    if (mFocalPoints) {
        [mFocalPoints release];
        mFocalPoints = nil;
    }
    
    mFocalPoints = [[NSMutableArray alloc] init];
    mFrames = [[NSMutableArray alloc] init];
    
    CGPoint centerPoint = {0.5f,0.5f};// center
    
    [mFocalPoints addObject:[NSValue valueWithCGPoint:centerPoint]];
    
    [shootButton addTarget:self action:@selector(addObserverToFocus)forControlEvents:UIControlEventTouchDown];
    [clearButton addTarget:self action:@selector(clearPoints)forControlEvents:UIControlEventTouchDown];

}

- (void)viewDidAppear:(BOOL)animated
{
    if (!captureSession) {
        [self startCaptureSession];
    } else {
        [captureSession startRunning];
    }
    

    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
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

- (void) dealloc
{
    [mFocalPoints release];
    [mFrames release];
    
    [super dealloc];
}

@end
