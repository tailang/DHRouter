//
//  ViewController.m
//  DHRouter
//
//  Created by tailang on 4/8/16.
//  Copyright © 2016 com.2Dfire.Router. All rights reserved.
//

#import "ViewController.h"
#import "DHRouter.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"DHRouter";
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
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"打开本应用的页面";
            break;
            
        case 1:
            cell.textLabel.text = @"在本应用中打开网页";
            break;
            
        case 2:
            cell.textLabel.text = @"打开其他应用";
            break;
            
        case 3:
            cell.textLabel.text = @"以modal的方式打开一个新页面";
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
            //没错，baidu就是用来测试网络的
            [[DHRouter shareManager] open:@"http://baidu.com"];
        }
            break;
            
        case 2:
        {
            [[DHRouter shareManager] open:@"calshow://"];
        }
            break;
            
        case 3:
        {
            [[DHRouter shareManager] open:@"DHRouter://thirdViewController/detail/1?title=DHRouter&time=now"
                              otherParams:@{@"otherParams": @"test"}
                                openStyle:DHRouterOpenStyleModal
                                animation:YES];
        }
            break;
            
        default:
            break;
    }
}
@end
