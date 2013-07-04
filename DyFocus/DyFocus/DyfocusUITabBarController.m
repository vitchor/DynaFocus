//
//  DyfocusUITabBarController.m
//  DyFocus
//
//  Created by Victor Oliveira on 8/28/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "DyfocusUITabBarController.h"
#import "AppDelegate.h"

@interface DyfocusUITabBarController ()

@end

@implementation DyfocusUITabBarController

@synthesize lastControllerIndex, actualControllerIndex;

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
    
    if (actualControllerIndex != -1) {
        self.lastControllerIndex = actualControllerIndex;
        NSLog(@"Updating lastControllerIndex: %d", lastControllerIndex);
    }
    
    self.actualControllerIndex = [self.viewControllers indexOfObject:viewController];
    NSLog(@"Updating actualControllerIndex: %d", actualControllerIndex);
    
    if(actualControllerIndex == 4)
        [self resetTabBarControllerTransitionView];
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

-(void)resetTabBarControllerTransitionView
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;
    
    for(UIView *view in delegate.tabBarController.view.subviews)
    {
        if(![view isKindOfClass:[UITabBar class]]){
            
            [view setFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y,
                                      view.frame.size.width, screenBounds.size.height-delegate.tabBarController.tabBar.frame.size.height)];
        }
    }
}

@end
