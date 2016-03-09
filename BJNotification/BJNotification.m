//
//  BJNotification.m
//  demo
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import "BJNotification.h"

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

// { "notificationName" : { "notificationObserver" : [observer set] , "notificationObject" :  BJNotification class } }
- (void)addObserver:(id)observer
           selector:(SEL)aSelector
               name:(NSString *)aName
             object:(id)anObject {
    NSAssert(aSelector, @"the selector can not be nil");
    NSAssert(aName, @"the name can not be nil");
    BJNotification *bjNotification = [BJNotification notificationWithName:aName object:anObject];
    [bjNotification setNotificationSelector:aSelector];
    NSMutableDictionary *notificationNameDic = [self.notificationDictionary objectForKey:aName];
    NSHashTable *observerSet = [NSHashTable weakObjectsHashTable];
    if (!notificationNameDic) {
        [observerSet addObject:observer];
        notificationNameDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:observerSet,@"notificationObserver",bjNotification,@"notificationObject", nil];
        [self.notificationDictionary setObject:notificationNameDic forKey:aName];
    } else {
        NSHashTable *observerSet = [notificationNameDic objectForKey:@"notificationObserver"];
        if (!observerSet) {
            observerSet = [NSHashTable weakObjectsHashTable];
        }
        [observerSet addObject:observer];
        [notificationNameDic setObject:observerSet forKey:@"notificationObserver"];
    }
     [notificationNameDic setObject:bjNotification forKey:@"notificationObject"];
}

- (void)postNotification:(BJNotification *)notification {
    NSAssert(notification, @"the notification can not be nil");
    BJNotification *oldNotification = [self findNotificationObject:notification.name];
    if (notification.name == oldNotification.name) {
        if (notification.object) {
            oldNotification.object = notification.object;
        }
        if (notification.userInfo) {
            oldNotification.userInfo = notification.userInfo;
        }
    }
    NSHashTable *observerSet = [self findNotificationObserverSet:notification.name];
    [observerSet.setRepresentation enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        SEL selector = [oldNotification notificationSelector];
        if ([obj respondsToSelector:selector]) {
            [obj performSelectorOnMainThread:selector withObject:oldNotification waitUntilDone:NO];
        }
    }];
}

- (void)postNotificationName:(NSString *)aName
                      object:(id)anObject {
    NSAssert(aName, @"the name can not be nil");
    BJNotification *bjNotification = [BJNotification notificationWithName:aName object:anObject];
    [self postNotification:bjNotification];
}

- (void)removeObserver:(id)observer {
    NSAssert(observer, @"the observer can not be nil");
    if (!self.notificationDictionary.count) {
        return;
    }
    [[self.notificationDictionary allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeObserver:observer name:[self.notificationDictionary objectForKey:obj] object:nil];
    }];
}

- (void)removeObserver:(id)observer
                  name:(NSString *)aName
                object:(id)anObject {
    NSAssert(observer, @"the observer can not be nil");
    NSAssert(aName, @"the name can not be nil");
    NSHashTable *notificationObserverSet = [self findNotificationObserverSet:aName];
    if (!notificationObserverSet) {
        return;
    }
    [notificationObserverSet.setRepresentation enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if (obj == observer) {
            [notificationObserverSet removeObject:observer];
            if (!notificationObserverSet.count) {
                [self.notificationDictionary removeObjectForKey:aName];
            }
            *stop = YES;
        }
    }];
}

#pragma mark - Private Method

- (NSMutableDictionary *)notificationDictionary {
    if (!_notificationDictionary) {
        _notificationDictionary = [NSMutableDictionary dictionary];
    }
    return _notificationDictionary;
}

- (NSMutableDictionary *)findNotificationNameDictionary:(NSString *)notificationName {
    return [self.notificationDictionary objectForKey:notificationName];
}

- (NSHashTable *)findNotificationObserverSet:(NSString *)notificationName {
    return [[self findNotificationNameDictionary:notificationName] objectForKey:@"notificationObserver"];
}

- (BJNotification *)findNotificationObject:(NSString *)notificationName {
    return [[self findNotificationNameDictionary:notificationName] objectForKey:@"notificationObject"];
}

@end
