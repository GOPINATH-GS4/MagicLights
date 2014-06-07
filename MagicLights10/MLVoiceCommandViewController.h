//
//  MLVoiceCommandViewController.h
//  MagicLights
//
//  Created by janakiraman gopinath on 5/27/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/FliteController.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/OpenEarsLogging.h>
#import <OpenEars/AcousticModel.h>

#import <Slt/Slt.h>
#import "MLLights.h"

@interface MLVoiceCommandViewController : UIViewController <OpenEarsEventsObserverDelegate>
@property (nonatomic, strong) MLLights *mlLights;
@end
