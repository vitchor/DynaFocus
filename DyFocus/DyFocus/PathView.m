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
	
//    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
//    context = UIGraphicsGetCurrentContext();
	
//	ref =  [[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.3] CGColor];
	
	if ([touchPoints count] >= 1) {
		
        // Old codes used when the "point" and the "line" were drawn:
        //
//        CGContextSetLineWidth(context, 8);
//		CGContextSetStrokeColorWithColor(context, ref);
//        CGContextSetFillColor(context, CGColorGetComponents([UIColor colorWithRed:255/255 green:50/255 blue:50/255 alpha:0.9].CGColor));
        
        if ([touchPoints count] >= 1){
           
            for (NSObject *point in touchPoints) {
                
                CGPoint cgPoint = [(NSValue *)point CGPointValue];
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                
                if ([touchPoints indexOfObject:point] == 0) {
                    
//                  firstImage.frame = (CGRect){{cgPoint.x-40, cgPoint.y-40}, firstImage.frame.size};
//                  firstImage.center = CGPointMake(cgPoint.x, cgPoint.y);
                   
                    
                    if (screenBounds.size.height == 568) {
                        firstFocusX.constant = cgPoint.x-40;
                        firstFocusY.constant = cgPoint.y-40-44;
                    }else{
                        firstFocusX.constant = cgPoint.x-40;
                        firstFocusY.constant = cgPoint.y-40;
                    }
                    
                    [firstImage setHidden:NO];
                    
                }
                else {
                    
//                  secondImage.frame = (CGRect){{cgPoint.x-40, cgPoint.y-40}, secondImage.frame.size};
//                  secondImage.center = CGPointMake(cgPoint.x, cgPoint.y);
                    
                    
                    if (screenBounds.size.height == 568) {
                        secondFocusX.constant = cgPoint.x-40;
                        secondFocusY.constant = cgPoint.y-40-44;
                    }else{
                        secondFocusX.constant = cgPoint.x-40;
                        secondFocusY.constant = cgPoint.y-40;
                    }
                    [secondImage setHidden:NO];
                }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) resetOrientations
{
    firstImage.transform = CGAffineTransformIdentity;
    secondImage.transform = CGAffineTransformIdentity;
    cancelIcon.transform = CGAffineTransformIdentity;
    cameraIcon.transform = CGAffineTransformIdentity;
    helpIcon.transform = CGAffineTransformIdentity;
    torchOneButton.transform = CGAffineTransformIdentity;
    torchTwoButton.transform = CGAffineTransformIdentity;
        
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationPortrait)
    {
        [self setTorchButtonsPlace:orientation];
    }
    else if (orientation == UIDeviceOrientationPortraitUpsideDown)
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
        
        if (lastOrientation == UIDeviceOrientationPortrait)
        {
            [self setTorchButtonsPlace:lastOrientation];
        }
        else if (lastOrientation == UIDeviceOrientationPortraitUpsideDown)
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
        else
        {
            [self setTorchButtonsPlace:UIDeviceOrientationPortrait];
        }
    }
    else
    {
        [self setTorchButtonsPlace:UIDeviceOrientationPortrait];
    }

    if(!(orientation==UIDeviceOrientationFaceUp||
         orientation==UIDeviceOrientationFaceDown)){
        lastOrientation = orientation;
    }
}

- (void) checkOrientations
{
    fadeDuration = 0.15;
    
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
    firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI/2);
    secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI/2);
    cancelIcon.transform = CGAffineTransformRotate(cancelIcon.transform, M_PI/2);
    cameraIcon.transform = CGAffineTransformRotate(cameraIcon.transform, M_PI/2);
    helpIcon.transform = CGAffineTransformRotate(helpIcon.transform, M_PI/2);
    
    [UIView animateWithDuration:fadeDuration animations:^{
        torchOneButton.alpha = 0.0;
        torchTwoButton.alpha = 0.0;
    } completion: ^(BOOL finished) {
        [UIView animateWithDuration:0 animations:^{
            torchOneButton.transform = CGAffineTransformRotate(torchOneButton.transform, M_PI/2);
            torchTwoButton.transform = CGAffineTransformRotate(torchTwoButton.transform, M_PI/2);
        } completion: ^(BOOL finished) {
            [self setTorchButtonsPlace:orientation];
        }];
    }];
//    CGAffineTransform rotateOne = CGAffineTransformRotate(torchOneView.transform, M_PI/2);
//    CGAffineTransform translateOne = CGAffineTransformMakeTranslation(toneX, toneY);
//    CGAffineTransform finalTransformOne = CGAffineTransformConcat(rotateOne, translateOne);
//    torchOneView.transform = finalTransformOne;
    
}
-(void)rotateImagesToTheLeft: (UIDeviceOrientation) orientation
{
    firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI/2);
    secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI/2);
    cancelIcon.transform = CGAffineTransformRotate(cancelIcon.transform, -M_PI/2);
    cameraIcon.transform = CGAffineTransformRotate(cameraIcon.transform, -M_PI/2);
    helpIcon.transform = CGAffineTransformRotate(helpIcon.transform, -M_PI/2);
    
    [UIView animateWithDuration:fadeDuration animations:^{
        torchOneButton.alpha = 0.0;
        torchTwoButton.alpha = 0.0;
    } completion: ^(BOOL finished) {
        [UIView animateWithDuration:0 animations:^{
            torchOneButton.transform = CGAffineTransformRotate(torchOneButton.transform, -M_PI/2);
            torchTwoButton.transform = CGAffineTransformRotate(torchTwoButton.transform, -M_PI/2);
        } completion: ^(BOOL finished) {
            [self setTorchButtonsPlace:orientation];
        }];
    }];
}
-(void)rotateImagesHalfMoon: (UIDeviceOrientation) orientation
{
    firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI);
    secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI);
    cancelIcon.transform = CGAffineTransformRotate(cancelIcon.transform, M_PI);
    cameraIcon.transform = CGAffineTransformRotate(cameraIcon.transform, M_PI);
    helpIcon.transform = CGAffineTransformRotate(helpIcon.transform, M_PI);
    
    [UIView animateWithDuration:fadeDuration animations:^{
        torchOneButton.alpha = 0.0;
        torchTwoButton.alpha = 0.0;
    } completion: ^(BOOL finished) {
        [UIView animateWithDuration:0 animations:^{
            torchOneButton.transform = CGAffineTransformRotate(torchOneButton.transform, M_PI);
            torchTwoButton.transform = CGAffineTransformRotate(torchTwoButton.transform, M_PI);
        } completion: ^(BOOL finished) {
            [self setTorchButtonsPlace:orientation];
        }];
    }];
}

-(void) setTorchButtonsPlace:(UIDeviceOrientation) orientation {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        
        if (orientation == UIDeviceOrientationPortrait)
        {
            torchOneX.constant = 36.0-(61.0/2);
            torchOneY.constant = 22.0-17.0;
            torchTwoX.constant = 100.0-(61.0/2);
            torchTwoY.constant = 22.0-17.0;
        }
        else if (orientation == UIDeviceOrientationPortraitUpsideDown)
        {
            torchOneX.constant = 284.0-(61.0/2);
            torchOneY.constant = 22.0-17.0;
            torchTwoX.constant = 220.0-(61.0/2);
            torchTwoY.constant = 22.0-17.0;
        }
        else if(orientation == UIDeviceOrientationLandscapeRight)
        {
            torchOneX.constant = 22.0-17;
            torchOneY.constant = 446.0-(61.0/2)-3;
            torchTwoX.constant = 22.0-17;
            torchTwoY.constant = 382.0-(61.0/2)-3;
        }
        else if(orientation == UIDeviceOrientationLandscapeLeft ||
                orientation == UIDeviceOrientationFaceUp ||
                orientation == UIDeviceOrientationFaceDown)
        {
            torchOneX.constant = 298.0-17;
            torchOneY.constant = 78.0-(61.0/2)+2;
            torchTwoX.constant = 298.0-17;
            torchTwoY.constant = 142.0-(61.0/2)+2;
        }
        
    } else {
        
        if (orientation == UIDeviceOrientationPortrait)
        {
            torchOneX.constant = 36.0-(61.0/2);
            torchOneY.constant = 22.0-17.0;
            torchTwoX.constant = 100.0-(61.0/2);
            torchTwoY.constant = 22.0-17.0;
            
        }
        else if (orientation == UIDeviceOrientationPortraitUpsideDown)
        {
            torchOneX.constant = 284.0-(61.0/2);
            torchOneY.constant = 22.0-17.0;
            torchTwoX.constant = 220.0-(61.0/2);
            torchTwoY.constant = 22.0-17.0;
        }
        else if(orientation == UIDeviceOrientationLandscapeRight)
        {
            torchOneX.constant = 22.0-17;
            torchOneY.constant = 398.0-(61.0/2)-3;
            torchTwoX.constant = 22.0-17;
            torchTwoY.constant = 334.0-(61.0/2)-3;
        }
        else if(orientation == UIDeviceOrientationLandscapeLeft ||
                orientation == UIDeviceOrientationFaceUp ||
                orientation == UIDeviceOrientationFaceDown)
        {
            torchOneX.constant = 298.0-17;
            torchOneY.constant = 36.0-(61.0/2);
            torchTwoX.constant = 298.0-17;
            torchTwoY.constant = 100.0-(61.0/2);
        }
    }
    
    [UIView animateWithDuration:fadeDuration animations:^{
        torchOneButton.alpha = 0.5;
        torchTwoButton.alpha = 0.5;
    }];
}

-(void)dealloc
{
    [firstImage release];
    [secondImage release];
    [firstFocusX release];
    [firstFocusY release];
    [secondFocusX release];
    [secondFocusY release];
    [cancelIcon release];
    [cameraIcon release];
    [helpIcon release];
    [torchOneButton release];
    [torchTwoButton release];
    [torchOneX release];
    [torchOneY release];
    [torchTwoX release];
    [torchTwoY release];
    [super dealloc];
}

@end
