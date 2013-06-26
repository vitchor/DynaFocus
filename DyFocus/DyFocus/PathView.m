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

@synthesize touchPoints, ref, context, enabled, cameraViewController, lastOrientation;

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
        
        [cameraViewController clearPoints];
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

// Old getPoints method
//- (NSMutableArray *)getPoints {
//	
//    if(!focusPoints){
//        focusPoints = [[NSMutableArray alloc] init];
//    } else {
//        [focusPoints removeAllObjects];
//    }
//    
//    for (NSObject *point in touchPoints) {
//        CGPoint touchPoint = [(NSValue *)point CGPointValue];
//        
//        NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(touchPoint.y / self.frame.size.height, 1 - touchPoint.x / self.frame.size.width)];
//        [focusPoints  addObject:pointValue];
//    }
//    
//    return focusPoints;
//}


// New getPoints method, now it returns a reversed array of focus points (ex: n, n-1,...3, 2, 1)
- (NSMutableArray *)getPoints {
	
    if(!focusPoints){
        focusPoints = [[NSMutableArray alloc] init];
    } else {
        [focusPoints removeAllObjects];
    }
    
    NSEnumerator *enumerator = [touchPoints reverseObjectEnumerator];
    
    for (NSObject *point in touchPoints) {
        CGPoint touchPoint = [(NSValue *)enumerator.nextObject CGPointValue];
        
        NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(touchPoint.y / self.frame.size.height, 1 - touchPoint.x / self.frame.size.width)];
        [focusPoints  addObject:pointValue];
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
        
        cameraViewController.mFocalPoints = [self getPoints];
        [cameraViewController updateFocusPoint];

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

- (void) checkOrientations:(BOOL)isFirstTime
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(orientation != self.lastOrientation || orientation == UIDeviceOrientationUnknown){
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationRepeatCount:1];
        
        if(orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown)
        {
            if(isFirstTime){
                
                if(self.lastOrientation!=UIDeviceOrientationUnknown)
                    [self rotateImagesToOrientation:self.lastOrientation];
                else
                    [self rotateImagesToOrientation:UIDeviceOrientationPortrait];
            }
        }
        else
        {
            [self rotateImagesToOrientation:orientation];
        }
        
        [UIView commitAnimations];
        
        if(orientation==UIDeviceOrientationPortrait ||
           orientation==UIDeviceOrientationPortraitUpsideDown ||
           orientation==UIDeviceOrientationLandscapeLeft ||
           orientation==UIDeviceOrientationLandscapeRight)
        {
            self.lastOrientation = orientation;
        }
    }
}

-(void)rotateImagesToOrientation: (UIDeviceOrientation) orientation
{
    if (orientation == UIDeviceOrientationPortrait || UIDeviceOrientationUnknown)
    {
        firstImage.transform = CGAffineTransformIdentity;
        secondImage.transform = CGAffineTransformIdentity;
        cancelIcon.transform = CGAffineTransformIdentity;
        cameraIcon.transform = CGAffineTransformIdentity;
        helpIcon.transform = CGAffineTransformIdentity;
    }
    else
    {
        float teta = 0;
        
        if (orientation == UIDeviceOrientationPortraitUpsideDown)
        {
            teta = M_PI;
        }
        else if(orientation == UIDeviceOrientationLandscapeRight)
        {
            teta = -M_PI_2;
        }
        else if(orientation == UIDeviceOrientationLandscapeLeft)
        {
            teta = M_PI_2;
        }
        else
            NSLog(@"Awkward Orientation: %d", orientation);
        
        if(teta!=0){
            firstImage.transform = CGAffineTransformMakeRotation(teta);
            secondImage.transform = CGAffineTransformMakeRotation(teta);
            cancelIcon.transform = CGAffineTransformMakeRotation(teta);
            cameraIcon.transform = CGAffineTransformMakeRotation(teta);
            helpIcon.transform = CGAffineTransformMakeRotation(teta);
        }
    }
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
    [super dealloc];
}

@end
