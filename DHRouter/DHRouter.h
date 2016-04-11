//
//  DHRouter.h
//  DHRouter
//
//  Created by tailang on 4/8/16.
//  Copyright © 2016 com.2Dfire.Router. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIViewController+DHRouter.h"

typedef NS_ENUM(NSUInteger, DHRouterOpenStyle) {
    DHRouterOpenStyleStack,
    DHRouterOpenStyleStackRoot,
    DHRouterOpenStyleModal
};

@interface DHRouter : NSObject

//必须初始化DHRouter后，必须指定mySchemes，navigationController，且不能为空
@property (nonatomic, copy) NSArray *mySchemes;

@property (nonatomic, strong) UINavigationController *navigationController;

//只需要一个route时，使用单列初始化
+ (instancetype)shareManager;

//如果需要多个route时，可以使用该方法
+ (instancetype)newRouter;

//route和对应的类映射
- (BOOL)map:(NSString *)route toControllerClass:(Class)controllerClass;

//通过route匹配生成对应的uiviewcontroller对象
- (UIViewController *)matchControllerFromRoute:(NSString *)route otherParams:(NSDictionary *)otherParams;

//打开route对应的viewcontroller
- (void)open:(NSString *)route otherParams:(NSDictionary *)otherParams openStyle:(DHRouterOpenStyle)openStyle animation:(BOOL)animation;
@end
