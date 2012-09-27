#import "LoadView.h"

@implementation LoadView

+ (id)loadViewOnView:(UIView *)view {
    return [[[LoadView alloc] initOnView:view text:nil backgroundAlpha:0.8] autorelease];
}

+ (id)loadViewOnView:(UIView *)view withText:(NSString *)text {
    return [[[LoadView alloc] initOnView:view text:text backgroundAlpha:0.8] autorelease];
}

- (id)initWithFrame:(CGRect)frame {
    CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self = [super initWithFrame:rect];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        m_activityLabel = [[ActivityLabel alloc] initWithFrame:CGRectMake(0, (frame.size.height - 30) / 2, frame.size.width, 30)];
        m_activityLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:m_activityLabel];
    }
    return self;
}

- (id)initOnView:(UIView *)view text:(NSString *)text backgroundAlpha:(CGFloat)alpha {
    CGRect frame = view.bounds;
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:alpha];
        self.tag = LOAD_VIEW_TAG;
        [view addSubview:self];
        
        m_activityLabel = [[ActivityLabel alloc] initWithFrame:CGRectMake(0, (frame.size.height - 30) / 2, frame.size.width, 30)];
        m_activityLabel.backgroundColor = [UIColor clearColor];
        [self setText:text showSpinner:YES];
        [self addSubview:m_activityLabel];
    }
    return self;
}

- (void)dealloc {
    [m_activityLabel release];
    [super dealloc];
}

- (void)setText:(NSString *)text showSpinner:(BOOL)show {
    [m_activityLabel setText:text showSpinner:show];
}

+ (void)removeFromView:(UIView*)view {
    LoadView *loadView = (LoadView*)[view viewWithTag:LOAD_VIEW_TAG];
    if ([loadView isKindOfClass:[LoadView class]]) {
        [loadView removeFromSuperview];
    }
}

- (void)fadeAndRemoveFromView:(UIView*)view {
    self.tag = LOAD_VIEW_FADING_TAG;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDuration:0.3];
    self.alpha = 0.0;
    [UIView commitAnimations];
}

+ (void)fadeAndRemoveFromView:(UIView*)view {
    LoadView *loadView = (LoadView*)[view viewWithTag:LOAD_VIEW_TAG];
    if ([loadView isKindOfClass:[LoadView class]]) {
        [loadView fadeAndRemoveFromView:view];
    }
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    [self removeFromSuperview];
}

@end
