//
//  DyfocusSettings.m
//  DyFocus
//
//  Created by mhss on 3/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "DyfocusSettings.h"

@implementation DyfocusSettings

@synthesize isFirstLogin;

// Singleton:
+(id)sharedSettings{
    static DyfocusSettings *sharedMySettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMySettings = [[self alloc] init];
    });
    return sharedMySettings;
}

// Singleton
- (id)init {
    if (self = [super init]) {
//        NSLog(@"==== reset isFirstLogin = NO");
//        isFirstLogin = NO;
    }
    return self;
}

// Singleton
- (void)dealloc {
//    [super dealloc];
    // Should never be called, but just here for clarity really.
}

//-(BOOL) setFirstLogin:(BOOL)flag{
//    @try {
//        isFirstLogin = flag;
//        return YES;
//    }@catch (NSException * e){
//        NSLog(@"Exception: %@", e);
//        return NO;
//    }
//}

@end
