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
                         /*
                         
                         NSString *fof_name = [[NSString alloc] initWithFormat:@"%f",CACurrentMediaTime()];
                         
                         for (int i = 0; i < [mFrames count]; i++)
                         {
                             NSLog(@"Uploading image %d",i);
                             UIImage *image = [mFrames objectAtIndex:i];
                             
                             NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/image.jpg"];
                             
                             // Write a UIImage to JPEG with minimum compression (best quality)
                             [UIImageJPEGRepresentation(image, 0.5) writeToFile:jpgPath atomically:YES];
                             
                             NSString *photoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/image.jpg"];
                             
                             NSURL *webServiceUrl = [NSURL URLWithString:@"http://192.168.100.107:8000/uploader/image/"];
                             //NSURL *webServiceUrl = [NSURL URLWithString:@"http://54.245.121.15//uploader/image/"];
                             
                             ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:webServiceUrl];
                             
                             // Add all the post values
                             NSString *fof_size = [[NSString alloc] initWithFormat:@"%d",[[pathView getPoints] count]];
                             NSString *frame_index = [[NSString alloc] initWithFormat:@"%d",i];
                             
                             CGPoint touchPoint = [(NSValue *)[[pathView getPoints] objectAtIndex:i] CGPointValue];
                             
                             [request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device_id"];
                             [request setPostValue:frame_index forKey:@"frame_index"];
                             [request setPostValue:[[NSNumber alloc] initWithInt:touchPoint.x*100] forKey:@"frame_focal_point_x"];
                             [request setPostValue:[[NSNumber alloc] initWithInt:touchPoint.y*100] forKey:@"frame_focal_point_y"];
                             
                             [request setPostValue:fof_name forKey:@"fof_name"];
                             [request setPostValue:fof_size forKey:@"fof_size"];
                             
                             
                             
                             // Add the image file to the request
                             [request setFile:photoPath withFileName:@"image.jpeg" andContentType:@"Image/jpeg" forKey:@"apiupload"];
                             
                             
                             [request startSynchronous];
                             
                             NSLog(@"MESSAGE %@",[request responseString]);
                             
                         }*/
                         
                         [mCaptureDevice removeObserver:self forKeyPath:@"adjustingFocus"];
                         
                         FOFPreview *FOFpreview = [[FOFPreview alloc] initWithNibName:@"FOFPreview" bundle:nil];
                         
                         //UIWebView *webView = UIWebViewNavigationTypeBackForward
                         
                         FOFpreview.frames = mFrames;
                         
                         for (UIImage *frame in mFrames) {
                             [frame release];
                         }
                         
                         //[mFrames release];
                         
                         [self.navigationController pushViewController:FOFpreview animated:false];
                         
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
    
    mFOFIndex = 0;
    
    // Hardcoding focal points
    // TODO: Get from class that is responsible for modeling the logic entity path.
    
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
    
    [self startCaptureSession];
    
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
