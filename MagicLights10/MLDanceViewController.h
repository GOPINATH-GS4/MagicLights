//
//  MLDanceViewController.h
//  MagicLights
//
//  Created by janakiraman gopinath on 5/29/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "MLLights.h"
@interface MLDanceViewController : UIViewController <MPMediaPickerControllerDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) MLLights *mlLights;
@end
