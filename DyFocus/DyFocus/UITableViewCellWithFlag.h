//
//  UITableViewCellWithFlag.h
//  DyFocus
//
//  Created by Victor Oliveira on 11/17/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCellWithFlag : UITableViewCell {
    long flag;
}
@property(nonatomic, readwrite) long flag;

@end
