//
//  ViewController.m
//  BJNotification
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import "ViewController.h"
#import "BJNotification.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)dealloc {
    [[BJNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:@"demo" object:@"beijiahiddink"];
    
    [[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessageSecond:) name:@"demo2" object:@"默认"];
//    [[BJNotificationCenter defaultCenter] postNotificationName:@"demo" object:@"第一次"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClick:(UIButton *)sender {
    sender.tag = !sender.tag;
    if (sender.tag) {
        [[BJNotificationCenter defaultCenter] postNotificationName:@"demo" object:@"第二次"];
    } else {
        [[BJNotificationCenter defaultCenter] postNotificationName:@"demo2" object:nil];
    }
}

- (void)receiveMessage:(BJNotification *)notification {

}

- (void)receiveMessageSecond:(BJNotification *)notification {

}

@end
