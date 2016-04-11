//
//  UIViewController+DHRouter.m
//  DHRouter
//
//  Created by tailang on 4/8/16.
//  Copyright © 2016 com.2Dfire.Router. All rights reserved.
//

#import "UIViewController+DHRouter.h"
#import <objc/runtime.h>

@implementation UIViewController (DHRouter)

- (void)setDHRouterParams:(NSDictionary *)paramsDictionary
{
    objc_setAssociatedObject(self, @selector(DHRouterParams), paramsDictionary, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)DHRouterParams
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
