//
//  TutorialView.h
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 6/24/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraView;

@interface TutorialView : UIImageView {

    NSEnumerator *instructionsImagesEnumerator;
    NSMutableArray *instructionsImagesArray;
    
    CameraView *cameraViewController;
}

@property(nonatomic,retain) NSEnumerator *instructionsImagesEnumerator;
@property(nonatomic,strong) CameraView *cameraViewController;

-(void)loadTutorial:(BOOL)shouldShowTutorial;

@end
