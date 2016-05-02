//
//  BJNotificationFWTests.m
//  BJNotificationFWTests
//
//  Created by 王旭 on 15/11/21.
//  Copyright © 2015年 beijiahiddink. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BJNotification.h"

static NSString *const NotificationTestKey = @"NotificationTest";
static NSArray *observerArray;

@interface BJNotificationFWTests : XCTestCase

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
    [[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationTest:) name:NotificationTestKey object:nil];
    NSObject *object = [observerArray lastObject];
    if ([object isMemberOfClass:NSClassFromString(@"BJNotificationMessageInfo")]){
        NSLog(@"%@\n    self: %p",object.debugDescription,self);
    }
    NSLog(@"-----------分割线-------------");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[BJNotificationCenter defaultCenter] removeObserver:self name:NotificationTestKey object:nil];
}

- (void)testAddObserver {
    XCTAssertTrue(observerArray.count == 1,@"通知添加注册者出现错误");
}

- (void)testRemoveObserver {
    NSInteger startCount = observerArray.count;
    [[BJNotificationCenter defaultCenter] removeObserver:self name:NotificationTestKey object:nil];
    NSInteger endCount = observerArray.count;
    XCTAssertTrue(startCount - endCount == 1,@"通知删除注册者出现错误");
}

static NSString *str;

- (void)testPostNotification {
    [[BJNotificationCenter defaultCenter] postNotificationName:NotificationTestKey object:@"demo"];
    XCTAssertTrue([str isEqualToString:@"demo"],@"发送通知出现错误");
}

- (void)notificationTest:(BJNotification *)notification {
    str = notification.object;
}


@end
