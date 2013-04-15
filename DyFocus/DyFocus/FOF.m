//
//  FOF.m
//  DyFocus
//
//  Created by Victor on 4/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "FOF.h"

@implementation FOF

@synthesize m_name, m_frames, m_comments, m_likes, m_userName, m_userId, m_date, m_userNickname, m_id, m_liked;

+(FOF *)fofFromJSON: (NSDictionary *)json {
    
    FOF *fof = [FOF alloc];
    
    NSString *facebook_id = [json valueForKey:@"user_facebook_id"];
    NSString *name = [json valueForKey:@"user_name"];
    
    NSString *fofId = [json valueForKey:@"id"];
    NSString *fofName = [json valueForKey:@"fof_name"];
    
    NSString *liked = [json valueForKey:@"liked"];
    
    NSDictionary *frames = [json valueForKey:@"frames"];
    
    NSString *pubDate = [json valueForKey:@"pub_date"];
    
    NSString *comments = [json valueForKey:@"comments"];
    
    NSString *likes = [json valueForKey:@"likes"];
    
    NSMutableArray *framesData = [NSMutableArray array];
    
    for (int index = 0; index < [frames count]; index++) {
        
        NSDictionary *jsonFrame = [frames objectAtIndex:index];
        
        NSMutableDictionary *frameData = [NSMutableDictionary dictionary];
        
        [frameData setValue:[jsonFrame objectForKey:@"frame_url"] forKey:@"frame_url"];
        
        [frameData setValue:[jsonFrame objectForKey:@"frame_index"] forKey:@"frame_index"];
        
        [framesData addObject:frameData];
        
    }
    
    fof.m_id = fofId;
    fof.m_name = fofName;
    fof.m_liked = [liked isEqualToString:@"1"];
    fof.m_userName = name;
    fof.m_userId = facebook_id;
    fof.m_frames = framesData;
    fof.m_likes = likes;
    fof.m_comments = comments;
    fof.m_date = pubDate;
    
    liked = nil;
    
    return fof;
}

- (void)dealloc {
    [m_name release];
    [m_frames release];
    [m_comments release];
    [m_userName release];
    [m_date release];
    [m_userNickname release];
    [m_likes release];
    [m_userId release];
    [m_id release];
	[super dealloc];
}

@end

