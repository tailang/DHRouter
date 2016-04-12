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
    DHRouterOpenStyleStack, //将viewController push进栈
    DHRouterOpenStyleStackRoot, //将viewcontroller push进栈作为Root
    DHRouterOpenStyleModal //已present modal的形式显示viewcontroller
};


@interface DHRouter : NSObject

/**
 *  必须初始化DHRouter后，必须指定mySchemes，navigationController，且不能为空,
 *  如果需要打开网页，需要指定webViewController，如果没有指定则使用Safari打开
 */


@property (nonatomic, copy) NSArray *mySchemes; //应用中使用的URL的schemes，必须添加到该白名单

@property (nonatomic, strong) UINavigationController *navigationController; //router需要有且只有一个对应的navigationcontroller

//如果应用中需要打开网页，并且不希望跳转到Safari中显示，那么你需要指定一个webViewController,
//并且webViewController必须包含一个属性DHRouterURL，类型为NSURL
@property (nonatomic, strong) UIViewController *webViewController;

/**
 *  只需要一个router时，使用单列初始化
 *
 *  @return DHRouter单例对象
 */
+ (instancetype)shareManager;

/**
 *  如果需要多个router对应多个navigationcontroller，可以使用该方法生成多个router
 *
 *  @return DHRtour对象
 */
+ (instancetype)newRouter;

/**
 *  route和对应的类映射
 *
 *  @param route           即URL
 *  @param controllerClass 对应的类
 *
 *  @return 如果映射成功，返回YES,反之返回NO
 */
- (BOOL)map:(NSString *)route toControllerClass:(Class)controllerClass;

/**
 *  通过route匹配生成对应的uiviewcontroller对象
 *
 *  @param route       即URL
 *  @param otherParams URL中可以包含一些简单的参数，如果需要添加一些其他复杂的参数，如对象，可以放在这
 *
 *  @return 对应的UIViewController对象
 */
- (UIViewController *)matchControllerFromRoute:(NSString *)route otherParams:(NSDictionary *)otherParams;

/**
 *  打开route对应的viewcontroller
 *
 *  @param route       即URL
 *  @param otherParams 除URL中包含的参数的其他参数
 *  @param openStyle   打开方式
 *  @param animation   是否显示动画
 */
- (void)open:(NSString *)route
 otherParams:(NSDictionary *)otherParams
   openStyle:(DHRouterOpenStyle)openStyle
   animation:(BOOL)animation;

/**
 *  - (void)open:(NSString *)route
 otherParams:(NSDictionary *)otherParams
 openStyle:(DHRouterOpenStyle)openStyle
 animation:(BOOL)animation; 方法的快速调用，otherParams=nil，openStyle=DHRouterOpenStyleStack， animation=YES
 *
 *  @param route 即URL
 */
- (void)open:(NSString *)route;

/**
 *  - (void)open:(NSString *)route
 otherParams:(NSDictionary *)otherParams
 openStyle:(DHRouterOpenStyle)openStyle
 animation:(BOOL)animation; 方法的快速调用，openStyle=DHRouterOpenStyleStack， animation=YES
 *
 *  @param route       即URL
 *  @param otherParams 其他参数
 */
- (void)open:(NSString *)route otherParams:(NSDictionary *)otherParams;

/**
 *  虽然每次新open一个页面，如果navigationcontroller上存在modal页面会先自动dismiss，
 但有时我们可能也想手动dismiss对应的modal页面，那么你可以使用该方法
 *
 *  @param animated                            是否显示动画
 *  @param DHRouterModalDismissCompletionBlock dismiss成功后的回调
 */
- (void)dissMissModalAnimated:(BOOL)animated DHRouterModalDismissCompletionBlock:(void(^)(void))DHRouterModalDismissCompletionBlock;
@end
