//
//  ViewController.m
//  LJScrollView
//
//  Created by lj on 2017/5/8.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import "ViewController.h"
#import "LJSecondScrollViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
    LJSecondScrollViewController *second = [[LJSecondScrollViewController alloc]init];
    [self.navigationController pushViewController:second animated:YES];
}

@end
