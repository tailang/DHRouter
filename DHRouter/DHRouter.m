//
//  DHRouter.m
//  DHRouter
//
//  Created by tailang on 4/8/16.
//  Copyright © 2016 com.2Dfire.Router. All rights reserved.
//

#import "DHRouter.h"
#import <objc/runtime.h>

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

- (void)open:(NSString *)route
{
    [self open:route otherParams:nil openStyle:DHRouterOpenStyleStack animation:YES];
}

- (void)open:(NSString *)route otherParams:(NSDictionary *)otherParams{
    [self open:route otherParams:otherParams openStyle:DHRouterOpenStyleStack animation:YES];
}

- (void)open:(NSString *)route otherParams:(NSDictionary *)otherParams openStyle:(DHRouterOpenStyle)openStyle animation:(BOOL)animation
{
    NSURL *URL = [[NSURL alloc] initWithString:route];
    NSString *scheme = URL.scheme;
    
    if (!scheme) {
        NSAssert(NO, @"the scheme can not be nil");
    }
    
    if ([scheme.lowercaseString isEqualToString:@"http"] || [scheme.lowercaseString isEqualToString:@"https"]) {
        if (self.navigationController) {
            if (self.webViewController) {
                
                if ([self classOfPropertyNamed:@"DHRouterURL" propertyclass:[self.webViewController class]] == [NSURL class]) {
                    [self.webViewController setValue:URL forKey:@"DHRouterURL"];
                    [self.navigationController pushViewController:self.webViewController animated:animation];
                }else{
                    NSAssert(NO, @"the DHRouterURL's class is not NSURL, it should be NSURL");
                }
                
            }else{
                //用Safari打开网页
                [[UIApplication sharedApplication] openURL:URL];
            }
        }else{
            NSAssert(NO, @"the router navigationcontroller can not find");
        }
    }else if ([self.mySchemes containsObject:scheme]) {
        UIViewController *viewController = [self matchControllerFromRoute:route otherParams:otherParams];
        if (self.navigationController) {
            //如果当前页面有modal 先dismiss
            if (self.navigationController.presentedViewController) {
                //Q:在present modal和dismiss modal的时候，要异步放入主队列，不然有时要等待2-3s才完成，下同
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController dismissViewControllerAnimated:NO completion:^{
                        [self viewController:viewController openStyle:openStyle animation:animation];
                    }];
                });
            }else{
                [self viewController:viewController openStyle:openStyle animation:animation];
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

- (void)dissMissModalAnimated:(BOOL)animated DHRouterModalDismissCompletionBlock:(void(^)(void))DHRouterModalDismissCompletionBlock
{
    if (self.navigationController.presentedViewController) {
        NSLog(@"start dismiss");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController dismissViewControllerAnimated:animated completion:^{
                DHRouterModalDismissCompletionBlock();
            }];
        });

    }
    
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

- (Class)classOfPropertyNamed:(NSString*) propertyName propertyclass:(Class)propertyclass
{
    if (class_getProperty(propertyclass, "DHRouterURL")) {
        Class propertyClass = nil;
        objc_property_t property = class_getProperty(propertyclass, [propertyName UTF8String]);
        NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
        if (splitPropertyAttributes.count > 0)
        {
            NSString *encodeType = splitPropertyAttributes[0];
            NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
            NSString *className = splitEncodeType[1];
            propertyClass = NSClassFromString(className);
        }
        return propertyClass;
    }else{
        NSAssert(NO, @"the webViewController don't has DHRouterURL property");
        return nil;
    }
}

- (void)viewController:(UIViewController *)viewController openStyle:(DHRouterOpenStyle)openStyle animation:(BOOL)animation
{
    if (openStyle == DHRouterOpenStyleModal) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:nav animated:animation completion:^{
                
            }];
        });
        
    }else if (openStyle == DHRouterOpenStyleStack) {
        [self.navigationController pushViewController:viewController animated:animation];
    }else if (openStyle == DHRouterOpenStyleStackRoot) {
        [self.navigationController setViewControllers:@[viewController] animated:animation];
    }else{
        NSAssert(NO, @"please use true DHRouterOpenStyle");
    }
}

@end
