//
//  BJNotification.m
//  BJNotification
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import "BJNotification.h"
#import <objc/runtime.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#pragma mark - BJNotificationClass

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

#pragma mark - BJNotificationMessageClass

@interface BJNotificationMessage : NSObject

@property (nonatomic, weak) id observer;
@property (nonatomic) SEL selector;
@property (nonatomic, copy) NSString *name;
@property (nullable, nonatomic) id object;
@property (nonatomic, copy) NSString *observerAddress;

@end

@implementation BJNotificationMessage

//- (void)dealloc {
//    NSLog(@"%@",self.debugDescription);
//}

- (NSString *)debugDescription {
    return [self bj_debugDescription];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return @"unknown";
}

@end

#pragma mark - BJNotificationCenterClass

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
    NSBlockOperation *anOperation = [[NSBlockOperation alloc] init];
    __weak __typeof(anOperation) weakOperation = anOperation;
    [anOperation addExecutionBlock:^{
        [self addObserver:observer selector:aSelector name:aName object:anObject withOperation:weakOperation];
    }];
    [anOperation start];
}

- (void)postNotification:(BJNotification *)notification {
    NSAssert(notification, @"the notification can not be nil");
        [self.notificationObserverArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BJNotificationMessage *listenInfo = obj;
            if ([notification.name isEqualToString:listenInfo.name]) {
                if (listenInfo.object) {
                    if (notification.object == listenInfo.object) {
                        if ([listenInfo.observer respondsToSelector:listenInfo.selector]) {
                            SuppressPerformSelectorLeakWarning([listenInfo.observer performSelector:listenInfo.selector withObject:notification]);
                        }
                    }
                } else {
                    if ([listenInfo.observer respondsToSelector:listenInfo.selector]) {
                        SuppressPerformSelectorLeakWarning([listenInfo.observer performSelector:listenInfo.selector withObject:notification]);
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
    NSBlockOperation *anOperation = [[NSBlockOperation alloc] init];
    __weak __typeof(anOperation) weakOperation = anOperation;
    [anOperation addExecutionBlock:^{
        [self removeObserver:observer name:aName object:anObject withOperation:weakOperation];
    }];
    [anOperation start];
}

#pragma mark - Private Method

- (NSMutableArray *)notificationObserverArray {
    if (!_notificationObserverArray) {
        _notificationObserverArray = [NSMutableArray array];
    }
    return _notificationObserverArray;
}

- (void)addObserver:(id)observer
           selector:(SEL)aSelector
               name:(NSString *)aName
             object:(nullable id)anObject
      withOperation:(NSOperation *)operation {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.weakObserver = %@ And self.object = %@ And self.name == '%@'",observer, anObject, aName];
    [self.notificationObserverArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BJNotificationMessage *listenInfo = obj;
        BOOL isSame = [predicate evaluateWithObject:listenInfo];
        if (isSame) {
            [self.notificationObserverArray removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    BJNotificationMessage *message = [[BJNotificationMessage alloc] init];
    message.observer = observer;
    message.name = aName;
    message.selector = aSelector;
    message.object = anObject;
    message.observerAddress = [NSString stringWithFormat:@"%p",message.observer];
    [self.notificationObserverArray addObject:message];
    NSLog(@"\nadd thead:--%@",[NSThread currentThread]);
}

- (void)removeObserver:(id)observer
                  name:(nullable NSString *)aName
                object:(nullable id)anObject
         withOperation:(NSOperation *)operation {
    [self.notificationObserverArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BJNotificationMessage *message = obj;
        if (message.observer) {
            if ([message.observerAddress isEqualToString:[NSString stringWithFormat:@"%p",observer]]) {
                if ((aName && !anObject) && ([message.name isEqualToString:aName])) {
                    [self.notificationObserverArray removeObjectAtIndex:idx];
                } else if ((!aName && anObject) && (message.object == anObject)) {
                    [self.notificationObserverArray removeObjectAtIndex:idx];
                } else if ((aName && anObject) && ([message.name isEqualToString:aName]) && (message.object == anObject)) {
                    [self.notificationObserverArray removeObjectAtIndex:idx];
                } else if (!aName && !anObject) {
                    [self.notificationObserverArray removeObjectAtIndex:idx];
                }
            }
        } else {
            [self.notificationObserverArray removeObjectAtIndex:idx];
        }
    }];
    NSLog(@"\nremove thead:--%@",[NSThread currentThread]);
}

@end

#pragma mark - NSObject Category

@implementation NSObject (BJDebugDescription)

#pragma mark - Public Method

- (NSString *)bj_debugDescription {
    NSMutableString *description = [[NSMutableString alloc] init];
    [description appendFormat:@"*****%s*****\n<%@: %p>\n",__func__,[self class],self];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t propertyClass = propertyList[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(propertyClass)];
        ;
        if (i == 0) {
            [description appendFormat:@"{\n"];
        }
        [description appendFormat:@"\t%@: %p",propertyName,[self valueForKey:propertyName]];
        if (i == count - 1) {
            [description appendFormat:@"\n}"];
        } else {
            [description appendFormat:@",\n"];
        }
    }
    return [description copy];
}

@end
