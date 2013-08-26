//
//  PathView.h
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraView;

@interface PathView : UIView {
    
    bool enabled;
    float fadeDuration;
    
    CGContextRef context;
    CGColorRef ref;
    NSMutableArray *touchPoints;
    NSMutableArray *focusPoints;
    UIDeviceOrientation lastOrientation;
    
    CameraView *cameraViewController;
    
    IBOutlet UIView* firstImage;
    IBOutlet UIView* secondImage;
    IBOutlet NSLayoutConstraint *firstFocusX;
    IBOutlet NSLayoutConstraint *firstFocusY;
    IBOutlet NSLayoutConstraint *firstFocusX2;
    IBOutlet NSLayoutConstraint *firstFocusY2;
    IBOutlet NSLayoutConstraint *secondFocusX;
    IBOutlet NSLayoutConstraint *secondFocusY;
    IBOutlet NSLayoutConstraint *secondFocusX2;
    IBOutlet NSLayoutConstraint *secondFocusY2;
    
    IBOutlet UIButton *torchOneButton;
    IBOutlet UIButton *torchTwoButton;
  
    IBOutlet UIButton *cancelIcon;
    IBOutlet UIButton *cameraIcon;
    IBOutlet UIButton *helpIcon;
    
    IBOutlet UIImageView *firstFocusImageView;
    IBOutlet UIImageView *secondFocusImageView;
}

@property(nonatomic,retain) NSMutableArray *touchPoints;
@property(nonatomic,readwrite)CGContextRef context;
@property(nonatomic,readwrite)CGColorRef ref;
@property(nonatomic,readwrite)bool enabled;
@property(nonatomic,strong)CameraView *cameraViewController;
@property(nonatomic,readwrite) UIDeviceOrientation lastOrientation;

@property(nonatomic,retain) IBOutlet UIImageView *firstFocusImageView;
@property(nonatomic,retain) IBOutlet UIImageView *secondFocusImageView;

-(NSMutableArray *)getPoints;
-(void)clearPoints;
-(void)checkOrientations:(BOOL)isFirstTime;

@end
