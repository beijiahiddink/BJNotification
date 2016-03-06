//
//  BJNotification.m
//  demo
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import "BJNotification.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface BJNotification ()

@property (nonatomic) SEL notificationSelector;

@end


@implementation BJNotification

#pragma mark - Public Method

+ (instancetype)notificationWithName:(NSString *)aName
                              object:(id)anObject {
    return [[self alloc] initWithName:aName object:anObject userInfo:nil];
}

+ (instancetype)notificationWithName:(NSString *)aName
                              object:(id)anObject
                            userInfo:(NSDictionary *)aUserInfo {
    return [[self alloc] initWithName:aName object:anObject userInfo:aUserInfo];
}

- (instancetype)initWithName:(NSString *)name
                      object:(id)object
                    userInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        _name = [name copy];
        _object = object;
        _userInfo = [userInfo copy];
    }
    return self;
}

@end



@interface BJNotificationCenter ()

@property (nonatomic, strong) NSMutableDictionary *notificationDictionary;

@end

static char observerBindKey;

@implementation BJNotificationCenter

#pragma mark - Public Method

+ (BJNotificationCenter *)defaultCenter {
    static BJNotificationCenter *center = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        center = [[BJNotificationCenter alloc] init];
    });
    return center;
}

- (void)addObserver:(id)observer
           selector:(SEL)aSelector
               name:(NSString *)aName
             object:(id)anObject {
    NSAssert(observer, @"the observer can not be nil in the %@", NSStringFromClass([self class]));
    NSAssert(aSelector, @"the selector can not be nil in the %@", NSStringFromClass([self class]));
    NSAssert(aName, @"the name can not be nil in the %@", NSStringFromClass([self class]));
    NSMutableSet *nameSet = [self backSetWithNotificationName:aName];
    NSMutableSet *observerSet = [self backSetWithNotificationObserver:observer];
    BJNotification *bjNotification = [BJNotification notificationWithName:aName object:anObject];
    [bjNotification setNotificationSelector:aSelector];
    [observerSet addObject:bjNotification];
    [nameSet addObject:observer];
}

- (void)postNotification:(BJNotification *)notification {
    NSAssert(notification, @"the notification can not be nil in the %@", NSStringFromClass([self class]));
    NSMutableSet *nameSet = [self backSetWithNotificationName:notification.name];
    [nameSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        NSMutableSet *observerSet = [self backSetWithNotificationObserver:obj];
        [observerSet enumerateObjectsUsingBlock:^(id obj2, BOOL *stop) {
            BJNotification *oldNotification = (BJNotification *)obj2;
            if (notification.name == oldNotification.name) {
                if (notification.object) {
                    oldNotification.object = notification.object;
                }
                if (notification.userInfo) {
                    oldNotification.userInfo = notification.userInfo;
                }
                SEL selector = [oldNotification notificationSelector];
                if ([obj respondsToSelector:selector]) {
                    objc_msgSend(obj, selector, oldNotification);
                }
            }
        }];
    }];
}

- (void)postNotificationName:(NSString *)aName
                      object:(id)anObject {
    NSAssert(aName, @"the name can not be nil in the %@", NSStringFromClass([self class]));
    BJNotification *bjNotification = [BJNotification notificationWithName:aName object:anObject];
    [self postNotification:bjNotification];
}

- (void)removeObserver:(id)observer {
    NSAssert(observer, @"the observer can not be nil in the %@", NSStringFromClass([self class]));
    NSMutableSet *observerSet = [self findBackSetWithNotificationObserver:observer];
    [observerSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        BJNotification *notification = obj;
        [self removeObserver:observer name:notification.name object:nil isDeleteObserverSet:NO];
    }];
    [observerSet removeAllObjects];
    objc_removeAssociatedObjects(observer);
}

- (void)removeObserver:(id)observer
                  name:(NSString *)aName
                object:(id)anObject {
    [self removeObserver:observer name:aName object:anObject isDeleteObserverSet:YES];
}

- (void)removeObserver:(id)observer
                  name:(NSString *)aName
                object:(id)anObject
   isDeleteObserverSet:(BOOL)isDelete {
    NSAssert(observer, @"the observer can not be nil in the %@", NSStringFromClass([self class]));
    NSAssert(aName, @"the name can not be nil in the %@", NSStringFromClass([self class]));
    NSMutableSet *nameSet = [self backSetWithNotificationName:aName];
    [nameSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if (obj == observer) {
            [nameSet removeObject:observer];
            *stop = YES;
        }
    }];
    if (isDelete) {
        NSMutableSet *observerSet = [self findBackSetWithNotificationObserver:observer];
        if (!observerSet.count) {
            objc_removeAssociatedObjects(observer);
        }
    }
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

- (NSMutableSet *)backSetWithNotificationObserver:(id)observer {
    if (![self findBackSetWithNotificationObserver:observer]) {
        NSMutableSet *set = [NSMutableSet set];
        objc_setAssociatedObject(observer, &observerBindKey, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [self findBackSetWithNotificationObserver:observer];
}

- (NSMutableSet *)findBackSetWithNotificationObserver:(id)observer {
    return objc_getAssociatedObject(observer, &observerBindKey);
}


@end
