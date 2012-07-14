//
//  FirstViewController.m
//  DynaFocus
//
//  Created by Marcia  Rozenfeld on 7/10/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "FirstViewController.h"

@implementation FirstViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mFOFIndex = 0;
    
    // Hardcoding focal points
    mFocalPoints = [[NSMutableArray alloc] init];
    
    CGPoint point1 = {0,0};
    CGPoint point2 = {1, 1};
    
    mFocalPoints = [NSMutableArray array];
    [mFocalPoints addObject:[NSValue valueWithCGPoint:point1]];
    [mFocalPoints addObject:[NSValue valueWithCGPoint:point2]];

    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*- (void)doTakePicture {
	UIImagePickerController *imagePicker = [[[UIImagePickerController alloc] init] autorelease];
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePicker.allowsEditing = NO;
	imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
	imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
	//UIImage *faceImage = [UIImage imageNamed:@"FaceOverlay.png"];
	//UIImageView *overlay = [[[UIImageView alloc] initWithImage:faceImage] autorelease];
	//overlay.frame = CGRectMake(0, 0, faceImage.size.width, faceImage.size.height);
	//imagePicker.cameraOverlayView = overlay;
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
}*/

- (void)doTakePicture {
	
    // Create Session
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    
    if ([captureSession canSetSessionPreset: AVCaptureSessionPresetPhoto]) {
        
        [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    
    // Find CaptureDevice
    AVCaptureDevice *captureDevice;
    
    NSArray *devices = [AVCaptureDevice devices];
   
    for (AVCaptureDevice *device in devices){
        
        if ([device hasMediaType:AVMediaTypeVideo]){
            
            if ([device position] == AVCaptureDevicePositionBack) {
                captureDevice = device;
                break;
            }
        }
        
    }
    
    // Set initial focus point
    NSError *error = nil;
    if ([captureDevice lockForConfiguration:&error]) {
        [captureDevice setFocusPointOfInterest:[[mFocalPoints objectAtIndex:0] CGPointValue]];
        [captureDevice unlockForConfiguration];
    }
           
    // Set observer to CaptureDevice
    int flags = NSKeyValueObservingOptionNew;
    [captureDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
    
    
    // Create and add DeviceInput to Session
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
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
    
    /*
    // Capture with handler
    NSLog(@"hi ");
    [mStillImageOutput captureStillImageAsynchronouslyFromConnection:mVideoConnection completionHandler:
     ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         
        CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         
        NSLog(@"hey ");
        
        if (exifAttachments) {
            NSLog(@"hello ");
        }
         
         
         //CHANGE FOCUS POINT
         //if (!isLastPoint) {
         // CALL NEW PICTURE
         //} else {
         // finish it
         //}
         
     }];*/
    
    
    // Showing preview layer
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.frame;
    [self.view.layer addSublayer:layer];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        
        NSLog(@"FOCUS IS GOOD");
        
        if(!adjustingFocus) {
            // Capture with handler
            NSLog(@"TAKING PICTURE...");
            [mStillImageOutput captureStillImageAsynchronouslyFromConnection:mVideoConnection completionHandler:
             ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                 
                 CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                 
                 
                 if (exifAttachments) {
                     NSLog(@"DONE! ");
                 }
                 
                 
                 //CHANGE FOCUS POINT
                 //if (!isLastPoint) {
                 // CALL NEW PICTURE
                 //} else {
                 // finish it
                 //}
                 
             }];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self doTakePicture];
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

@end
