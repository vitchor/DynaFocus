//
//  ActivityLabel.h
//  Goodrec
//
//  Created by Jeff Anderson on 8/12/08.
//  Copyright 2008 GoodRec. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ActivityLabel : UIView {
    UIActivityIndicatorView *m_spinnerView;
    NSString *m_text;
    UIFont *m_font;
    CGPoint m_textPos;
}

@property (nonatomic,readonly) UIActivityIndicatorView *spinner;

- (void)setText:(NSString *)text;
- (void)showSpinner:(BOOL)show;
- (void)setText:(NSString *)text showSpinner:(BOOL)show;

@end
