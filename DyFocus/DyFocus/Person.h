//
//  Person.h
//  DyFocus
//
//  Created by mhss on 3/18/13.
//  Copyright (c) 2013 dyfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
extern int MYSELF;                 // kind = 0: friend on both, App and  on  facebook
extern int FRIENDS_ON_APP_AND_FB;  // kind = 1: friend on both, App and  on  facebook
extern int FRIENDS_ON_FB;          // kind = 2: not a friend on App, just on facebook
extern int FRIENDS_ON_APP;         // kind = 3: friend just on App, NOT on facebook but a facebook user

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
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *facebookUserName;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *facebookId;
@property(nonatomic, readonly) float timezone;
@property(nonatomic, readonly) NSString *location;
@property(nonatomic, assign) BOOL selected;

- (id) initWithId:(long)iUid andName:(NSString *)iName andUserName:(NSString *)iUserName andfacebookId:(NSString *)iFacebookId;
- (id)initWithIdAndKind:(long)iUid andName:(NSString *)iName andUserName:(NSString *)iUserName andfacebookId:(NSString *)iFacebookId andKind:(int)iKind;
- (id)initWithDic:(NSMutableDictionary*) facebookUser;
- (id)initWithDicAndKind:(NSMutableDictionary*) facebookUser andKind:(int)kind;

@end