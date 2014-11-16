//
//  ViewController.m
//  TruPark
//
//  Created by Anthony on 11/15/14.
//  Copyright (c) 2014 Anthony Vella. All rights reserved.
//

#import "ParkMapViewController.h"
#import "ParkingAnnotation.h"
#import "ParkingAnnotationView.h"
#import <AFNetworking/AFNetworking.h>
#import "ZSPinAnnotation.h"
#import "AppDelegate.h"
#import "DataModel.h"

@interface ParkMapViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation ParkMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.ParkingAnnotationArray = [[NSMutableArray alloc] init];
            
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [super viewDidLoad];
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:@"TableViewCellSelected" object:nil];
    
    #ifdef __IPHONE_8_0
    if (IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    #endif
    
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self blueButtonNetworkManager];
    [self yellowButtonNetworkManager];
    [self redButtonNetworkManager];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self addParkingLotAnnotations];
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    //View Area
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.0165f;
    span.longitudeDelta = 0.0165f;
    CLLocationCoordinate2D location;
    location.latitude = self.locationManager.location.coordinate.latitude - 0.003;
    location.longitude = self.locationManager.location.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.mapView setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addParkingLotAnnotations
{
    for (NSString *key in [self.appDelegate.parkingAnnotations allKeys] ) {
        DataModel *dataModel = [self.appDelegate.parkingAnnotations objectForKey:key];
        ParkingAnnotation *parkingAnnotation = [[ParkingAnnotation alloc] init];
        CLLocationDegrees lat = [dataModel lat];
        CLLocationDegrees lon = [dataModel lon];
        parkingAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
        parkingAnnotation.title = [dataModel title];
        parkingAnnotation.subtitle = [dataModel state];
        parkingAnnotation.sparkCoreID = [dataModel deviceID];
        
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:parkingAnnotation.coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        NSTimeInterval arrivalETA = [self calculateArrivalTime:mapItem];
        NSInteger minutesETAConversion = ((NSInteger)arrivalETA / 60) % 60;
        parkingAnnotation.arrivalETA = [NSString stringWithFormat:@"%ld", (long)minutesETAConversion];
        
        [self.ParkingAnnotationArray addObject:parkingAnnotation];
        [self.mapView addAnnotation:parkingAnnotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(NSObject<MKAnnotation>*)annotation
{
    if ([annotation isEqual:[mapView userLocation]]) {
        return nil;
    }
    
    static NSString *defaultPinID = @"ParkingLotAnnotation";
    ZSPinAnnotation *pinView = (ZSPinAnnotation *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if (pinView == nil){
        pinView = [[ZSPinAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    }
    
    NSString *annotationState = [annotation valueForKey:@"subtitle"];
    
    if ([annotationState isEqualToString:@"Open"]) {
        pinView.annotationColor = [UIColor greenColor];
    } else if ([annotationState isEqualToString:@"Taken"]) {
        pinView.annotationColor = [UIColor redColor];
    } else {
        pinView.annotationColor = [UIColor yellowColor];
    }
    
    UIView *viewLeftAccessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pinView.frame.size.height - 15, pinView.frame.size.height)];
    viewLeftAccessory.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:101.0/255.0 blue:101.0/255.0 alpha:1.0];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapRecognizer.cancelsTouchesInView = NO;
    tapRecognizer.delegate = self;
    [viewLeftAccessory addGestureRecognizer:tapRecognizer];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, -10, pinView.frame.size.height - 55, pinView.frame.size.height - 55)];
    UILabel *arrivalETALabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 28, pinView.frame.size.height - 50, pinView.frame.size.height - 70)];
    arrivalETALabel.textColor = [UIColor whiteColor];
    
    arrivalETALabel.text = [NSString stringWithFormat:@"%@ min", [annotation valueForKey:@"arrivalETA"]];
    imageView.image = [UIImage imageNamed:@"CalloutIcon"];
    
    [viewLeftAccessory addSubview:imageView];
    [viewLeftAccessory addSubview:arrivalETALabel];
    
    pinView.leftCalloutAccessoryView = viewLeftAccessory;
    
    pinView.centerOffset = CGPointMake(10, -20);
    
    pinView.annotationType = ZSPinAnnotationTypeStandard;
    pinView.contentMode = UIViewContentModeScaleAspectFit;
    pinView.dragState = MKAnnotationViewDragStateNone;
    pinView.canShowCallout = YES;
    
    return pinView;
}

- (NSString *)deviceLocation
{
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}

- (NSString *)deviceLat
{
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
}

- (NSString *)deviceLon
{
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
}

- (NSString *)deviceAlt
{
    return [NSString stringWithFormat:@"%f", self.locationManager.location.altitude];
}

- (void)blueButtonNetworkManager
{
    // Blue Button Request
    AFHTTPRequestOperationManager *blueManager = [AFHTTPRequestOperationManager manager];
    [blueManager GET:@"https://api.spark.io/v1/devices/55ff70065075555329431787/buttonPresse?access_token=44c73e488bd939af04dc6886f03ecf3923d7146d" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self validateParkingLot:responseObject];
        [self blueButtonNetworkManager];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)yellowButtonNetworkManager
{
    // Yellow Button Request
    AFHTTPRequestOperationManager *yellowManager = [AFHTTPRequestOperationManager manager];
    [yellowManager GET:@"https://api.spark.io/v1/devices/54ff73066667515149361367/buttonPresse?access_token=44c73e488bd939af04dc6886f03ecf3923d7146d" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self validateParkingLot:responseObject];
        [self yellowButtonNetworkManager];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)redButtonNetworkManager
{
    // Red Button Request
    AFHTTPRequestOperationManager *redManager = [AFHTTPRequestOperationManager manager];
    [redManager GET:@"https://api.spark.io/v1/devices/53ff70065075535113331387/buttonPresse?access_token=44c73e488bd939af04dc6886f03ecf3923d7146d" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self validateParkingLot:responseObject];
        [self redButtonNetworkManager];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)validateParkingLot:(id)responseObject
{
    NSInteger serverResult = [[responseObject valueForKey:@"result"] integerValue];
    NSString *deviceID = [[responseObject objectForKey:@"coreInfo"] valueForKey:@"deviceID"];
    
    for (ParkingAnnotation *parkingAnnotation in self.mapView.annotations) {
        if ([parkingAnnotation isKindOfClass:[ParkingAnnotation class]]) {
            switch (serverResult) {
                case 1:
                    if ([deviceID isEqualToString:parkingAnnotation.sparkCoreID]) {
                        parkingAnnotation.subtitle = @"Taken";
                        [self updateAnnotationColor:parkingAnnotation];
                    }
                    break;
                case 0:
                    if ([deviceID isEqualToString:parkingAnnotation.sparkCoreID]) {
                        parkingAnnotation.subtitle = @"Open";
                        [self updateAnnotationColor:parkingAnnotation];
                    }
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)updateAnnotationColor:(ParkingAnnotation *)paramAnnotation
{
    ZSPinAnnotation *pinView = (ZSPinAnnotation *)[self.mapView viewForAnnotation:paramAnnotation];
    
    if ([paramAnnotation.subtitle isEqualToString:@"Open"]) {
        pinView.annotationColor = [UIColor greenColor];
    } else if ([paramAnnotation.subtitle isEqualToString:@"Taken"]) {
        pinView.annotationColor = [UIColor redColor];
    } else {
        pinView.annotationColor = [UIColor yellowColor];
    }
}

- (void)receivedNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"TableViewCellSelected"]) {
        NSDictionary *cellDictionary = [notification userInfo];
        DataModel *dataModel = [cellDictionary objectForKey:@"row"];
        NSString *dataTitle = [dataModel title];
        ParkingAnnotation *pAnn = nil;
        
        for (ParkingAnnotation *p in self.ParkingAnnotationArray) {
            if ([dataTitle isEqualToString:[p title]]) {
                pAnn = p;
            }
        }
        
        [self.mapView setCenterCoordinate:[pAnn coordinate] animated:YES];
        [self.mapView selectAnnotation:pAnn animated:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTableViewForMapScroll" object:self];
        [self.mapView deselectAnnotation:[[self.mapView annotations] lastObject] animated:YES];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTableViewForMapScroll" object:self];
    }
}

- (NSTimeInterval)calculateArrivalTime:(MKMapItem *)endItem
{
    __block MKRoute *drivingRoute = nil;
    MKDirectionsRequest *drivingRouteRequest = [[MKDirectionsRequest alloc] init];
    drivingRouteRequest.transportType = MKDirectionsTransportTypeAutomobile;
    [drivingRouteRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    [drivingRouteRequest setDestination:endItem];
    MKDirections *drivingRouteDirections = [[MKDirections alloc] initWithRequest:drivingRouteRequest];
    [drivingRouteDirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if ( ! error && [response routes] > 0) {
            drivingRoute = [[response routes] objectAtIndex:0];
        }
    }];
    
    return drivingRoute.expectedTravelTime;
}

//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
//{
//    id annotation = view.annotation;
//    if ([annotation isKindOfClass:[ParkingAnnotation class]]) {
//        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
//        [request setSource:[MKMapItem mapItemForCurrentLocation]];
//        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:view.annotation.coordinate addressDictionary:nil];
//        MKMapItem *endItem = [[MKMapItem alloc] initWithPlacemark:placemark];
//        [request setDestination:endItem];
//        [request setTransportType:MKDirectionsTransportTypeAutomobile];
//        [request setRequestsAlternateRoutes:NO];
//        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
//        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//            if ( ! error && [response routes] > 0) {
//                MKRoute *route = [[response routes] objectAtIndex:0];
//                [MKMapItem openMapsWithItems:[response routes] launchOptions:nil];
//            }
//        }];
//    }
//}

- (void)tapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)sender;
        
        tapRecognizer.view.alpha = 0.50;
    }
}

//- (NSMutableDictionary *)getAnnotations
//{
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ParkingLots" ofType:@"json"];
//    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    NSData *jsonData = [fileContent dataUsingEncoding:NSUTF16StringEncoding];
//    NSMutableDictionary *parsedAnnotations = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
//    return parsedAnnotations;
//}

@end
