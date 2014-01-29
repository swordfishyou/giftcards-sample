//
//  GCAppDelegate.m
//  cards
//
//  Created by Anatoly Tukhtarov on 1/29/14.
//  Copyright (c) 2014 Anatoly Tukhtarov. All rights reserved.
//

#import "GCAppDelegate.h"

@implementation GCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end