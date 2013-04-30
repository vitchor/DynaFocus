//
//  LoginController.h
//  DyFocus
//
//  Created by Victor Oliveira on 12/16/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNumberOfPages 3

@interface LoginController : UIViewController <UIScrollViewDelegate> {
    
    IBOutlet UIButton *facebookConnectButton;
    IBOutlet UIButton *leftButton;
    IBOutlet UIButton *rightButton;
    IBOutlet UIView *borderView;

    IBOutlet NSMutableArray *fofs;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    BOOL pageControlUsed;
    
    NSString *fofName;

}

@property(nonatomic,retain) IBOutlet UIButton *facebookConnectButton;
@property(nonatomic,retain) IBOutlet UIButton *leftButton;
@property(nonatomic,retain) IBOutlet UIButton *rightButton;
@property(nonatomic,retain) IBOutlet UIView *borderView;

@property(nonatomic,retain) IBOutlet NSMutableArray *fofs;
@property(nonatomic,retain) IBOutlet NSMutableArray *focalPoints;


@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllers;

- (IBAction)changePage:(id)sender;

@end
