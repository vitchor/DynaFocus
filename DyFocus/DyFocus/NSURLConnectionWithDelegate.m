//
//  NSURLConnectionWithDelegate.m
//  DyFocus
//
//  Created by Victor Oliveira on 11/17/12.
//  Copyright (c) 2012 Ufscar. All rights reserved.
//

#import "NSURLConnectionWithDelegate.h"

@implementation NSURLConnectionWithDelegate
@synthesize uid;
   

+ (NSURLConnectionWithDelegate*)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate andId:(int)uid {
    
    NSURLConnectionWithDelegate *connection= (NSURLConnectionWithDelegate *)[super connectionWithRequest:request delegate:delegate];
    connection.uid = uid;
    
    return connection;
}

@end
