//
//  FirstPageController.m
//  BJNotification
//
//  Created by WangXu on 15/11/11.
//  Copyright © 2015年 beijiahiddink. All rights reserved.
//

#import "FirstPageController.h"
#import "BJNotification.h"

@interface FirstPageController ()

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation FirstPageController

- (void)dealloc {
    [[BJNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"FirstPage";
    [[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTip:) name:@"TipNotification" object:nil];
    self.tipLabel.text = @"没有任何提示";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receiveTip:(BJNotification *)notification {
    NSArray *array = notification.object;
    self.tipLabel.text = array.firstObject;
    self.tipLabel.textColor = array.lastObject;
}

@end
