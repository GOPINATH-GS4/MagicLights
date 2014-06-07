//
//  MLAudioTableViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/27/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLAudioTableViewController.h"
#import "MLVoiceCommandViewController.h"
#import "MLMusicViewController.h"
@interface MLAudioTableViewController ()

@end

@implementation MLAudioTableViewController
@synthesize mlLights = _mlLights;

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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[MLVoiceCommandViewController class]]) {
        ((MLVoiceCommandViewController *)segue.destinationViewController).mlLights = self.mlLights;
        [self.mlLights disableLocalHeartbeat];
        [self.mlLights removeNotifications:self.mlLights];
    } else if ([segue.destinationViewController isKindOfClass:[MLMusicViewController class]]) {
        ((MLMusicViewController *)segue.destinationViewController).mlLights = self.mlLights;
        [self.mlLights disableLocalHeartbeat];
        [self.mlLights removeNotifications:self.mlLights];
    }
    
}
#pragma mark - Table view data source

@end
