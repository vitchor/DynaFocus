//
//  NSDyfocusURLRequest.h
//  DyFocus
//
//  Created by Victor on 2/6/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDyfocusURLRequest : NSURLRequest {
    
    int tag;
    NSString *id;
}

@property (nonatomic, readwrite) int tag;
@property (nonatomic, retain) NSString *id;

@end
