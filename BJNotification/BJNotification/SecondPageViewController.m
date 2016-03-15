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
    self.tipLabel.text = @"静夜思";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postNotificationEvent:(UIButton *)sender {
    NSArray *array = @[@"窗前明月光",@"疑是地上霜",@"举头望明月",@"低头思故乡"];
    int index = arc4random() % array.count;
    [[BJNotificationCenter defaultCenter] postNotificationName:@"TipNotification" object:array[index]];
}

- (void)receiveTip:(BJNotification *)notification {
    self.tipLabel.text = notification.object;
}


@end
