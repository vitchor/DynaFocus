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
	
	BOOL isPointDiscontinued = FALSE;
	
	context = UIGraphicsGetCurrentContext();
	
	ref =  [[UIColor redColor] CGColor];
	
	if([touchPoints count]>1){
		CGContextSetLineWidth(context, 25);
		
		CGContextSetStrokeColorWithColor(context, ref);
        
		CGPoint firstPoint = [[touchPoints objectAtIndex:0] CGPointValue];
		
		CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
		
		for (NSObject *point in touchPoints) {
			
			if([point isKindOfClass:[NSString class]])
			{
				isPointDiscontinued=TRUE;
			}else if(isPointDiscontinued && ![point isKindOfClass:[NSString class]]){
				CGPoint cgPoint = [(NSValue *)point CGPointValue];
				CGContextMoveToPoint(context, cgPoint.x, cgPoint.y);
				isPointDiscontinued=FALSE;
			}else if(!isPointDiscontinued){
				
				CGPoint cgPoint = [(NSValue *)point CGPointValue];
				CGContextAddLineToPoint(context, cgPoint.x, cgPoint.y);
			}
		}
		CGContextStrokePath(context);
	}
	
}

-(void)clearPoints{
	
	if(touchPoints!=nil){
		//dealocating NSFStrings
		for (NSObject *point in touchPoints) {		
			if([point isKindOfClass:[NSString class]]){
				[point release];
			}
		}
		
		[touchPoints removeAllObjects];
	}
}

- (void)addPoint:(CGPoint)actualTouchPoint {
	
	if (touchPoints == nil) {
		touchPoints = [[NSMutableArray alloc] initWithObjects:nil];
	}
	
	NSValue *value = [NSValue valueWithCGPoint:actualTouchPoint];
	[touchPoints addObject:value];
	
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
