//
//  PathView.m
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "PathView.h"

@implementation PathView

@synthesize touchPoints, ref, context;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
	context = UIGraphicsGetCurrentContext();
	
	ref =  [[UIColor redColor] CGColor];
	
	if ([touchPoints count] >= 1) {
		
        CGContextSetLineWidth(context, 10);
		CGContextSetStrokeColorWithColor(context, ref);
        
        CGPoint firstPoint = [[touchPoints objectAtIndex:0] CGPointValue];
		
		
        if ([touchPoints count] == 1) {
            CGContextStrokeEllipseInRect(context, CGRectMake(firstPoint.x - 10, firstPoint.y - 10, 20, 20));
        } else {
            CGPoint lastPoint;
            for (NSObject *point in touchPoints) {
                CGPoint cgPoint = [(NSValue *)point CGPointValue];
                CGContextStrokeEllipseInRect(context, CGRectMake(cgPoint.x - 10, cgPoint.y - 10, 20, 20));
                
                
                CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
                
                if ([touchPoints indexOfObject:point] != 0) {
                    CGContextAddLineToPoint(context, cgPoint.x, cgPoint.y);
                    CGContextStrokePath(context);
                }
                lastPoint = cgPoint;
            }
        }
		
        
		CGContextStrokePath(context);
	}
	
}

-(void)clearPoints{
	
	if(touchPoints!=nil){
		[touchPoints removeAllObjects];
        [self setNeedsDisplay];
	}
}

- (void)addPoint:(CGPoint)actualTouchPoint {
	
	if (touchPoints == nil) {
		touchPoints = [[NSMutableArray alloc] initWithObjects:nil];
	}
	
	NSValue *value = [NSValue valueWithCGPoint:actualTouchPoint];
	[touchPoints addObject:value];
	
}

- (NSMutableArray *)getPoints {
	
    NSMutableArray *focusPoints = [[NSMutableArray alloc] init];
    
    for (NSObject *point in touchPoints) {
        CGPoint touchPoint = [(NSValue *)point CGPointValue];
        
        NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(1 - touchPoint.x / self.frame.size.width, touchPoint.y / self.frame.size.height)];
        [focusPoints addObject:pointValue];
    }
    
    return focusPoints;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    [self addPoint:touchPoint];
    
    
    [self setNeedsDisplay];
    
    NSLog(@"TOUUUCH (%f, %f)", 1 - touchPoint.x / self.frame.size.width, touchPoint.y / self.frame.size.height);    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

@end
