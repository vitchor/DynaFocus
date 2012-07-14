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

@implementation CameraView

@synthesize cameraView, pathView, shootButton, clearButton;

- (void)updateFocusPoint {
    NSLog(@"UPDATE POINT: %d", mFOFIndex);
    NSError *error = nil;
    if ([mCaptureDevice lockForConfiguration:&error]) {
        NSLog(@"UPDATE POINT, DONE");
        [mCaptureDevice setFocusPointOfInterest:[[mFocalPoints objectAtIndex:mFOFIndex] CGPointValue]];
        [mCaptureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [mCaptureDevice unlockForConfiguration];
    }
}
- (void)startCaptureSession {
	
    // Create Session
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    
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
                     [mFrames addObject:image];
                     
                     NSLog(@"DONE! ");
                     
                     mFOFIndex = mFOFIndex + 1;
                     
                     if (mFOFIndex < [mFocalPoints count]) {
                         [self updateFocusPoint];
                     } else {
                         NSLog(@" FINISHED PICTURE");
                         [mCaptureDevice removeObserver:self forKeyPath:@"adjustingFocus"];
                         
                         FOFPreview *FOFpreview = [[FOFPreview alloc] initWithNibName:@"FOFPreview" bundle:nil];
                         
                         FOFpreview.frames = mFrames;
                         
                         [self.navigationController pushViewController:FOFpreview animated:false];
                     }
                     
                     
                     
                 }
                 
                 
             }];
        }
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    mFOFIndex = 0;
    
    // Hardcoding focal points 
    // TODO: Get from class that is responsible for modeling the logic entity path.
    mFocalPoints = [[NSMutableArray alloc] init];
    mFrames = [[NSMutableArray alloc] init];
    
    CGPoint point1 = {0,0};//top right
    CGPoint point2 = {0.5f,0.5f};// center
    CGPoint point3 = {1,1};// bottom left
    
    [mFocalPoints addObject:[NSValue valueWithCGPoint:point1]];
    [mFocalPoints addObject:[NSValue valueWithCGPoint:point2]];
    [mFocalPoints addObject:[NSValue valueWithCGPoint:point3]];    
    //
    
    [shootButton addTarget:self action:@selector(addObserverToFocus)forControlEvents:UIControlEventTouchDown];
    [clearButton addTarget:self action:@selector(clearPoints)forControlEvents:UIControlEventTouchDown];
    
    [self startCaptureSession];
    
    [super viewDidLoad];
    
}

-(void)clearPoints
{
    [pathView clearPoints];
}

-(void)addObserverToFocus
{

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
    mFOFIndex = 0;
    [self updateFocusPoint];
    [mFrames removeAllObjects];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end