//
//  Person.h
//  DyFocus
//
//  Created by mhss on 3/18/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MYSELF 1                 // kind = 0: friend on both, App and  on  facebook
#define FRIENDS_ON_APP_AND_FB 2  // kind = 1: friend on both, App and  on  facebook
#define FRIENDS_ON_FB 3          // kind = 2: not a friend on App, just on facebook
#define FRIENDS_ON_APP 4         // kind = 3: friend just on App, NOT on facebook but a facebook user

@interface Person: NSObject {
    long m_uid;
    int m_kind;
	NSString *m_name;
	NSString *m_facebookUserName; // facebookUserName
	NSString *m_email;
    NSString *m_facebookId;
    float m_timezone;
    NSString *m_location;
	BOOL m_selected;
}

@property(nonatomic, readonly) long uid;
@property(nonatomic, assign) int kind;
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *facebookUserName;
@property(nonatomic, readonly) NSString *email;
@property(nonatomic, readonly) NSString *facebookId;
@property(nonatomic, readonly) float timezone;
@property(nonatomic, readonly) NSString *location;
@property(nonatomic, assign) BOOL selected;

- (id) initWithId:(long)iUid andName:(NSString *)iName andUserName:(NSString *)iUserName andfacebookId:(NSString *)iFacebookId;
- (id)initWithIdAndKind:(long)iUid andName:(NSString *)iName andUserName:(NSString *)iUserName andfacebookId:(NSString *)iFacebookId andKind:(int)iKind;
- (id)initWithDic:(NSMutableDictionary*) facebookUser;
- (id)initWithDicAndKind:(NSMutableDictionary*) facebookUser andKind:(int)kind;

@end