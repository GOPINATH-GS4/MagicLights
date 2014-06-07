//
//  MLFunTableViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/28/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLFunTableViewController.h"
#import "MLBoxingViewController.h"
#import "MLDanceViewController.h"
#import "MLColorScannerViewController.h"

@interface MLFunTableViewController ()

@end

@implementation MLFunTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([segue.destinationViewController isKindOfClass:[MLBoxingViewController class]]) {
        ((MLBoxingViewController *)segue.destinationViewController).mlLights = self.mlLights;
        [self.mlLights disableLocalHeartbeat];
        [self.mlLights removeNotifications:self.mlLights];
    } else if ([segue.destinationViewController isKindOfClass:[MLDanceViewController class]]) {
        ((MLDanceViewController *)segue.destinationViewController).mlLights = self.mlLights;
        [self.mlLights disableLocalHeartbeat];
        [self.mlLights removeNotifications:self.mlLights];
    } else if ([segue.destinationViewController isKindOfClass:[MLColorScannerViewController class]]) {
        ((MLColorScannerViewController *)segue.destinationViewController).mlLights = self.mlLights;
        [self.mlLights disableLocalHeartbeat];
        [self.mlLights removeNotifications:self.mlLights];
    }
    
}

@end
