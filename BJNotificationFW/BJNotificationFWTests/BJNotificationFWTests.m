//
//  BJNotificationFWTests.m
//  BJNotificationFWTests <https://github.com/beijiahiddink/BJNotification>
//
//  Created by WangXu on 15/11/21.
//  Copyright © 2015年 beijiahiddink. All rights reserved.
//
//  For the full copyright and license information, please view the README
//  file that was distributed with this source code.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "BJNotification.h"

static NSString *const NotificationTestKey = @"NotificationTest";
static NSArray *observerArray;

typedef void(^BJTestBlock)(id object, NSString *methodName);

@interface BJNotificationCenter (BJFMTest)

- (void)bj_setTestBlock:(BJTestBlock)bj_testBlock;
- (BJTestBlock)bj_testBlock;

@end

@implementation BJNotificationCenter (BJFMTest)

static char ktestBlockKey;

- (void)bj_setTestBlock:(BJTestBlock)bj_testBlock {
    objc_setAssociatedObject(self, &ktestBlockKey, bj_testBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BJTestBlock)bj_testBlock {
    return objc_getAssociatedObject(self, &ktestBlockKey);
}

@end

@interface BJNotificationFWTests : XCTestCase

@property (nonatomic, strong) XCTestExpectation *expectation;

@end

@implementation BJNotificationFWTests

+ (void)initialize {
    if (self == [BJNotificationFWTests class]) {
        observerArray = [[BJNotificationCenter defaultCenter] valueForKey:@"notificationObserverArray"];
    }
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
//#warning TODO:
    [[BJNotificationCenter defaultCenter] bj_setTestBlock:^(id object, NSString *methodName) {
        NSLog(@"--BJTestBlock--\n%@\n%@",object, methodName);
        NSObject *nobject = object;
        if ([nobject isMemberOfClass:NSClassFromString(@"BJNotificationElement")]){
            NSLog(@"%@",nobject.debugDescription);
        }
    }];
    [[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationTest:) name:NotificationTestKey object:nil];
    NSLog(@"-----------分割线-------------");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.expectation = nil;
    [[BJNotificationCenter defaultCenter] removeObserver:self name:NotificationTestKey object:nil];
}

- (void)testAddObserver {
    XCTAssertTrue(observerArray.count == 1, @"通知添加注册者出现错误");
}

- (void)testRemoveObserver {
    NSInteger startCount = observerArray.count;
    [[BJNotificationCenter defaultCenter] removeObserver:self name:NotificationTestKey object:nil];
    NSInteger endCount = observerArray.count;
    XCTAssertTrue(startCount - endCount == 1, @"通知删除注册者出现错误");
}


- (void)testPostNotification {
    [[BJNotificationCenter defaultCenter] postNotificationName:NotificationTestKey object:@"demo"];
}

- (void)notificationTest:(BJNotification *)notification {
    NSString *str = notification.object;
    XCTAssertTrue([str isEqualToString:@"demo"], @"发送通知出现错误");
}


@end

