//
//  AppDelegate.h
//  TruPark
//
//  Created by Anthony on 11/15/14.
//  Copyright (c) 2014 Anthony Vella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableDictionary *parkingAnnotations;
@property (strong, nonatomic) DataModel *dataSpot1;
@property (strong, nonatomic) DataModel *dataSpot2;
@property (strong, nonatomic) DataModel *dataSpot3;

@end

