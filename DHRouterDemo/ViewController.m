//
//  ViewController.m
//  DHRouter
//
//  Created by tailang on 4/8/16.
//  Copyright © 2016 com.2Dfire.Router. All rights reserved.
//

#import "ViewController.h"
#import "DHRouter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    button.backgroundColor = [UIColor blueColor];
    [button addTarget:self action:@selector(go:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(10, 100, 100, 100);
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)go:(UIButton *)uu
{
    [[DHRouter shareManager] open:@"CardApp://order/detail" otherParams:nil openStyle:DHRouterOpenStyleModal animation:YES];
}

@end
