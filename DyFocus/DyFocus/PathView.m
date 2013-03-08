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

- (void) setDefaultImages{
    
    firstImage = [UIImage imageNamed:@"1st-focus.png"];
    secondImage = [UIImage imageNamed:@"2nd-focus.png"];
    
//    firstImage = [[UIImageView alloc] initWithImage:firstImageTmp];
//    secondImage = [[UIImageView alloc] initWithImage:secondImageTmp];

}

- (void)drawRect:(CGRect)rect {
	
    context = UIGraphicsGetCurrentContext();
	
	ref =  [[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.3] CGColor];
	
	if ([touchPoints count] >= 1) {
		
        // Old codes used when the "point" and the "line" were drawn:
        //
        CGContextSetLineWidth(context, 8);
		CGContextSetStrokeColorWithColor(context, ref);
        CGContextSetFillColor(context, CGColorGetComponents([UIColor colorWithRed:255/255 green:50/255 blue:50/255 alpha:0.9].CGColor));
        
		CGPoint firstPoint = [[touchPoints objectAtIndex:0] CGPointValue];
		
//        if ([touchPoints count] == 1) {
//            [firstImage drawInRect:CGRectMake(firstPoint.x - 40, firstPoint.y - 40, 80, 80) blendMode:0 alpha:0.6];
//            //CGContextFillEllipseInRect(context, CGRectMake(firstPoint.x - 10, firstPoint.y - 10, 20, 20));
//            
//        } else if ([touchPoints count] == 2){
        
        if ([touchPoints count] >= 1){
           
            for (NSObject *point in touchPoints) {
                
                CGPoint cgPoint = [(NSValue *)point CGPointValue];
                
                if ([touchPoints indexOfObject:point] == 0) {
                    [firstImage drawInRect:CGRectMake(cgPoint.x - 40, cgPoint.y - 40, 80, 80) blendMode:0 alpha:0.6];
                   // CGContextDrawImage(context, CGRectMake(cgPoint.x - 50, cgPoint.y - 50, 100, 100), firstImage.CGImage);
                }
                else {
                    [secondImage drawInRect:CGRectMake(cgPoint.x - 40, cgPoint.y - 40, 80, 80) blendMode:0 alpha:0.6];
                    //CGContextDrawImage(context, CGRectMake(cgPoint.x - 50, cgPoint.y - 50, 100, 100), secondImage.CGImage);
                }
            }
            
        }
        
            
//            
//            CGPoint lastPoint;
//            for (NSObject *point in touchPoints) {
//                CGPoint cgPoint = [(NSValue *)point CGPointValue];
//                //CGContextStrokeEllipseInRect(context, CGRectMake(cgPoint.x - 10, cgPoint.y - 10, 20, 20));
//                
//                
//                CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
//                
//                if ([touchPoints indexOfObject:point] != 0) {
//                    CGContextAddLineToPoint(context, cgPoint.x, cgPoint.y);
//                    CGContextStrokePath(context);
//                }
//                lastPoint = cgPoint;
//                
//            }
//            
//            for (NSObject *point in touchPoints) {
//                CGPoint cgPoint = [(NSValue *)point CGPointValue];
//                CGContextDrawImage(context, CGRectMake(cgPoint.x - 50, cgPoint.y - 50, 100, 100), secondImage.CGImage);
//                //CGContextFillEllipseInRect(context, CGRectMake(cgPoint.x - 10, cgPoint.y - 10, 20, 20));
//            }
            
//        }
        
		//CGContextStrokePath(context);
	}
	
}


-(void)clearPoints{
	
	if(touchPoints!=nil){
		[touchPoints removeAllObjects];
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


- (void) rotateImagesToTheLeft{
    
    UIImage * portraitImage1 = firstImage;
    firstImage = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
                                                             scale: 1.0
                                                       orientation: UIImageOrientationRight];

    UIImage * portraitImage2 = secondImage;
    secondImage = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
                                                             scale: 1.0
                                                       orientation: UIImageOrientationRight];
    [self setNeedsDisplay];
    
    NSLog(@"GLA");
}

- (void) rotateImagesToTheRight{
    
    UIImage * portraitImage1 = firstImage;
    firstImage = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
                                                                scale: 1.0
                                                          orientation: UIImageOrientationLeft];

    UIImage * portraitImage2 = secondImage;
    secondImage = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
                                                                scale: 1.0
                                                          orientation: UIImageOrientationLeft];

    [self setNeedsDisplay];
    
    NSLog(@"GLAGLA");
}

- (void) rotateImagesToDefault{
    
    firstImage = [UIImage imageNamed:@"1st-focus.png"];
    secondImage = [UIImage imageNamed:@"2nd-focus.png"];

    [self setNeedsDisplay];

    
    NSLog(@"GLAGLAGLA");
}

-(void)rotateImagesUpsideDown{
    
    
    UIImage * portraitImage1 = [UIImage imageNamed:@"1st-focus.png"];
    firstImage = [[UIImage alloc] initWithCGImage: portraitImage1.CGImage
                                            scale: 1.0
                                      orientation: UIImageOrientationDown];
    
    UIImage * portraitImage2 = [UIImage imageNamed:@"2nd-focus.png"];
    secondImage = [[UIImage alloc] initWithCGImage: portraitImage2.CGImage
                                             scale: 1.0
                                       orientation: UIImageOrientationDown];

    
    [self setNeedsDisplay];
    
    
    NSLog(@"GLAGLAGLAGLA");

}

@end
