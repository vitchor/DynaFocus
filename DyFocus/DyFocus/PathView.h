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
    
    CGContextRef context;
    CGColorRef ref;
    NSMutableArray *touchPoints;
    NSMutableArray *focusPoints;
    UIDeviceOrientation lastOrientation;
    
    CameraView *cameraViewController;
    
    IBOutlet UIImageView* firstImage;
    IBOutlet UIImageView* secondImage;
    IBOutlet NSLayoutConstraint *firstFocusX;
    IBOutlet NSLayoutConstraint *firstFocusY;
    IBOutlet NSLayoutConstraint *secondFocusX;
    IBOutlet NSLayoutConstraint *secondFocusY;
    
    IBOutlet UIButton *torchOneButton;
    IBOutlet UIButton *torchTwoButton;
    IBOutlet NSLayoutConstraint *torchOneX;
    IBOutlet NSLayoutConstraint *torchOneY;
    IBOutlet NSLayoutConstraint *torchTwoX;
    IBOutlet NSLayoutConstraint *torchTwoY;

    IBOutlet UIButton *cancelIcon;
    IBOutlet UIButton *cameraIcon;
    IBOutlet UIButton *helpIcon;
}

@property(nonatomic,retain) NSMutableArray *touchPoints;
@property(nonatomic,readwrite)CGContextRef context;
@property(nonatomic,readwrite)CGColorRef ref;
@property(nonatomic,readwrite)bool enabled;
@property(nonatomic,strong)CameraView *cameraViewController;
@property(nonatomic,retain) IBOutlet UIButton *cancelIcon;
@property(nonatomic,retain) IBOutlet UIButton *cameraIcon;
@property(nonatomic,retain) IBOutlet UIButton *helpIcon;


-(NSMutableArray *)getPoints;
-(void)clearPoints;
-(void)resetOrientations;
-(void)checkOrientations;

@end
