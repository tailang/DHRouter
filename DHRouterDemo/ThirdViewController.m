//
//  ThirdViewController.m
//  DHRouter
//
//  Created by tailang on 4/8/16.
//  Copyright © 2016 com.2Dfire.Router. All rights reserved.
//

#import "ThirdViewController.h"
#import "DHRouter.h"

@interface ThirdViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"打开一个新页面会自动dismiss本页面";
            break;
            
        case 1:
            cell.textLabel.text = @"点击手动dismiss本页面";
            break;
            
            
        default:
            break;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            [[DHRouter shareManager] open:@"DHRouter://secondViewController/detail/2?title=DHRouter&time=now"
                              otherParams:@{@"otherParams": @"test"}
                                openStyle:DHRouterOpenStyleStack
                                animation:YES];
        }
            break;
            
        case 1:
        {
            [[DHRouter shareManager] dissMissModalAnimated:YES DHRouterModalDismissCompletionBlock:^{
                NSLog(@"dismiss completion");
            }];
        }
            break;

        default:
            break;
    }
}

@end
