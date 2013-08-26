//
//  FOF.m
//  DyFocus
//
//  Created by Victor on 4/14/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import "FOF.h"

@implementation FOF

@synthesize m_name, m_userId, m_frames, m_comments, m_likes, m_userName, m_userFacebookId, m_date, m_userNickname, m_id, m_liked, m_private, m_description;

+(FOF *)fofFromJSON: (NSDictionary *)json {
    
    FOF *fof = [FOF alloc];
    
    long user_id = [[json valueForKey:@"user_id"] longLongValue];
    NSString *facebook_id = [json valueForKey:@"user_facebook_id"];
    NSString *name = [json valueForKey:@"user_name"];
    NSString *fofId = [json valueForKey:@"id"];
    NSString *fofName = [json valueForKey:@"fof_name"];
    NSString *liked = [json valueForKey:@"liked"];
    NSNumber *isPrivate = [json valueForKey:@"is_private"];
    NSDictionary *frames = [json valueForKey:@"frames"];
    NSString *pubDate = [json valueForKey:@"pub_date"];
    NSString *comments = [json valueForKey:@"comments"];
    NSString *likes = [json valueForKey:@"likes"];
    NSString *description = [json valueForKey:@"fof_description"];
    
//No description:
//    NSString *description = @"";

//1 line description:
//    NSString *description = @"Lorem ipsum dolor sit amet.";

//2 lines description:
//    NSString *description = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit.";

//3 lines description:
//    NSString *description = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Etiam eget ligula eu lectus lobortis condimentum.";

//4 lines or more description:
//    NSString *description = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Etiam eget ligula eu lectus lobortis condimentum. Aliquam nonummy auctor massa. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nulla at risus. Quisque purus magna, auctor et, sagittis ac, posuere eu, lectus. Nam mattis, felis ut adipiscing.";
    
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
    fof.m_private = [isPrivate isEqualToNumber:[NSNumber numberWithInt:1]];
    fof.m_liked = [liked isEqualToString:@"1"];
    fof.m_userName = name;
    fof.m_userFacebookId = facebook_id;
    fof.m_frames = framesData;
    fof.m_likes = likes;
    fof.m_comments = comments;
    fof.m_date = pubDate;
    fof.m_userId = user_id;
    fof.m_description = description;
    
    NSLog(@"OLHA A DESCRIIIIIIIIPTIONNNNNNNNNNNNNNNNNN:  %@", description);
    
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
    [m_userFacebookId release];
    [m_id release];
    [m_description release];
	[super dealloc];
}

@end

