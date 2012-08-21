#import <UIKit/UIKit.h>
#import "ActivityLabel.h"

#define LOAD_VIEW_TAG 1234560
#define LOAD_VIEW_FADING_TAG 1234561


@interface LoadView : UIView {
    ActivityLabel *m_activityLabel;
}

+ (id)loadViewOnView:(UIView *)view;
+ (id)loadViewOnView:(UIView *)view withText:(NSString *)text;

+ (void)removeFromView:(UIView *)view;
+ (void)fadeAndRemoveFromView:(UIView *)view;

- (id)initOnView:(UIView *)view text:(NSString *)text backgroundAlpha:(CGFloat)alpha;
- (void)fadeAndRemoveFromView:(UIView *)view;
- (void)setText:(NSString *)text showSpinner:(BOOL)show;

@end
