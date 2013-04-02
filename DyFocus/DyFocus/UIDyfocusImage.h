//
//  UIDyfocusImage.h
//  DyFocus
//
//  Created by Victor on 2/6/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDyfocusImage : UIImage {
    int index;
    NSString *faceId;   // Used to know which user has it's photo loaded. In case The user logs out and with another user logs in
}

@property (nonatomic, readwrite) int index;
@property (nonatomic, unsafe_unretained) NSString *faceId;

@end
