//
//  ActivityLabel.m
//  Goodrec
//
//  Created by Jeff Anderson on 8/12/08.
//  Copyright 2008 GoodRec. All rights reserved.
//

#import "ActivityLabel.h"

#define SPINNER_SIZE 16
#define SPINNER_SPACING 5


@implementation ActivityLabel

@synthesize spinner = m_spinnerView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        CGRect spinnerFrame = CGRectMake((frame.size.width-SPINNER_SIZE)/2,(frame.size.height-SPINNER_SIZE)/2,SPINNER_SIZE,SPINNER_SIZE);
        m_spinnerView = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
        m_spinnerView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [self addSubview:m_spinnerView];
        m_font = [[UIFont systemFontOfSize:16] retain];
        
        // For screen capture
        //m_spinnerView.hidesWhenStopped = NO;
        //[m_spinnerView stopAnimating];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [[UIColor lightGrayColor] set];    
    [m_text drawAtPoint:m_textPos withFont:m_font];
}

- (void)dealloc {
    [m_text release];
    [m_font release];
    [super dealloc];
}

- (void)resize {
    CGSize ts = [m_text sizeWithFont:m_font];
    CGRect vf = self.frame;
    CGRect sf = m_spinnerView.frame;
    int sw = m_spinnerView.isAnimating?sf.size.width+SPINNER_SPACING:0;
    sf.origin.x = (vf.size.width-(sw+ts.width))/2;
    m_spinnerView.frame = sf;
    m_textPos.x = sf.origin.x+sw;
    m_textPos.y = (vf.size.height-ts.height)/2;
    [self setNeedsDisplay];
}

- (void)showSpinner:(BOOL)show {
    if (show) [m_spinnerView startAnimating];
    else [m_spinnerView stopAnimating];
    [self resize];
}

- (void)setText:(NSString *)text {
    [m_text release];
    m_text = text;
    [m_text retain];
    [self resize];
}

- (void)setText:(NSString *)text showSpinner:(BOOL)show {
    if (show) [m_spinnerView startAnimating];
    else [m_spinnerView stopAnimating];
    [m_text release];
    m_text = text;
    [m_text retain];
    [self resize];
}

@end
