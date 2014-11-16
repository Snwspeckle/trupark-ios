//
//  NearParkingSpotTableViewController.m
//  TruPark
//
//  Created by Anthony on 11/15/14.
//  Copyright (c) 2014 Anthony Vella. All rights reserved.
//

#import "NearParkingLotTableViewController.h"
#import "ParkingLotTableViewCell.h"
#import "AppDelegate.h"

static NSString * const ParkingLotCellIdentifier = @"ParkingLotCellIdentifier";

@interface NearParkingLotTableViewController()

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation NearParkingLotTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:@"HideTableViewForMapScroll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:@"ShowTableViewForMapScroll" object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.appDelegate.parkingAnnotations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self parkingLotCellAtIndexPath:indexPath];
}

- (ParkingLotTableViewCell *)parkingLotCellAtIndexPath:(NSIndexPath *)indexPath
{
    ParkingLotTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ParkingLotCellIdentifier forIndexPath:indexPath];
    [self configureBasicCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureBasicCell:(ParkingLotTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.appDelegate.parkingAnnotations allKeys];
    NSDictionary *annotation = [self.appDelegate.parkingAnnotations objectForKey:[keys objectAtIndex:indexPath.row]];
    [self setTitleForCell:cell annotation:annotation];
    [self setSubtitleForCell:cell annotation:annotation];
}

- (void)setTitleForCell:(ParkingLotTableViewCell *)cell annotation:(NSDictionary *)annotation
{
    NSString *title = [annotation valueForKey:@"title"];
    cell.textLabel.text = title;
}

- (void)setSubtitleForCell:(ParkingLotTableViewCell *)cell annotation:(NSDictionary *)annotation
{
    NSString *subtitle = [annotation valueForKey:@"state"];
    
    cell.detailTextLabel.text = subtitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataModel *dataModel = nil;
    
    switch (indexPath.row) {
        case 0:
            dataModel = self.appDelegate.dataSpot1;
            break;
        case 1:
            dataModel = self.appDelegate.dataSpot2;
            break;
        case 2:
            dataModel = self.appDelegate.dataSpot3;
            break;
        default:
            break;
    }
    
    NSDictionary *cellDictionary = [NSDictionary dictionaryWithObject:dataModel forKey:@"row"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewCellSelected" object:self userInfo:cellDictionary];
}

- (void)receivedNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"HideTableViewForMapScroll"]) {
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
        }];
    } else if ([[notification name] isEqualToString:@"ShowTableViewForMapScroll"]) {
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            [self.tableView reloadData];
        }];
    }
}

- (NSMutableDictionary *)getAnnotations
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ParkingLots" ofType:@"json"];
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [fileContent dataUsingEncoding:NSUTF16StringEncoding];
    NSMutableDictionary *parsedAnnotations = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    return parsedAnnotations;
}

@end
