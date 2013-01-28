//
//  DyfocusUITabBarController.m
//  DyFocus
//
//  Created by Victor Oliveira on 8/28/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "DyfocusUITabBarController.h"
#import "WebViewController.h"

@interface DyfocusUITabBarController ()

@end

@implementation DyfocusUITabBarController

@synthesize feedWebController, featuredWebController, lastControllerIndex, actualControllerIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    
    lastOrientation = [[UIDevice currentDevice] orientation];
    
    self.delegate = self;
    
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(orientationChanged:)
    //                                             name:UIDeviceOrientationDidChangeNotification
    //                                           object:nil];
  
    
    self.actualControllerIndex = -1;
    self.lastControllerIndex = -1;
    NSLog(@"Updating lastControllerIndex: %d", lastControllerIndex);
    
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
//    if (!(viewController == feedWebController )) {
//        
//        int orientation = [[UIDevice currentDevice] orientation];
//
//        if (orientation != UIDeviceOrientationPortrait) {
//        
//            UIViewController *c = [[UIViewController alloc]init];
//            [viewController presentModalViewController:c animated:NO];
//            [viewController dismissModalViewControllerAnimated:NO];
//            
//            [c release];
//            c = nil;
//            
//            if ([UIViewController respondsToSelector:@selector(attemptRotationToDeviceOrientation)]) {
//                // this ensures that the view will be presented in the orientation of the device
//                // This method is only supported on iOS 5.0.  iOS 4.3 users may get a little dizzy.
//                [UIViewController attemptRotationToDeviceOrientation];
//            }
//        }
//    }
    
    if (actualControllerIndex != -1) {
        self.lastControllerIndex = actualControllerIndex;
        NSLog(@"Updating lastControllerIndex: %d", lastControllerIndex);
    }
    
    self.actualControllerIndex = [self.viewControllers indexOfObject:viewController];
    NSLog(@"Updating actualControllerIndex: %d", actualControllerIndex);
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
