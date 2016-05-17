//
//  BJNotificationFWTests.m
//  BJNotificationFWTests
//
//  Created by 王旭 on 15/11/21.
//  Copyright © 2015年 beijiahiddink. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "BJNotification.h"

static NSString *const NotificationTestKey = @"NotificationTest";
static NSArray *observerArray;

typedef void(^BJTestBlock)(id object, NSString *methodName);

@interface BJNotificationCenter (BJFMTest)

@property (nonatomic, copy) BJTestBlock testBlock;

@end

@implementation BJNotificationCenter (BJFMTest)

static char testBlockKey;

- (void)setTestBlock:(BJTestBlock)testBlock {
    objc_setAssociatedObject(self, &testBlockKey, testBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BJTestBlock)testBlock {
    return objc_getAssociatedObject(self, &testBlockKey);
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
    [[BJNotificationCenter defaultCenter] setTestBlock:^(id object, NSString *methodName) {
        NSLog(@"--BJTestBlock--\n%@\n%@",object, methodName);
        NSObject *nobject = object;
        if ([nobject isMemberOfClass:NSClassFromString(@"BJNotificationMessageInfo")]){
            NSLog(@"%@\n    self: %p",nobject.debugDescription, self);
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
    self.expectation = [self expectationWithDescription:@"testPostNotification"];
    [[BJNotificationCenter defaultCenter] postNotificationName:NotificationTestKey object:@"demo"];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)notificationTest:(BJNotification *)notification {
    NSString *str = notification.object;
    XCTAssertTrue([str isEqualToString:@"demo"], @"发送通知出现错误");
    [self.expectation fulfill];
}


@end

