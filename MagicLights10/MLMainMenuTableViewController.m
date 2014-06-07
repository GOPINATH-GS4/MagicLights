//
//  MLMainMenuTableViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/17/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLMainMenuTableViewController.h"
#import "MLLightsTableViewController.h"
#import "MLBridgesTableViewController.h"
#import "MLEffectsTableViewController.h"
#import "MLAudioTableViewController.h"
#import "MLFunTableViewController.h"
#import "MLConfigurationTableViewController.h"
@interface MLMainMenuTableViewController ()
@property (nonatomic, strong) UIAlertView *linkAlert;
@property (nonatomic) BOOL alertViewOnFocus;
@end

@implementation MLMainMenuTableViewController

@synthesize linkAlert = _linkAlert;
@synthesize mlLights = _mlLights;
@synthesize bridgeScanned = _bridgeScanned;
@synthesize alertViewOnFocus = _alertViewOnFocus;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self accessorySetupBeforeConnect:YES];
    
    [self.mlLights initPhHUE];
    [self.mlLights startupPhHUE];
    self.mlLights.connectionSource = self;
    [self.mlLights enableLocalHeartbeat:10];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) accessorySetupBeforeConnect:(BOOL) disabled {
    
    for (int i = 1; i <=4 ; i++) {
         NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        ([self.tableView cellForRowAtIndexPath:indexPath]).accessoryType =
                (disabled) ? UITableViewCellAccessoryNone:UITableViewCellAccessoryDetailDisclosureButton;
        
    }
    for (int i = 0; i < 3 ; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:1];
        ([self.tableView cellForRowAtIndexPath:indexPath]).accessoryType =
        (disabled) ? UITableViewCellAccessoryNone:UITableViewCellAccessoryDetailDisclosureButton;
        
    }


}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([segue.destinationViewController isKindOfClass:[MLBridgesTableViewController class]]) {
        ((MLBridgesTableViewController *)segue.destinationViewController).mlLights = self.mlLights;
        [self.mlLights disableLocalHeartbeat];
        [self.mlLights removeNotifications:self.mlLights];
    } else if ([segue.destinationViewController isKindOfClass:[MLLightsTableViewController class]]) {
        MLLightsTableViewController *lightsViewController = (MLLightsTableViewController *) segue.destinationViewController;
        lightsViewController.mlLights = self.mlLights;
        [self.mlLights disableLocalHeartbeat];
        [self.mlLights removeNotifications:self.mlLights];
        
    } else if ([segue.destinationViewController isKindOfClass:[MLEffectsTableViewController class]]) {
        MLEffectsTableViewController *effectsViewController = (MLEffectsTableViewController *) segue.destinationViewController;
        [self.mlLights disableLocalHeartbeat];
        effectsViewController.mlLights = self.mlLights;
        [self.mlLights removeNotifications:self.mlLights];
    } else if ([segue.destinationViewController isKindOfClass:[MLAudioTableViewController class]]) {
        MLAudioTableViewController *audioViewController = (MLAudioTableViewController *) segue.destinationViewController;
        [self.mlLights disableLocalHeartbeat];
        audioViewController.mlLights = self.mlLights;
        [self.mlLights removeNotifications:self.mlLights];
    } else if ([segue.destinationViewController isKindOfClass:[MLFunTableViewController class]]) {
        MLFunTableViewController *funViewController = (MLFunTableViewController *) segue.destinationViewController;
        [self.mlLights disableLocalHeartbeat];
        funViewController.mlLights = self.mlLights;
        [self.mlLights removeNotifications:self.mlLights];
    }
    else if ([segue.destinationViewController isKindOfClass:[MLConfigurationTableViewController class]]) {
        MLConfigurationTableViewController *configViewController = (MLConfigurationTableViewController *) segue.destinationViewController;
        [self.mlLights disableLocalHeartbeat];
        configViewController.mlLights = self.mlLights;
        [self.mlLights removeNotifications:self.mlLights];
    }
}

- (MLLights *) mlLights {
    if (_mlLights == nil) {
        _mlLights = [[MLLights alloc] init];
    }
    return _mlLights;
}

/**
 Notification receiver for successful local connection
 */

- (void) reloadtable {
    NSIndexPath *indexPath = [NSIndexPath  indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = (self.mlLights.currentIp == nil) ? @"Not connected":self.mlLights.currentIp;
    
    [self.tableView reloadData];

}
/**
 Notification receiver for failed local connection
 */
/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    
    if (self.bridgeScanned && !self.alertViewOnFocus) {
        self.linkAlert = [[UIAlertView alloc] initWithTitle:@"Push Link"
                                                message:@"Press the link button in the bridge (round button in the middle)"
                                               delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil];
        [self.linkAlert setUserInteractionEnabled:NO];
        [self.linkAlert show];
        self.alertViewOnFocus = YES;
        [self startPushLinking];
    }
    
    
}
- (void)localConnection {
    // Check current connection state
    [self checkConnectionState];
}

- (void)noLocalConnection {
    // Check current connection state
    [self checkConnectionState];
}

- (void)checkConnectionState {
      if (!self.mlLights.phHueSDK.localConnected) {
        NSLog(@"Not Connected ....");
        self.mlLights.currentIp = nil;
       
        
    }
    else {
        NSLog(@"Connected ....");
        if (self.mlLights.currentIp != nil) {
             [self accessorySetupBeforeConnect:NO];
        }
       
        
    }
    [self reloadtable];
}
- (void)startPushLinking {
    /***************************************************
     Set up the notifications for push linkng
     *****************************************************/
    
    // Register for notifications about pushlinking
    PHNotificationManager *phNotificationMgr = [PHNotificationManager defaultManager];
    
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationSuccess) forNotification:PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationFailed) forNotification:PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalConnection) forNotification:PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalBridge) forNotification:PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(buttonNotPressed:) forNotification:PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION];
    
    // Call to the hue SDK to start pushlinking process
    /***************************************************
     Call the SDK to start Push linking.
     The notifications sent by the SDK will confirm success
     or failure of push linking
     *****************************************************/
    
    [self.mlLights.phHueSDK startPushlinkAuthentication];
}
/**
 Notification receiver which is called when the pushlinking was successful
 */
- (void)authenticationSuccess {
    /***************************************************
     The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION
     was received. We have confirmed the bridge.
     De-register for notifications and call
     pushLinkSuccess on the delegate
     *****************************************************/
    // Deregister for all notifications
    //[[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    [self.linkAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.linkAlert = [[UIAlertView alloc] initWithTitle:@"Push Link"
                                                message:@"Push Link Sucess"
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    [self.linkAlert show];
}

/**
 Notification receiver which is called when the pushlinking failed because the time limit was reached
 */
- (void)authenticationFailed {
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    [self.linkAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.linkAlert = [[UIAlertView alloc] initWithTitle:@"Push Link"
                                                message:@"Authentication Failed, device probably is locked or lost internet connection, or you did not press the link button within the timelimit"
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    [self.linkAlert show];

}

/**
 Notification receiver which is called when the pushlinking failed because the local connection to the bridge was lost
 */

/**
 Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
 */
- (void)noLocalBridge {
    // Deregister for all notifications
   [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    // Inform delegate
    [self.linkAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.linkAlert = [[UIAlertView alloc] initWithTitle:@"Push Link"
                                                message:@"No Local Bridge, please make sure the bridge is connected to Internet"
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    [self.linkAlert show];

   
}
/**
 This method is called when the pushlinking is still ongoing but no button was pressed yet.
 @param notification The notification which contains the pushlinking percentage which has passed.
 */
- (void)buttonNotPressed:(NSNotification *)notification {
    // Update status bar with percentage from notification
    //NSDictionary *dict = notification.userInfo;
    //NSNumber *progressPercentage = [dict objectForKey:@"progressPercentage"];
    
    // Convert percentage to the progressbar scale
    //float progressBarValue = [progressPercentage floatValue] / 100.0f;
    //self.progressView.progress = progressBarValue;
    //[self.linkAlert dismissWithClickedButtonIndex:0 animated:YES];
    //self.linkAlert = [[UIAlertView alloc] initWithTitle:@"Push Link"
     //                                           message:@"Push Link Failed, you did not press the button within time limit"
       //                                        delegate:self
         //                             cancelButtonTitle:@"OK"
           //                           otherButtonTitles:nil];
    //[self.linkAlert show];
    
}
- (void) foundBridges:(NSDictionary *)bridges {

}
- (void) notFoundBridges {
    
}
#pragma --mark talertViewDelegate
- (void)alertViewCancel:(UIAlertView *)alertView {
    self.alertViewOnFocus = NO;
}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.alertViewOnFocus = NO;
}
@end
