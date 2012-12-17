

#import "UIStyledLabel.h"


@implementation UIStyledLabel

- (void)drawRect:(CGRect)rect {
    
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGColorRef colorRef = self.textColor.CGColor;
	int numComponents = CGColorGetNumberOfComponents(colorRef);
	if (numComponents == 4) {
		const CGFloat *components = CGColorGetComponents(colorRef);
		CGFloat color[4] = {components[0], components[1], components[2], components[3]};
		CGContextSetStrokeColor(c, color);
	} else {
        NSLog(@"BULLSHIT");
		//CGFloat color[4] = {0.0, 0.0, 0.0, 1.0};
		CGContextSetStrokeColorWithColor(c, self.textColor.CGColor);
	}
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, 1.0f, 24.0f);
    CGContextAddLineToPoint(c, 119.0f, 24.0f);
    CGContextStrokePath(c);
	[super drawRect:rect];
    


}

@end
