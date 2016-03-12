//
//  BJNotification.m
//  demo
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import "BJNotification.h"


@implementation BJNotification

#pragma mark - Public Method

+ (instancetype)notificationWithName:(NSString *)aName
                              object:(nullable id)anObject {
    NSAssert(aName, @"the name can not be nil");
    return [[self alloc] initWithName:aName object:anObject userInfo:nil];
}

+ (instancetype)notificationWithName:(NSString *)aName
                              object:(nullable id)anObject
                            userInfo:(nullable NSDictionary *)aUserInfo {
    NSAssert(aName, @"the name can not be nil");
    return [[self alloc] initWithName:aName object:anObject userInfo:aUserInfo];
}

- (instancetype)initWithName:(NSString *)name
                      object:(nullable id)object
                    userInfo:(nullable NSDictionary *)userInfo {
    NSAssert(name, @"the name can not be nil");
    self = [super init];
    if (self) {
        _name = [name copy];
        _object = object;
        _userInfo = [userInfo copy];
    }
    return self;
}

@end


@interface BJNotificationListenInfo : NSObject

@property (nonatomic, weak) id listenObserver;
@property (nonatomic) SEL listenSelector;
@property (nonatomic, copy) NSString *listenName;
@property (nullable, nonatomic) id listenObject;

@end

@implementation BJNotificationListenInfo

@end


@interface BJNotificationCenter ()

@property (nonatomic, strong) NSMutableArray *notificationObserverArray;

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

- (void)addObserver:(id)observer
           selector:(SEL)aSelector
               name:(NSString *)aName
             object:(nullable id)anObject {
    NSAssert(observer, @"the observer can not be nil");
    NSAssert(aSelector, @"the selector can not be nil");
    NSAssert(aName, @"the name can not be nil");
    [self.notificationObserverArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BJNotificationListenInfo *listenInfo = obj;
        if (listenInfo.listenObserver == observer && listenInfo.listenObject == anObject && [listenInfo.listenName isEqualToString:aName]) {
            [self.notificationObserverArray removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    BJNotificationListenInfo *listenInfo = [[BJNotificationListenInfo alloc] init];
    listenInfo.listenObserver = observer;
    listenInfo.listenSelector = aSelector;
    listenInfo.listenName = aName;
    listenInfo.listenObject = anObject;
    [self.notificationObserverArray addObject:listenInfo];
}

- (void)postNotification:(BJNotification *)notification {
    NSAssert(notification, @"the notification can not be nil");
    [self.notificationObserverArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BJNotificationListenInfo *listenInfo = obj;
        if ([notification.name isEqualToString:listenInfo.listenName]) {
            if (listenInfo.listenObject) {
                if (notification.object == listenInfo.listenObject) {
                    if ([listenInfo.listenObserver respondsToSelector:listenInfo.listenSelector]) {
                        [listenInfo.listenObserver performSelectorOnMainThread:listenInfo.listenSelector withObject:notification waitUntilDone:NO];
                    }
                }
            } else {
                if ([listenInfo.listenObserver respondsToSelector:listenInfo.listenSelector]) {
                    [listenInfo.listenObserver performSelectorOnMainThread:listenInfo.listenSelector withObject:notification waitUntilDone:NO];
                }
            }
        }
    }];
}

- (void)postNotificationName:(NSString *)aName
                      object:(nullable id)anObject {
    NSAssert(aName, @"the name can not be nil");
    BJNotification *bjNotification = [BJNotification notificationWithName:aName object:anObject];
    [self postNotification:bjNotification];
}

- (void)removeObserver:(id)observer {
    [self removeObserver:observer name:nil object:nil];
}

- (void)removeObserver:(id)observer
                  name:(nullable NSString *)aName
                object:(nullable id)anObject {
    NSAssert(observer, @"the observer can not be nil");
    if (!self.notificationObserverArray.count) {
        return;
    }
    [self.notificationObserverArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BJNotificationListenInfo *listenInfo = obj;
        if (listenInfo.listenObserver == observer) {
            if (aName && !anObject) {
                if ([listenInfo.listenName isEqualToString:aName]) {
                    [self.notificationObserverArray removeObjectAtIndex:idx];
                }
            } else if (!aName && anObject) {
                if (listenInfo.listenObject == anObject) {
                    [self.notificationObserverArray removeObjectAtIndex:idx];
                }
            } else if (aName && anObject) {
                if ([listenInfo.listenName isEqualToString:aName] && listenInfo.listenObject == anObject) {
                    [self.notificationObserverArray removeObjectAtIndex:idx];
                }
            } else {
                [self.notificationObserverArray removeObjectAtIndex:idx];
            }
        } else if (!listenInfo.listenObserver) {
            [self.notificationObserverArray removeObjectAtIndex:idx];
        }
    }];
}

#pragma mark - Private Method

- (NSMutableArray *)notificationObserverArray {
    if (!_notificationObserverArray) {
        _notificationObserverArray = [NSMutableArray array];
    }
    return _notificationObserverArray;
}

@end
