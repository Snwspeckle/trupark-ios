//
//  AppDelegate.m
//  TruPark
//
//  Created by Anthony on 11/15/14.
//  Copyright (c) 2014 Anthony Vella. All rights reserved.
//

#import "AppDelegate.h"
#import "DataModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:101.0/255.0 blue:101.0/255.0 alpha:1.0]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.dataSpot1 = [[DataModel alloc] init];
    self.dataSpot1.deviceID = @"55ff70065075555329431787";
    self.dataSpot1.name = @"parkingSpot1";
    self.dataSpot1.title = @"435-439 Riddle Rd";
    self.dataSpot1.state = @"Taken";
    self.dataSpot1.lat = 39.135445;
    self.dataSpot1.lon = -84.521911;
    
    self.dataSpot2 = [[DataModel alloc] init];
    self.dataSpot2.deviceID = @"54ff73066667515149361367";
    self.dataSpot2.name = @"parkingSpot2";
    self.dataSpot2.title = @"2380 Wheeler St";
    self.dataSpot2.state = @"Taken";
    self.dataSpot2.lat = 39.127302;
    self.dataSpot2.lon = -84.520388;
    
    self.dataSpot3 = [[DataModel alloc] init];
    self.dataSpot3.deviceID = @"53ff70065075535113331387";
    self.dataSpot3.name = @"parkingSpot3";
    self.dataSpot3.title = @"22823 Glendora Ave";
    self.dataSpot3.state = @"Taken";
    self.dataSpot3.lat = 39.132491;
    self.dataSpot3.lon = -84.510142;
    
    self.parkingAnnotations = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.dataSpot1, @"dataSpot1", self.dataSpot2, @"dataSpot2", self.dataSpot3, @"dataSpot3", nil];
    
    NSLog(@"%@", self.parkingAnnotations);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
