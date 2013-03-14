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
    
    context = UIGraphicsGetCurrentContext();
	
	ref =  [[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.3] CGColor];
	
	if ([touchPoints count] >= 1) {
		
        // Old codes used when the "point" and the "line" were drawn:
        //
//        CGContextSetLineWidth(context, 8);
//		CGContextSetStrokeColorWithColor(context, ref);
//        CGContextSetFillColor(context, CGColorGetComponents([UIColor colorWithRed:255/255 green:50/255 blue:50/255 alpha:0.9].CGColor));
        
        if ([touchPoints count] >= 1){
           
            for (NSObject *point in touchPoints) {
                
                CGPoint cgPoint = [(NSValue *)point CGPointValue];
                
                
                if ([touchPoints indexOfObject:point] == 0) {
                    
//                  firstImage.frame = (CGRect){{cgPoint.x-40, cgPoint.y-40}, firstImage.frame.size};
//                  firstImage.center = CGPointMake(cgPoint.x, cgPoint.y);
                    
                    firstFocusX.constant = cgPoint.x-40;
                    firstFocusY.constant = cgPoint.y-40;
                    
                    [firstImage setHidden:NO];
                    
                }
                else {
                    
//                  secondImage.frame = (CGRect){{cgPoint.x-40, cgPoint.y-40}, secondImage.frame.size};
//                  secondImage.center = CGPointMake(cgPoint.x, cgPoint.y);
                    
                    secondFocusX.constant = cgPoint.x-40;
                    secondFocusY.constant = cgPoint.y-40;

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
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    firstImage.transform = CGAffineTransformIdentity;
    secondImage.transform = CGAffineTransformIdentity;
    
    UIImage * portraitImage1 = [UIImage imageNamed:@"1st-focus.png"];
    UIImage * portraitImage2 = [UIImage imageNamed:@"2nd-focus.png"];
    
    if(orientation == UIDeviceOrientationPortrait)
    {
        
        firstImage.image = portraitImage1;
        
        secondImage.image = portraitImage2;
        
    }
    else if (orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        
        firstImage.image = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
                                                               scale: 1.0
                                                         orientation: UIImageOrientationDown];
        [firstImage.image release];
        
        
        secondImage.image = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
                                                                scale: 1.0
                                                          orientation: UIImageOrientationDown];
        [secondImage.image release];
    }
    else if(orientation == UIDeviceOrientationLandscapeRight)
    {
        
        firstImage.image = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
                                                               scale: 1.0
                                                         orientation: UIImageOrientationLeft];
        [firstImage.image release];
        
        
        secondImage.image = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
                                                                scale: 1.0
                                                          orientation: UIImageOrientationLeft];
        [secondImage.image release];
    }
    else if(orientation == UIDeviceOrientationLandscapeLeft ||
            orientation == UIDeviceOrientationFaceUp ||
            orientation == UIDeviceOrientationFaceDown)
    {
        firstImage.image = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
                                                               scale: 1.0
                                                         orientation: UIImageOrientationRight];
        [firstImage.image release];
        
        
        secondImage.image = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
                                                                scale: 1.0
                                                          orientation: UIImageOrientationRight];
        [secondImage.image release];
        
    }
    
    lastOrientation = orientation;
    
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
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-horiz-right-white" ofType:@"png"]];
        
        [cameraViewController.instructionsImageView setImage:helpImage];
        
            
        if(lastOrientation == UIDeviceOrientationPortrait){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI/2);
            
        }
        else if (lastOrientation == UIDeviceOrientationPortraitUpsideDown) {
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, -M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationLandscapeRight){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, M_PI);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI);
        }
        //        else if (lastOrientation == UIDeviceOrientationFaceUp || lastOrientation == UIDeviceOrientationFaceDown){
        //            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, 2*M_PI);
        //            firstImage.transform = CGAffineTransformRotate(firstImage.transform, 2*M_PI);
        //            secondImage.transform = CGAffineTransformRotate(secondImage.transform, 2*M_PI);
        //        }
        
    }
    
    if (orientation == UIDeviceOrientationLandscapeRight )
    {
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-horiz-left-white" ofType:@"png"]];
        
        [cameraViewController.instructionsImageView setImage:helpImage];
        
        
        if(lastOrientation == UIDeviceOrientationPortrait){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, -M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationPortraitUpsideDown){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationLandscapeLeft || lastOrientation == UIDeviceOrientationFaceUp || lastOrientation == UIDeviceOrientationFaceDown){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, -M_PI);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI);
        }
        
    }
    
    
    if (orientation == UIDeviceOrientationPortrait)
    {
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-white" ofType:@"png"]];
        
        [cameraViewController.instructionsImageView setImage:helpImage];
        
        
        if(lastOrientation == UIDeviceOrientationLandscapeLeft || lastOrientation == UIDeviceOrientationFaceUp || lastOrientation == UIDeviceOrientationFaceDown){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, -M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationLandscapeRight){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationPortraitUpsideDown){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, -M_PI);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI);
        }
    }
    
    if (orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        
        UIImage *helpImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"dyfocus-instructions-white" ofType:@"png"]];
        
        [cameraViewController.instructionsImageView setImage:helpImage];
        
        
        if(lastOrientation == UIDeviceOrientationLandscapeLeft || lastOrientation == UIDeviceOrientationFaceUp || lastOrientation == UIDeviceOrientationFaceDown){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationLandscapeRight){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, -M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationPortrait){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, M_PI);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI);
        }
        
    }
    
    if (orientation == UIDeviceOrientationFaceUp){
        
        if(lastOrientation == UIDeviceOrientationPortrait){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationPortraitUpsideDown){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, -M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationLandscapeRight){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, -M_PI);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI);
        }
        //        else if(lastOrientation == UIDeviceOrientationLandscapeLeft || lastOrientation == UIDeviceOrientationFaceDown){
        //            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, 2*M_PI);
        //            firstImage.transform = CGAffineTransformRotate(firstImage.transform, 2*M_PI);
        //            secondImage.transform = CGAffineTransformRotate(secondImage.transform, 2*M_PI);
        //        }
        
    }
    
    if (orientation == UIDeviceOrientationFaceDown){
        
        if(lastOrientation == UIDeviceOrientationPortrait){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI/2);
        }
        else if(lastOrientation == UIDeviceOrientationPortraitUpsideDown){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, -M_PI/2);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI/2);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI/2);
        }
        else if (lastOrientation == UIDeviceOrientationLandscapeRight){
            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, -M_PI);
            firstImage.transform = CGAffineTransformRotate(firstImage.transform, -M_PI);
            secondImage.transform = CGAffineTransformRotate(secondImage.transform, -M_PI);
        }
        //        else if(lastOrientation == UIDeviceOrientationLandscapeLeft || lastOrientation == UIDeviceOrientationFaceUp){
        //            cameraViewController.testInfoView.transform = CGAffineTransformRotate(cameraViewController.testInfoView.transform, 2*M_PI);
        //            firstImage.transform = CGAffineTransformRotate(firstImage.transform, 2*M_PI);
        //            secondImage.transform = CGAffineTransformRotate(secondImage.transform, 2*M_PI);
        //        }
        
    }
    
    [UIView commitAnimations];
    
    lastOrientation = orientation;
}

-(void)dealloc
{
    [firstImage release];
    [secondImage release];
    [firstFocusX release];
    [firstFocusY release];
    [secondFocusX release];
    [secondFocusY release];
    [super dealloc];
}

@end
