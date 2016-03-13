//
//  SecondPageViewController.m
//  BJNotification
//
//  Created by WangXu on 15/11/11.
//  Copyright © 2015年 beijiahiddink. All rights reserved.
//

#import "SecondPageViewController.h"
#import "BJNotification.h"

@interface SecondPageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation SecondPageViewController

- (void)dealloc {
    [[BJNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"SecondPageViewController dealloc");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"SecondPage";
    [[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTip:) name:@"TipNotification" object:nil];
    NSLog(@"第2次");
    [[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTip:) name:@"TipNotification" object:@"通知已发送"];
    NSLog(@"第3次");
    self.tipLabel.text = @"没有任何提示";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postNotificationEvent:(UIButton *)sender {
    [[BJNotificationCenter defaultCenter] postNotificationName:@"TipNotification" object:@"通知已发送"];
}

- (void)receiveTip:(BJNotification *)notification {
    self.tipLabel.text = notification.object;
}


@end
