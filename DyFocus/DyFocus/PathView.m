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

@synthesize touchPoints, ref, context, enabled, cameraViewController, firstImage, secondImage;

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
                    
//                    firstImage.frame = (CGRect){{cgPoint.x-40, cgPoint.y-40}, firstImage.frame.size};
                    
                    firstImage.center = CGPointMake(cgPoint.x, cgPoint.y);
                    
                    [firstImage setHidden:NO];
                    
                }
                else {
//                    secondImage.frame = (CGRect){{cgPoint.x-40, cgPoint.y-40}, secondImage.frame.size};
                    
                    secondImage.center = CGPointMake(cgPoint.x, cgPoint.y);
                    
                    
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

//- (void) rotateImagesToTheLeft{
//
//    NSLog(@"CENTER BEFOOOOOORRRRREEEEE %f", firstImage.center.x);
//    
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationRepeatCount:1];
//    
//    NSLog(@"CENTER BEFOOOOOORRRRREEEEE222 %f", firstImage.center.x);
//    
////    firstImage.transform = CGAffineTransformMakeTranslation(firstImage.center.x,firstImage.center.y);
//    firstImage.transform = CGAffineTransformRotate(firstImage.transform, M_PI/2);
//
//    NSLog(@"CENTER BEFOOOOOORRRRREEEEE3333 %f", firstImage.center.x);
////    secondImage.transform = CGAffineTransformMakeTranslation(30.0,30.0);
//    secondImage.transform = CGAffineTransformRotate(secondImage.transform, M_PI/2);
//
//    NSLog(@"CENTER BEFOOOOOORRRRREEEEE444 %f", firstImage.center.x);
//    
//    [UIView commitAnimations];
//    
//    NSLog(@"CENTER AFTEEEEEERRRRRRRRRRR %f",firstImage.center.x);
//}


//- (void) rotateImagesToTheLeft{
//    
//    UIImage * portraitImage1 = firstImage;
//    firstImage = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
//                                                             scale: 1.0
//                                                       orientation: UIImageOrientationRight];
//
//    UIImage * portraitImage2 = secondImage;
//    secondImage = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
//                                                             scale: 1.0
//                                                       orientation: UIImageOrientationRight];
//    [self setNeedsDisplay];
//    
//    NSLog(@"GLA");
//}

//
//- (void) rotateImagesToTheRight{
//    
//    UIImage * portraitImage1 = firstImage;
//    firstImage = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
//                                                                scale: 1.0
//                                                          orientation: UIImageOrientationLeft];
//
//    UIImage * portraitImage2 = secondImage;
//    secondImage = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
//                                                                scale: 1.0
//                                                          orientation: UIImageOrientationLeft];
//
//    [self setNeedsDisplay];
//    
//    NSLog(@"GLAGLA");
//}
//
//- (void) rotateImagesToDefault{
//    
//    firstImage = [UIImage imageNamed:@"1st-focus.png"];
//    secondImage = [UIImage imageNamed:@"2nd-focus.png"];
//
//    [self setNeedsDisplay];
//
//    
//    NSLog(@"GLAGLAGLA");
//}
//
//-(void)rotateImagesUpsideDown{
//    
//    
//    UIImage * portraitImage1 = [UIImage imageNamed:@"1st-focus.png"];
//    firstImage = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
//                                            scale: 1.0
//                                      orientation: UIImageOrientationDown];
//    
//    UIImage * portraitImage2 = [UIImage imageNamed:@"2nd-focus.png"];
//    secondImage = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
//                                             scale: 1.0
//                                       orientation: UIImageOrientationDown];
//
//    
//    [self setNeedsDisplay];
//    
//    
//    NSLog(@"GLAGLAGLAGLA");
//
//}

@end
