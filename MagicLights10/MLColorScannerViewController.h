//
//  MLColorScannerViewController.h
//  MagicLights
//
//  Created by janakiraman gopinath on 6/3/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MLLights.h"
@interface MLColorScannerViewController : UIViewController  <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic,strong) MLLights *mlLights;

@end
