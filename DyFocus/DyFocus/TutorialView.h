//
//  TutorialView.h
//  DyFocus
//
//  Created by Cassio Marcos Goulart on 6/24/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@class CameraView;

@interface TutorialView : UIImageView  <MFMailComposeViewControllerDelegate>{

    IBOutlet UILabel *supportEmailLabel;
    
    NSMutableArray *instructionsImagesArray;
    
    CameraView *cameraViewController;
}

@property(nonatomic,retain) NSEnumerator *instructionsImagesEnumerator;
@property(nonatomic,strong) CameraView *cameraViewController;

-(void)loadTutorial:(BOOL)shouldShowTutorial;

@end
