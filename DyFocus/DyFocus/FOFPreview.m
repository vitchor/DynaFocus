
//  FOFPreview.m
//  DyFocus
//
//  Created by Marcia  Rozenfeld on 7/14/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "FOFPreview.h"
#import "ASIFormDataRequest.h"

@implementation FOFPreview

@synthesize imageView, frames, slider;

-(IBAction)changeSlider:(id)sender 
{
    
    float share = 100 / [frames count];
    
    for (int i = 1; i <= [frames count]; i++) {
        if (round(slider.value)  < i*share ) {


            NSLog(@"Slider Value: %f", slider.value);
            
            if (frameIndex != i - 1) {
                frameIndex = i - 1;
                
                NSLog(@"FRAME INDEX: %d", frameIndex);
                
                [imageView setImage: [frames objectAtIndex:frameIndex]];
                
            }
            break;

        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.imageView setImage: [self.frames objectAtIndex:0]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated
{

   
  
}
@end
