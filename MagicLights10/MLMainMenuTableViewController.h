//
//  MLMainMenuTableViewController.h
//  MagicLights
//
//  Created by janakiraman gopinath on 5/17/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLLights.h"
@interface MLMainMenuTableViewController : UITableViewController <MLConnectionStatus, UIAlertViewDelegate>
@property (nonatomic, strong) MLLights *mlLights;
@property (nonatomic) BOOL bridgeScanned;
@end
