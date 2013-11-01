//
//  TutorialView.h
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 6/24/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

#define kNumberOfTutorialPages 5
#define kGifPage 2
#define fAnimationDuration 4.0

@interface TutorialView : UIViewController  <UIScrollViewDelegate, MFMailComposeViewControllerDelegate>{
    
    IBOutlet UILabel *supportEmailLabel;
    
    IBOutlet UIView *shadowView;
    IBOutlet UIView *pageController0;
    IBOutlet UIView *pageController1;
    IBOutlet UIView *pageController2;
    IBOutlet UIView *pageController3;
    IBOutlet UIView *pageController4;
    
    IBOutlet UIImageView *gifImageView;
    
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIScrollView *scrollView;

    NSMutableArray *pageControllers;
}

@property (nonatomic, retain) NSMutableArray *pageControllers;

@end
