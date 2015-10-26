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

/**
 *  初始化通知体实例便利构造器
 *
 *  @param aName    通知名字
 *  @param anObject anObject
 *
 *  @return 通知体实例
 */
+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject;
+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

/**
 *  初始化通知体实例
 *
 *  @param name     通知名字
 *  @param object   object
 *  @param userInfo userInfo
 *
 *  @return  通知体实例
 */
- (instancetype)initWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end


@interface BJNotificationCenter : NSObject

/**
 *  创建通知中心服务
 *
 *  @return 返回通知中心实例
 */
+ (BJNotificationCenter *)defaultCenter;

/**
 *  注册通知
 *
 *  @param observer  注册人
 *  @param aSelector 注册响应方法
 *  @param aName     通知名字
 *  @param anObject  anObject
 */
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;

/**
 *  发送通知
 *
 *  @param notification 通知体类型
 */
- (void)postNotification:(BJNotification *)notification;

/**
 *  发送通知
 *
 *  @param aName    通知名字
 *  @param anObject anObject
 */
- (void)postNotificationName:(NSString *)aName object:(id)anObject;

/**
 *  删除注册人
 *
 *  @param observer 注册人
 */
- (void)removeObserver:(id)observer;

/**
 *  删除注册人
 *
 *  @param observer 注册人
 *  @param aName    通知名字
 *  @param anObject anObject
 */
- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject;

@end
