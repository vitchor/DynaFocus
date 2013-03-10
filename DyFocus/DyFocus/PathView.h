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
    
    NSMutableArray *touchPoints;
	CGContextRef context;
    CGColorRef ref;
    bool enabled;
    NSMutableArray *focusPoints;
    CameraView *cameraViewController;
    IBOutlet UIImageView* firstImage;
    IBOutlet UIImageView* secondImage;
}

@property(nonatomic,retain) NSMutableArray *touchPoints;
@property(nonatomic,readwrite)CGContextRef context;
@property(nonatomic,readwrite)CGColorRef ref;
@property(nonatomic,readwrite)bool enabled;
@property(nonatomic,strong)CameraView *cameraViewController;
@property(nonatomic,retain) IBOutlet UIImageView *firstImage;
@property(nonatomic,retain) IBOutlet UIImageView *secondImage;

-(void)clearPoints;
-(NSMutableArray *)getPoints;
-(void)setDefaultImages;
-(void)rotateImagesToTheLeft;
-(void)rotateImagesToTheRight;
-(void)rotateImagesToDefault;
-(void)rotateImagesUpsideDown;

@end
