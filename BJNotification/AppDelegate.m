//
//  AppDelegate.m
//  BJNotification
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import "AppDelegate.h"
#import "BJNotificationCenter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[BJNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveMessage:) name:@"demo" object:@"beijiahiddink"];
    
    [[BJNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveMessage) name:@"demo2" object:@"默认"];
    [[BJNotificationCenter defaultCenter]postNotificationName:@"demo" object:@"第一次"];
    
    
    return YES;
}

- (void)receiveMessage:(BJNotification *)notification {
    NSLog(@"receive message object : %@ notificationName : %@",notification.object, notification.name);
}

- (void)receiveMessage {
    NSLog(@"receive message object2");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
