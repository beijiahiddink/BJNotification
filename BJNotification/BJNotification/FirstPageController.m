//
//  FirstPageController.m
//  BJNotification <https://github.com/beijiahiddink/BJNotification>
//
//  Created by WangXu on 15/11/11.
//  Copyright © 2015年 beijiahiddink. All rights reserved.
//
//  For the full copyright and license information, please view the README
//  file that was distributed with this source code.
//

#import "FirstPageController.h"
#import "BJNotification.h"

@interface FirstPageController ()

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation FirstPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"FirstPage";
    [[BJNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveText:) name:TextNotificationKey object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[BJNotificationCenter defaultCenter] postNotificationName:TextNotificationKey object:textAction()];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receiveText:(BJNotification *)notification {
    self.tipLabel.text = notification.object;
}

@end
