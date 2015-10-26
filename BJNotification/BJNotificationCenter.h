//
//  BJNotificationCenter.h
//  demo
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BJNotification : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) id object;
@property (nonatomic, copy) NSDictionary *userInfo;

+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject;
+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;
- (instancetype)initWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end


@interface BJNotificationCenter : NSObject

+ (BJNotificationCenter *)defaultCenter;

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;
- (void)postNotification:(BJNotification *)notification;
- (void)postNotificationName:(NSString *)aName object:(id)anObject;
- (void)removeObserver:(id)observer;
- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject;

@end
