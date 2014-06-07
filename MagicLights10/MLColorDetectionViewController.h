//
//  MLColorDetectionViewController.h
//  MagicLights
//
//  Created by janakiraman gopinath on 5/31/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLLights.h"

@interface MLColorDetectionViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic,strong) MLLights *mlLights;
@end
