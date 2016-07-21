//
//  BJNotification.m
//  BJNotification <https://github.com/beijiahiddink/BJNotification>
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
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

#define BJLog(format, ...) \
NSLog((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__)

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


NS_ASSUME_NONNULL_BEGIN

#pragma mark - BJNotificationClass

@implementation BJNotification

+ (instancetype)notificationWithName:(NSString *)aName
                              object:(nullable id)anObject {
    return [[self alloc] initWithName:aName object:anObject userInfo:nil];
}

+ (instancetype)notificationWithName:(NSString *)aName
                              object:(nullable id)anObject
                            userInfo:(nullable NSDictionary *)aUserInfo {
    return [[self alloc] initWithName:aName object:anObject userInfo:aUserInfo];
}

- (instancetype)initWithName:(NSString *)name
                      object:(nullable id)object
                    userInfo:(nullable NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        _name = [name copy];
        _object = object;
        _userInfo = [userInfo copy];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[BJNotification allocWithZone:zone] initWithName:_name object:_object userInfo:_userInfo];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _object = [aDecoder decodeObjectForKey:@"object"];
        _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_object forKey:@"object"];
    [aCoder encodeObject:_userInfo forKey:@"userInfo"];
}

@end

#pragma mark - BJNotificationElementClass

@interface _BJNotificationElement : NSObject {
    @package
    __unsafe_unretained id _observer;
    NSValue *_selector;
    NSString *_name;
    id _object;
    NSString *_observerIdentifier;
}

+ (instancetype)elementWithObserver:(id)observer
                           selector:(SEL)selector
                               name:(nullable NSString *)name
                             object:(nullable id)object;

+ (instancetype)elementWithObserverIdentifier:(NSString *)identifier
                                         name:(nullable NSString *)name
                                       object:(nullable id)object;

- (instancetype)initWithObserver:(id)observer
                        selector:(SEL)selector
                            name:(nullable NSString *)name
                          object:(nullable id)object;

- (instancetype)initWithObserverIdentifier:(NSString *)identifier
                                      name:(nullable NSString *)name
                                    object:(nullable id)object;

- (BOOL)canRemoveFromContainer:(id)object;

@end

@implementation _BJNotificationElement

+ (instancetype)elementWithObserver:(id)observer
                           selector:(SEL)selector
                               name:(nullable NSString *)name
                             object:(nullable id)object {
    return [[self alloc] initWithObserver:observer selector:selector name:name object:object];
}

+ (instancetype)elementWithObserverIdentifier:(NSString *)identifier
                                         name:(nullable NSString *)name
                                       object:(nullable id)object {
    return [[self alloc] initWithObserverIdentifier:identifier name:name object:object];
}

- (instancetype)initWithObserver:(id)observer
                        selector:(SEL)selector
                            name:(nullable NSString *)name
                          object:(nullable id)object {
    self = [super init];
    if (self) {
        _observer = observer;
        _selector = [NSValue value:&selector withObjCType:@encode(SEL)];
        _name = name;
        _object = object;
        _observerIdentifier = [NSString stringWithFormat:@"%p", observer];
    }
    return self;
}

- (instancetype)initWithObserverIdentifier:(NSString *)identifier
                                      name:(nullable NSString *)name
                                    object:(nullable id)object {
    self = [super init];
    if (self) {
        _observerIdentifier = identifier;
        _name = name;
        _object = object;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[_BJNotificationElement class]]) {
        _BJNotificationElement *temp = object;
        if (temp->_observer == _observer && temp->_object == _object && [temp->_name isEqualToString:_name]) return YES;
        else return NO;
    }
    return [super isEqual:object];
}

- (BOOL)canRemoveFromContainer:(id)object {
    if (!_observer || ![object isMemberOfClass:[_BJNotificationElement class]]) return YES;
    _BJNotificationElement *temp = object;
    
    if ([_observerIdentifier isEqualToString:temp->_observerIdentifier]) {
        if ((temp->_name && !temp->_object) && ([_name isEqualToString:temp->_name])) return YES;
        else if ((!temp->_name && temp->_object) && (_object == temp->_object)) return YES;
        else if ((temp->_name && temp->_object) && ([_name isEqualToString:temp->_name]) && (_object == temp->_object)) return YES;
        else if (!temp->_name && !temp->_object) return YES;
    }
    return NO;
}

- (NSString *)debugDescription {
    return [self bj_debugDescription];
}

@end

#pragma mark - BJNotificationCenterClass

@interface BJNotificationCenter () {
    NSMutableArray *_notificationObserverArray;
}

@end

@implementation BJNotificationCenter

+ (instancetype)defaultCenter {
    static id center = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        center = [self new];
    });
    return center;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _notificationObserverArray = [NSMutableArray new];
    }
    return self;
}

- (void)addObserver:(id)observer
           selector:(SEL)aSelector
               name:(NSString *)aName
             object:(nullable id)anObject {
    dispatch_main_async_safe(^{
        [self _addObserver:observer selector:aSelector name:aName object:anObject];
    });
}

- (void)_addObserver:(id)observer
            selector:(SEL)aSelector
                name:(NSString *)aName
              object:(nullable id)anObject {
    _BJNotificationElement *element = [_BJNotificationElement elementWithObserver:observer selector:aSelector name:aName object:anObject];
    [_notificationObserverArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([element isEqual:obj]) {
            [_notificationObserverArray removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    [_notificationObserverArray addObject:element];
    [self _testWithObject:element methodName:NSStringFromSelector(_cmd)];
}

- (void)postNotificationName:(NSString *)aName
                      object:(nullable id)anObject {
    BJNotification *notification = [BJNotification notificationWithName:aName object:anObject];
    [self postNotification:notification];
}

- (void)postNotification:(BJNotification *)notification {
    dispatch_main_async_safe(^{
        [self _postNotification:notification];
    });
}

- (void)_postNotification:(BJNotification *)notification {
    [_notificationObserverArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _BJNotificationElement *element = obj;
        if ([notification.name isEqualToString:element->_name]) {
            SEL selector;
            NSValue *selValue = element->_selector;
            [selValue getValue:&selector];
            if (element->_object) {
                if (notification.object == element->_object) {
                    SuppressPerformSelectorLeakWarning([element->_observer performSelector:selector withObject:notification];);
                }
            } else {
                SuppressPerformSelectorLeakWarning([element->_observer performSelector:selector withObject:notification];);
            }
        }
    }];
}

- (void)removeObserver:(id)observer {
    [self removeObserver:observer name:nil object:nil];
}

- (void)removeObserver:(id)observer
                  name:(nullable NSString *)aName
                object:(nullable id)anObject {
    dispatch_main_async_safe(^{
        [self _removeObserver:observer name:aName object:anObject];
    });
}

- (void)_removeObserver:(id)observer
                   name:(nullable NSString *)aName
                 object:(nullable id)anObject {
    if (!_notificationObserverArray.count) return;
    NSString *identifier = [NSString stringWithFormat:@"%p", observer];
    _BJNotificationElement *removeElement = [_BJNotificationElement elementWithObserverIdentifier:identifier name:aName object:anObject];
    [_notificationObserverArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _BJNotificationElement *element = obj;
        if ([element canRemoveFromContainer:removeElement]) {
            [_notificationObserverArray removeObjectAtIndex:idx];
            [self _testWithObject:element methodName:NSStringFromSelector(_cmd)];
        }
    }];
}

- (void)_testWithObject:(id)object methodName:(NSString *)name {
#ifdef DEBUG
    if ([self respondsToSelector:NSSelectorFromString(@"bj_testBlock")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id block = [self performSelector:NSSelectorFromString(@"bj_testBlock")];
#pragma clang diagnostic pop
        if (block) {
            void(^BJTestBlock)() = block;
            BJTestBlock(object, name);
        }
    }
#endif
}

@end

#pragma mark - NSObject Category

@implementation NSObject (BJDebugDescription)

- (NSString *)bj_debugDescription {
    NSMutableString *description = [NSMutableString new];
    [description appendFormat:@"*****%s*****\n<%@: %p>\n", __FUNCTION__, [self class], self];
    
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t propertyClass = propertyList[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(propertyClass)];
        ;
        if (i == 0) [description appendFormat:@"{\n"];
#if OutputDebugDescription
        [description appendFormat:@"\t%@: %@", propertyName, [self valueForKey:propertyName]];
#else
        [description appendFormat:@"\t%@: %p", propertyName, [self valueForKey:propertyName]];
#endif
        if (i == count - 1) [description appendFormat:@"\n}"];
        else [description appendFormat:@",\n"];
    }
    return [description copy];
}

@end

NS_ASSUME_NONNULL_END
