//
//  MLMusicViewController.h
//  MagicLights
//
//  Created by janakiraman gopinath on 5/28/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "MLLights.h"
@interface MLMusicViewController : UIViewController <MPMediaPickerControllerDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) MLLights *mlLights;
@end
