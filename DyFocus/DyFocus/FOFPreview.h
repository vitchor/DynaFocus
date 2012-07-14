//
//  FOFPreview.h
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FOFPreview : UIViewController {
    
    IBOutlet UIImageView *imageView;
    IBOutlet NSMutableArray *frames;
    IBOutlet UISlider *slider;
    
    int frameIndex;
}

@property(nonatomic,retain) IBOutlet UIImageView *imageView;
@property(nonatomic,retain) IBOutlet NSMutableArray *frames;
@property(nonatomic,retain) IBOutlet UISlider *slider;

-(IBAction)changeSlider:(id)sender;

@end
