//
//  DataModel.h
//  TruPark
//
//  Created by Anthony on 11/16/14.
//  Copyright (c) 2014 Anthony Vella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *state;
@property (nonatomic) float lat;
@property (nonatomic) float lon;

@end
