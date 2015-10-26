//
//  ViewController.m
//  BJNotification
//
//  Created by WangXu on 15/10/26.
//  Copyright (c) 2015年 beijiahiddink. All rights reserved.
//

#import "ViewController.h"
#import "BJNotificationCenter.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)dealloc {
    [[BJNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)buttonClick:(id)sender {
    [[BJNotificationCenter defaultCenter] postNotificationName:@"demo" object:@"第二次"];
    [[BJNotificationCenter defaultCenter] postNotificationName:@"demo2" object:nil];
}

@end
