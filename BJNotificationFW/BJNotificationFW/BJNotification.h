//
//  BJNotification.h
//  BJNotification
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/****************	BJNotification	****************/

@interface BJNotification : NSObject

@property (nonatomic, copy) NSString *name;
@property (nullable, nonatomic, strong) id object;
@property (nullable, nonatomic, copy) NSDictionary *userInfo;

/**
 *  初始化通知体实例便利构造器
 *
 *  @param aName    通知名字
 *  @param anObject anObject
 *
 *  @return 通知体实例
 */
+ (instancetype)notificationWithName:(NSString *)aName
                              object:(nullable id)anObject;

/**
 *  初始化通知体实例便利构造器
 *
 *  @param aName    通知名字
 *  @param anObject anObject
 *  @param aUserInfo aUserInfo
 *
 *  @return 通知体实例
 */
+ (instancetype)notificationWithName:(NSString *)aName
                              object:(nullable id)anObject
                            userInfo:(nullable NSDictionary *)aUserInfo;

/**
 *  初始化通知体实例
 *
 *  @param name     通知名字
 *  @param object   object
 *  @param userInfo userInfo
 *
 *  @return  通知体实例
 */
- (instancetype)initWithName:(NSString *)name
                      object:(nullable id)object
                    userInfo:(nullable NSDictionary *)userInfo;

@end

/****************	BJNotificationCenter	****************/

@interface BJNotificationCenter : NSObject

/**
 *  创建通知中心服务
 *
 *  @return 返回通知中心实例
 */
+ (instancetype)defaultCenter;

/**
 *  注册通知
 *
 *  @param observer  注册者
 *  @param aSelector 注册响应方法
 *  @param aName     通知名字
 *  @param anObject  anObject
 */
- (void)addObserver:(id)observer
           selector:(SEL)aSelector
               name:(NSString *)aName
             object:(nullable id)anObject;

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
- (void)postNotificationName:(NSString *)aName
                      object:(nullable id)anObject;

/**
 *  删除注册者
 *
 *  @param observer 注册者
 */
- (void)removeObserver:(id)observer;

/**
 *  删除注册者
 *
 *  @param observer 注册者
 *  @param aName    通知名字
 *  @param anObject anObject
 */
- (void)removeObserver:(id)observer
                  name:(nullable NSString *)aName
                object:(nullable id)anObject;

@end

#define OutputDebugDescription   0 //真则打印对象，假则打印指针

@interface NSObject (BJDebugDescription)

- (NSString *)bj_debugDescription;

@end


NS_ASSUME_NONNULL_END
