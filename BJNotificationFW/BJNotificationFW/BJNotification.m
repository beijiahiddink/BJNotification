//
//  BJNotification.m
//  BJNotification
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import "BJNotification.h"
#import <objc/runtime.h>

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


@interface BJNotificationMessageInfo : NSObject

@property (nonatomic, weak) id weakObserver;
@property (nonatomic, strong) id strongObserver;
@property (nonatomic) SEL selector;
@property (nonatomic, copy) NSString *name;
@property (nullable, nonatomic) id object;
@property (nonatomic, copy) NSString *observerAddress;

@end

@implementation BJNotificationMessageInfo

- (void)dealloc {
    NSLog(@"%@",self.debugDescription);
}

- (NSString *)debugDescription {
    return [self bj_debugDescription];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return @"unknown";
}

@end


@interface BJNotificationCenter ()

@property (nonatomic, strong) NSMutableArray *notificationObserverArray;
@property (nonatomic, strong) NSOperationQueue *notificationQueue;

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
    BJNotificationMessageInfo *messageInfo = [[BJNotificationMessageInfo alloc] init];
    messageInfo.strongObserver = observer;
    messageInfo.selector = aSelector;
    messageInfo.name = aName;
    messageInfo.object = anObject;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(addObserverWithOperationMessage:) object:messageInfo];
    [self.notificationQueue addOperation:operation];
}

- (void)addObserverWithOperationMessage:(BJNotificationMessageInfo *)message {
    [self.notificationObserverArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BJNotificationMessageInfo *listenInfo = obj;
        if (listenInfo.weakObserver == message.strongObserver && listenInfo.object == message.object && [listenInfo.name isEqualToString:message.name]) {
            [self.notificationObserverArray removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    message.weakObserver = message.strongObserver;
    message.strongObserver = nil;
    message.observerAddress = [NSString stringWithFormat:@"%p",message.weakObserver];
    [self.notificationObserverArray addObject:message];
    NSLog(@"\nadd thead:--%@",[NSThread currentThread]);
}

- (void)postNotification:(BJNotification *)notification {
    NSAssert(notification, @"the notification can not be nil");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.notificationObserverArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BJNotificationMessageInfo *listenInfo = obj;
            if ([notification.name isEqualToString:listenInfo.name]) {
                if (listenInfo.object) {
                    if (notification.object == listenInfo.object) {
                        if ([listenInfo.weakObserver respondsToSelector:listenInfo.selector]) {
                            [listenInfo.weakObserver performSelectorOnMainThread:listenInfo.selector withObject:notification waitUntilDone:NO];
                        }
                    }
                } else {
                    if ([listenInfo.weakObserver respondsToSelector:listenInfo.selector]) {
                        [listenInfo.weakObserver performSelectorOnMainThread:listenInfo.selector withObject:notification waitUntilDone:NO];
                    }
                }
            }
        }];
    });
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
    BJNotificationMessageInfo *messageInfo = [[BJNotificationMessageInfo alloc] init];
    messageInfo.name = aName;
    messageInfo.object = anObject;
    messageInfo.observerAddress = [NSString stringWithFormat:@"%p",observer];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(removeObserverWithOperationMessage:) object:messageInfo];
    [self.notificationQueue addOperation:operation];
}

- (void)removeObserverWithOperationMessage:(BJNotificationMessageInfo *)message {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [self.notificationObserverArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BJNotificationMessageInfo *listenInfo = obj;
        if (listenInfo.weakObserver) {
            if ([listenInfo.observerAddress isEqualToString:message.observerAddress]) {
                if ((message.name && !message.object) && ([listenInfo.name isEqualToString:message.name])) {
                    [indexSet addIndex:idx];
                } else if ((!message.name && message.object) && (listenInfo.object == message.object)) {
                    [indexSet addIndex:idx];
                } else if ((message.name && message.object) && ([listenInfo.name isEqualToString:message.name]) && (listenInfo.object == message.object)) {
                    [indexSet addIndex:idx];
                }
            }
        } else {
            [indexSet addIndex:idx];
        }
    }];
    NSLog(@"\nremove thead:--%@",[NSThread currentThread]);
    if (!indexSet.count) {
        return;
    }
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self.notificationObserverArray removeObjectAtIndex:idx];
    }];
}

#pragma mark - Private Method

- (NSMutableArray *)notificationObserverArray {
    if (!_notificationObserverArray) {
        _notificationObserverArray = [NSMutableArray array];
    }
    return _notificationObserverArray;
}

- (NSOperationQueue *)notificationQueue {
    if (!_notificationQueue) {
        _notificationQueue = [NSOperationQueue mainQueue];
    }
    return _notificationQueue;
}


@end

@implementation NSObject (BJDebugDescription)

- (NSString *)bj_debugDescription {
    NSMutableString *description = [[NSMutableString alloc] init];
    [description appendFormat:@"*****%@*****\n<%@ : %p>\n",NSStringFromSelector(_cmd),[self class],self];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t propertyClass = propertyList[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(propertyClass)];
        ;
        if (i == 0) {
            [description appendFormat:@"{\n"];
        }
        [description appendFormat:@"\t%@ : %p\n",propertyName,[self valueForKey:propertyName]];
        if (i == count - 1) {
            [description appendFormat:@"}"];
        }
    }
    return [description copy];
}

@end
