//
//  DyfocusSettings.h
//  DyFocus
//
//  Created by mhss on 3/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DyfocusSettings : NSObject{
    BOOL isFirstLogin;
}
@property (nonatomic) BOOL isFirstLogin;

+ (id) sharedSettings;
//-(BOOL) setFirstLogin:(BOOL)flag;

@end
