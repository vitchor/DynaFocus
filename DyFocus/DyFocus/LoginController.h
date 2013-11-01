//
//  LoginController.h
//  DyFocus
//
//  Created by Victor Oliveira on 12/16/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNumberOfPages 3

@interface LoginController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate> {
    
    IBOutlet UIImageView *dyfocusIcon;
    IBOutlet UIButton *facebookConnectButton;
    IBOutlet UIButton *leftButton;
    IBOutlet UIButton *rightButton;
    IBOutlet UIView *borderView;
    
    IBOutlet UIButton *showSignupButton;
    IBOutlet UIButton *showLoginButton;
    
    // SIGNUP VIEW OUTLETS
    IBOutlet UIView      *signupView;
    IBOutlet UIButton    *signupCancelButton;
    IBOutlet UITextField *signupFullNameTextField;
    IBOutlet UILabel     *signupFullNameTextFieldErrorLabel;
    IBOutlet UITextField *signupEmailTextField;
    IBOutlet UILabel     *signupEmailTextFieldErrorLabel;
    IBOutlet UITextField *signupPasswordTextField;
    IBOutlet UILabel     *signupPasswordTextFieldErrorLabel;
    
    // LOGIN VIEW OUTLETS
    IBOutlet UIView      *loginView;
    IBOutlet UIButton    *loginCancelButton;
    IBOutlet UITextField *loginEmailTextField;
    IBOutlet UILabel     *loginEmailTextFieldErrorLabel;    
    IBOutlet UITextField *loginPasswordTextField;
    IBOutlet UILabel     *loginPasswordTextFieldErrorLabel;
    IBOutlet UIButton    *loginForgotPasswordButton;

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


@property (nonatomic, retain) IBOutlet UIButton     *showSignupButton;
// SIGNUP VIEW OUTLETS
@property (nonatomic, retain) IBOutlet UIView      *signupView;
@property (nonatomic, retain) IBOutlet UIButton    *signupCancelButton;
@property (nonatomic, retain) IBOutlet UITextField *signupFullNameTextField;
@property (nonatomic, retain) IBOutlet UILabel     *signupFullNameTextFieldErrorLabel;
@property (nonatomic, retain) IBOutlet UITextField *signupEmailTextField;
@property (nonatomic, retain) IBOutlet UILabel     *signupEmailTextFieldErrorLabel;
@property (nonatomic, retain) IBOutlet UITextField *signupPasswordTextField;
@property (nonatomic, retain) IBOutlet UILabel     *signupPasswordTextFieldErrorLabel;

@property (nonatomic, retain) IBOutlet UIButton     *showLoginButton;
// LOGIN VIEW OUTLETS
@property (nonatomic, retain) IBOutlet UIView      *loginView;
@property (nonatomic, retain) IBOutlet UIButton    *loginCancelButton;
@property (nonatomic, retain) IBOutlet UITextField *loginEmailTextField;
@property (nonatomic, retain) IBOutlet UILabel     *loginEmailTextFieldErrorLabel;
@property (nonatomic, retain) IBOutlet UITextField *loginPasswordTextField;
@property (nonatomic, retain) IBOutlet UILabel     *loginPasswordTextFieldErrorLabel;
@property (nonatomic, retain) IBOutlet UIButton    *loginForgotPasswordButton;

- (IBAction)changePage:(id)sender;

@end
