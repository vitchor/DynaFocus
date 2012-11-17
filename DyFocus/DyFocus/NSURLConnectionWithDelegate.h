//
//  NSURLConnectionWithDelegate.h
//  DyFocus
//
//  Created by Victor Oliveira on 11/17/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnectionWithDelegate : NSURLConnection {
    int uid;
}

+ (NSURLConnectionWithDelegate*)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate andId:(int)uid;

@property(nonatomic, readwrite) int uid;
@end
