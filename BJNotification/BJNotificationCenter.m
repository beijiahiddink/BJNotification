//
//  BJNotificationCenter.m
//  demo
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import "BJNotificationCenter.h"
#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - BJNotification

@implementation BJNotification

+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject {
    return [[self alloc] initWithName:aName object:anObject userInfo:nil];
}

+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    return [[self alloc] initWithName:aName object:anObject userInfo:aUserInfo];
}

- (instancetype)initWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        self.name = name ;
        self.object = object;
        self.userInfo = userInfo;
    }
    return self;
}

@end

#pragma mark - BJNotificationCenter

@interface BJNotificationCenter ()

@property (nonatomic, strong) NSMutableDictionary *notificationDictionary;

@end

static char observerBindKey;
static char observerSelectorKey;

@implementation BJNotificationCenter

+ (BJNotificationCenter *)defaultCenter {
    static BJNotificationCenter *center = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        center = [[BJNotificationCenter alloc] init];
    });
    return center;
}

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject {
    NSAssert(observer, @"the observer can not be nil with %@", NSStringFromClass([self class]));
    NSAssert(aSelector, @"the selector can not be nil with %@", NSStringFromClass([self class]));
    NSAssert(aName, @"the name can not be nil with %@", NSStringFromClass([self class]));
    NSMutableSet *set = [self backSetWithNotificationName:aName];
    BJNotification *bjNotification = [BJNotification notificationWithName:aName object:anObject];
    NSString *selectorStr = NSStringFromSelector(aSelector);
    objc_setAssociatedObject(observer, &observerBindKey, bjNotification, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, &observerSelectorKey, selectorStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [set addObject:observer];
}

- (void)postNotification:(BJNotification *)notification {
    NSAssert(notification, @"post notification can not be nil with %@", NSStringFromClass([self class]));
    NSMutableSet *set = [self backSetWithNotificationName:notification.name];
    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        BJNotification *oldNotification = objc_getAssociatedObject(obj, &observerBindKey);
        if (notification.object) {
            oldNotification.object = notification.object;
        }
        if (notification.userInfo) {
            oldNotification.userInfo = notification.userInfo;
        }
        NSString *selectorStr = objc_getAssociatedObject(obj, &observerSelectorKey);
        SEL selector = NSSelectorFromString(selectorStr);
        if ([obj respondsToSelector:selector]) {
            objc_msgSend(obj, selector, oldNotification);
        }
    }];
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject {
    NSAssert(aName, @"the name can not be nil with %@", NSStringFromClass([self class]));
    BJNotification *bjNotification = [BJNotification notificationWithName:aName object:anObject];
    [self postNotification:bjNotification];
}

- (void)removeObserver:(id)observer {
    NSAssert(observer, @"the observer can not be nil with %@", NSStringFromClass([self class]));
    BJNotification *bjNotification = objc_getAssociatedObject(observer, &observerBindKey);
    [self removeObserver:observer name:bjNotification.name object:nil];
}

- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject {
    NSAssert(observer, @"the observer can not be nil with %@", NSStringFromClass([self class]));
    NSAssert(aName, @"the name can not be nil with %@", NSStringFromClass([self class]));
    objc_removeAssociatedObjects(observer);
    NSMutableSet *set = [self backSetWithNotificationName:aName];
    [set removeObject:observer];
}

#pragma mark - Private Method

- (NSMutableDictionary *)notificationDictionary {
    if (!_notificationDictionary) {
        self.notificationDictionary = [NSMutableDictionary dictionary];
    }
    return _notificationDictionary;
}

- (NSMutableSet *)findBackSetWithNotificationName:(NSString *)notificationName {
    return [self.notificationDictionary valueForKey:notificationName];
}

- (NSMutableSet *)backSetWithNotificationName:(NSString *)notificationName {
    if (![self findBackSetWithNotificationName:notificationName]) {
        NSMutableSet *set = [NSMutableSet set];
        [self.notificationDictionary setValue:set forKey:notificationName];
        return set;
    }
    return [self findBackSetWithNotificationName:notificationName];
}


@end
