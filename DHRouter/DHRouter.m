//
//  DHRouter.m
//  DHRouter
//
//  Created by tailang on 4/8/16.
//  Copyright © 2016 com.2Dfire.Router. All rights reserved.
//

#import "DHRouter.h"
#import "UIViewController+DHRouter.h"

@interface DHRouter()

@property (nonatomic, strong) NSMutableDictionary *routes;

@end

@implementation DHRouter

#pragma mark - public

+ (instancetype)shareManager
{
    static DHRouter *router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!router) {
            router = [[DHRouter alloc] init];
        }
    });
    
    return router;
}

+ (instancetype)newRouter
{
    return [[self alloc] init];
}

- (void)open:(NSString *)route otherParams:(NSDictionary *)otherParams openStyle:(DHRouterOpenStyle)openStyle animation:(BOOL)animation
{
    NSURL *URL = [[NSURL alloc] initWithString:route];
    NSString *scheme = URL.scheme;
    
    if (!scheme) {
        NSAssert(NO, @"the scheme can not be nil");
    }
    
    if ([scheme.lowercaseString isEqualToString:@"http"] || [scheme.lowercaseString isEqualToString:@"https"]) {
        //TODO: webview
    }else if ([self.mySchemes containsObject:scheme]) {
        UIViewController *viewController = [self matchControllerFromRoute:route otherParams:otherParams];
        if (self.navigationController) {
            //如果当前页面有modal 先dismiss
            if (self.navigationController.presentedViewController) {
                [self.navigationController dismissViewControllerAnimated:NO completion:nil];
            }
            
            if (openStyle == DHRouterOpenStyleModal) {
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
                [self.navigationController presentViewController:nav animated:animation completion:^{
                    
                }];
            }else if (openStyle == DHRouterOpenStyleStack) {
                [self.navigationController pushViewController:viewController animated:animation];
            }else if (openStyle == DHRouterOpenStyleStackRoot) {
                [self.navigationController setViewControllers:@[viewController] animated:animation];
            }else{
                NSAssert(NO, @"please use true DHRouterOpenStyle");
            }
        
        }else{
            NSAssert(NO, @"the router navigationcontroller can not find");
        }
    }else{
        [[UIApplication sharedApplication] openURL:URL];
    }
}


- (UIViewController *)matchControllerFromRoute:(NSString *)route otherParams:(NSDictionary *)otherParams
{
    NSMutableDictionary *params = [self getParamsInRoute:route];
    [otherParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [params setObject:obj forKey:key];
    }];
    
    Class controllerClass = params[@"controller_class"];
    
    UIViewController *viewController = [[controllerClass alloc] init];
    if ([viewController respondsToSelector:@selector(setDHRouterParams:)]) {
        [viewController performSelector:@selector(setDHRouterParams:)
                             withObject:[params copy]];
    }
    
    return viewController;
}

- (BOOL)map:(NSString *)route toControllerClass:(Class)controllerClass
{
    NSArray *URLElements = [self getElementsFromURL:[self checkRoute:route]];
    __block NSMutableDictionary *subRoutes = self.routes;
    [URLElements enumerateObjectsUsingBlock:^(NSString *URLElement, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![subRoutes objectForKey:URLElement]) {
            subRoutes[URLElement] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[URLElement];
    }];
    
    subRoutes[@"target"] = controllerClass;
    
    return YES;
}

#pragma mark - private

- (NSMutableDictionary *)routes
{
    if (!_routes) {
        _routes = [[NSMutableDictionary alloc] init];
    }
    
    return _routes;
}

- (NSMutableDictionary *)getParamsInRoute:(NSString *)route
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSURL *URL = [self checkRoute:route];
    
    NSString *noQueryRoute = route;
    
    if (URL.query) {
        NSString *query = [@"?" stringByAppendingString:URL.query];
        noQueryRoute = [route stringByReplacingOccurrencesOfString:query withString:@""];
    }
    
    
    //get params from URL Path
    __block NSMutableDictionary *subRoutes = self.routes;
    NSArray *URLElements = [self getElementsFromURL:[[NSURL alloc] initWithString:noQueryRoute]];
    
    for (NSString *URLElement in URLElements) {
        BOOL found = NO;
        NSArray *subRoutesKeys = subRoutes.allKeys;
        for (NSString *key in subRoutesKeys) {
            if ([subRoutesKeys containsObject:URLElement]) {
                found = YES;
                subRoutes = subRoutes[URLElement];
                break;
            } else if ([key hasPrefix:@":"]) {
                found = YES;
                subRoutes = subRoutes[key];
                params[[key substringFromIndex:1]] = URLElement;
                break;
            }
        }
        if (!found) {
            return nil;
        }
    }
    
    [params setObject:subRoutes[@"target"] forKey:@"controller_class"];
    
    //get params from URL Query
    if (URL.query) {
        NSArray *queryStringArray = [URL.query componentsSeparatedByString:@"&"];
        for (NSString *queryString in queryStringArray) {
            NSArray *paramStringArray = [queryString componentsSeparatedByString:@"="];
            if (paramStringArray && paramStringArray.count > 1) {
                NSString *key = [paramStringArray objectAtIndex:0];
                NSString *value = [paramStringArray objectAtIndex:1];
                [params setObject:value forKey:key];
            }
        }
    }
   
    
    return params;
}

- (NSArray *)getElementsFromURL:(NSURL *)URL
{
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:URL.scheme];
    [elements addObject:URL.host];
    
    for (NSString *component in URL.pathComponents) {
        if ([component isEqualToString:@"/"]) {
            continue;
        }
        
        if ([component isEqualToString:@"?"]) {
            NSAssert(NO, @"The map URL can not contain '?' ");
        }
        
        [elements addObject:component];
    }
    
    return (NSArray *)elements;
}

- (NSURL *)checkRoute:(NSString *)route
{
    if (!route) {
        NSAssert(NO, @"route can not be nil");
    }
    
    NSURL *routeURL = [[NSURL alloc] initWithString:route];
    if (!routeURL || !routeURL.scheme) {
        NSAssert(NO, @"route format is wrong, maybe the scheme is nil");
    }
    
    if (![self.mySchemes containsObject:routeURL.scheme]) {
        NSAssert(NO, @"the URL scheme must be in mySchemes");
    }
    
    return routeURL;
}

@end
