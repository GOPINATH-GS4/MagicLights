//
//  MLConfigurationTableViewController.h
//  MagicLights
//
//  Created by janakiraman gopinath on 6/1/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLLights.h"
@interface MLConfigurationTableViewController : UITableViewController <UIAlertViewDelegate>
@property (nonatomic, strong) MLLights *mlLights;
@end
