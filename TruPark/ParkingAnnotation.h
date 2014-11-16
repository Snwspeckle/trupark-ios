//
//  ParkingAnnotation.h
//  TruPark
//
//  Created by Anthony on 11/15/14.
//  Copyright (c) 2014 Anthony Vella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ParkingAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *sparkCoreID;
@property (nonatomic, copy) NSString *arrivalETA;

@end
