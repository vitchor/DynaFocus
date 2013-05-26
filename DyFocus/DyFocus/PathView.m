//
//  PathView.m
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "PathView.h"
#import "CameraView.h"
#import "AppDelegate.h"


@implementation PathView

@synthesize touchPoints, ref, context, enabled, cameraViewController;

- (id)initWithFrame:(CGRect)frame
{
    enabled = true;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
        
    if ([touchPoints count] >= 1){
       
        for (NSObject *point in touchPoints) {
            
            CGPoint cgPoint = [(NSValue *)point CGPointValue];
            
            if ([touchPoints indexOfObject:point] == 0) {
                
                firstFocusX.constant = cgPoint.x-40;
                firstFocusY.constant = cgPoint.y-40;
                firstFocusX2.constant = self.frame.size.width - firstFocusX.constant - 80;
                firstFocusY2.constant = self.frame.size.height - firstFocusY.constant - 80;
                
                [firstImage setHidden:NO];
            }
            else {
                secondFocusX.constant = cgPoint.x-40;
                secondFocusY.constant = cgPoint.y-40;
                secondFocusX2.constant = self.frame.size.width - secondFocusX.constant - 80;
                secondFocusY2.constant = self.frame.size.height - secondFocusY.constant - 80;
                
                [secondImage setHidden:NO];
            }
        }
    }
}


-(void)clearPoints{
	
	if(touchPoints!=nil){
		[touchPoints removeAllObjects];
        [firstImage setHidden:YES];
        [secondImage setHidden:YES];
        [self setNeedsDisplay];
	}
}

- (void)addPoint:(CGPoint)actualTouchPoint {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logEvent:@"Added Point"];
	
	if (touchPoints == nil) {
		touchPoints = [[NSMutableArray alloc] initWithObjects:nil];
	}
	
	NSValue *value = [NSValue valueWithCGPoint:actualTouchPoint];
	[touchPoints addObject:value];
    if([touchPoints count] == 2){
        [cameraViewController setProximityEnabled:YES];
    }
}

- (NSMutableArray *)getPoints {
	
    if(!focusPoints){
        focusPoints = [[NSMutableArray alloc] init];
    } else {
        [focusPoints removeAllObjects];
    }
    
    for (NSObject *point in touchPoints) {
        CGPoint touchPoint = [(NSValue *)point CGPointValue];
        
        NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(touchPoint.y / self.frame.size.height, 1 - touchPoint.x / self.frame.size.width)];
        [focusPoints addObject:pointValue];
    }
    
    return focusPoints;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (enabled && [touchPoints count] < 2) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self];
        
        float focusPointWidth = firstImage.frame.size.width;
        float focusPointHeight = firstImage.frame.size.height;
        
        //The code below limits the touching area.
        if(touchPoint.x<focusPointWidth/2)
            touchPoint.x =  focusPointWidth/2;
        else if (touchPoint.x>self.frame.size.width-focusPointWidth/2)
            touchPoint.x = self.frame.size.width-focusPointWidth/2;
        
        if(touchPoint.y<focusPointHeight/2)
            touchPoint.y =  focusPointHeight/2;
        else if (touchPoint.y>self.frame.size.height-focusPointHeight/2)
            touchPoint.y = self.frame.size.height-focusPointHeight/2;
        
        [self addPoint:touchPoint];
        [self setNeedsDisplay];
        
        if ([touchPoints count] == 1) {
            cameraViewController.mFocalPoints = [self getPoints];
            [cameraViewController updateFocusPoint];
        }
    }
    else if (enabled && [touchPoints count] == 2) {
        [self clearPoints];
        [cameraViewController setProximityEnabled:NO];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void) resetOrientations
{
    firstImage.transform = CGAffineTransformIdentity;
    secondImage.transform = CGAffineTransformIdentity;
    cancelIcon.transform = CGAffineTransformIdentity;
    cameraIcon.transform = CGAffineTransformIdentity;
    helpIcon.transform = CGAffineTransformIdentity;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        [self rotateImagesHalfMoon:orientation];
    }
    else if(orientation == UIDeviceOrientationLandscapeRight)
    {
        [self rotateImagesToTheLeft:orientation];
    }
    else if(orientation == UIDeviceOrientationLandscapeLeft)
    {
        [self rotateImagesToTheRight:orientation];
    }
    else if(orientation == UIDeviceOrientationFaceUp ||
            orientation == UIDeviceOrientationFaceDown){
        
        if (lastOrientation == UIDeviceOrientationPortraitUpsideDown)
        {
            [self rotateImagesHalfMoon:lastOrientation];
        }
        else if(lastOrientation == UIDeviceOrientationLandscapeRight)
        {
            [self rotateImagesToTheLeft:lastOrientation];
        }
        else if(lastOrientation == UIDeviceOrientationLandscapeLeft)
        {
            [self rotateImagesToTheRight:lastOrientation];
        }
    }

    if(!(orientation==UIDeviceOrientationFaceUp||
         orientation==UIDeviceOrientationFaceDown)){
        
        lastOrientation = orientation;
        
    }
    if(lastOrientation==UIDeviceOrientationUnknown){
        
        lastOrientation = UIDeviceOrientationPortrait;
    }

}

- (void) checkOrientations
{
    double duration = 0.3;

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationRepeatCount:1];
    
    if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        if(!cameraViewController.popupView.isHidden){
            
            UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-horiz-right-white" ofType:@"png"]];
        
            [cameraViewController.instructionsImageView setImage:helpImage];
        
        }
        
        if(lastOrientation == UIDeviceOrientationPortrait){
            [self rotateImagesToTheRight:orientation];
        }
        else if (lastOrientation == UIDeviceOrientationPortraitUpsideDown) {
            [self rotateImagesToTheLeft:orientation];
        }
        else if(lastOrientation == UIDeviceOrientationLandscapeRight){
            [self rotateImagesHalfMoon:orientation];
        }
        
    }
    if (orientation == UIDeviceOrientationLandscapeRight )
    {
        if(!cameraViewController.popupView.isHidden){
            
            UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-horiz-left-white" ofType:@"png"]];
            
            [cameraViewController.instructionsImageView setImage:helpImage];
        }
        
        if(lastOrientation == UIDeviceOrientationPortrait){
            [self rotateImagesToTheLeft:orientation];
        }
        else if (lastOrientation == UIDeviceOrientationPortraitUpsideDown){
            [self rotateImagesToTheRight:orientation];
        }
        else if(lastOrientation == UIDeviceOrientationLandscapeLeft){
            [self rotateImagesHalfMoon:orientation];
        }
        
    }
    if (orientation == UIDeviceOrientationPortrait)
    {
        if(!cameraViewController.popupView.isHidden){
            
            UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-white" ofType:@"png"]];
            
            [cameraViewController.instructionsImageView setImage:helpImage];
        }
        
        if(lastOrientation == UIDeviceOrientationLandscapeLeft){
            [self rotateImagesToTheLeft:orientation];
        }
        else if (lastOrientation == UIDeviceOrientationLandscapeRight){
            [self rotateImagesToTheRight:orientation];
        }
        else if(lastOrientation == UIDeviceOrientationPortraitUpsideDown){
            [self rotateImagesHalfMoon:orientation];
        }
        
    }
    if (orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        if(!cameraViewController.popupView.isHidden){
            
            UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-white" ofType:@"png"]];
            
            [cameraViewController.instructionsImageView setImage:helpImage];
        }
        
        if(lastOrientation == UIDeviceOrientationLandscapeLeft){
            [self rotateImagesToTheRight:orientation];
        }
        else if (lastOrientation == UIDeviceOrientationLandscapeRight){
            [self rotateImagesToTheLeft:orientation];
        }
        else if(lastOrientation == UIDeviceOrientationPortrait){
            [self rotateImagesHalfMoon:orientation];
        }
        
    }

    [UIView commitAnimations];
    
    if(!(orientation==UIDeviceOrientationFaceUp||
         orientation==UIDeviceOrientationFaceDown)){
        lastOrientation = orientation;    
    }
    
}

//-(void) setImagesOrientation: (UIImageOrientation) orientation{
//    
//    UIImage * portraitImage1 = [UIImage imageNamed:@"1st-focus.png"];
//    UIImage * portraitImage2 = [UIImage imageNamed:@"2nd-focus.png"];
//    UIImage * portraitImage3 = [UIImage imageNamed:@"CameraView-CancelIcon.png"];
//    UIImage * portraitImage4 = [UIImage imageNamed:@"CameraView-CameraIcon.png"];
//    UIImage * portraitImage5 = [UIImage imageNamed:@"CameraView-HelpIcon.png"];
//    
//    firstImage.image = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage scale: 1.0 orientation: orientation];
//    [firstImage.image release];
//    
//    secondImage.image = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage scale: 1.0 orientation: orientation];
//    [secondImage.image release];
//    
//    cancelIcon.image = [[UIImage alloc] initWithCGImage: portraitImage3.CGImage scale: 1.0 orientation: orientation];
//    [cancelIcon.image release];
//    
//    cameraIcon.image = [[UIImage alloc] initWithCGImage: portraitImage4.CGImage scale: 1.0 orientation: orientation];
//    [cameraIcon.image release];
//    
//    helpIcon.image = [[UIImage alloc] initWithCGImage: portraitImage5.CGImage scale: 1.0 orientation: orientation];
//    [helpIcon.image release];
//    
//}



-(void)rotateImagesToTheRight: (UIDeviceOrientation) orientation
{
    firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI_2);
    secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI_2);
    cancelIcon.transform = CGAffineTransformRotate(cancelIcon.transform, M_PI_2);
    cameraIcon.transform = CGAffineTransformRotate(cameraIcon.transform, M_PI_2);
    helpIcon.transform = CGAffineTransformRotate(helpIcon.transform, M_PI_2);    
}
-(void)rotateImagesToTheLeft: (UIDeviceOrientation) orientation
{
    firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI_2);
    secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI_2);
    cancelIcon.transform = CGAffineTransformRotate(cancelIcon.transform, -M_PI_2);
    cameraIcon.transform = CGAffineTransformRotate(cameraIcon.transform, -M_PI_2);
    helpIcon.transform = CGAffineTransformRotate(helpIcon.transform, -M_PI_2);
}
-(void)rotateImagesHalfMoon: (UIDeviceOrientation) orientation
{
    firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI);
    secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI);
    cancelIcon.transform = CGAffineTransformRotate(cancelIcon.transform, M_PI);
    cameraIcon.transform = CGAffineTransformRotate(cameraIcon.transform, M_PI);
    helpIcon.transform = CGAffineTransformRotate(helpIcon.transform, M_PI);
}

-(void)dealloc
{
    [firstImage release];
    [secondImage release];
    [firstFocusX release];
    [firstFocusY release];
    [firstFocusX2 release];
    [firstFocusY2 release];
    [secondFocusX release];
    [secondFocusY release];
    [secondFocusX2 release];
    [secondFocusY2 release];
    [cancelIcon release];
    [cameraIcon release];
    [helpIcon release];
    [torchOneButton release];
    [torchTwoButton release];
    [super dealloc];
}

@end
