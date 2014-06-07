//
//  MLDanceViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/29/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLDanceViewController.h"
#import <CoreMotion/CoreMotion.h>

#import  <AVFoundation/AVFoundation.h>

#define MOVEMENT_THRESHOLD 25

@interface MLDanceViewController ()
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (weak, nonatomic) IBOutlet UISlider *intensitySlider;
@property (weak, nonatomic) IBOutlet UILabel *intensityLabel;
@property (nonatomic) int intensity;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UISlider *seek;
@property (nonatomic, strong) NSURL *url;
@property (weak, nonatomic) IBOutlet UIImageView *musicView;
@property (weak, nonatomic) IBOutlet UIButton *selectMusic;
@property (nonatomic) BOOL playing;
@property (nonatomic) BOOL playState;
@property (weak, nonatomic) IBOutlet UIButton *playMusic;

@end



@implementation MLDanceViewController
@synthesize motionManager = _motionManager;
@synthesize intensity = _intensity;
@synthesize audioPlayer = _audioPlayer;

@synthesize url = _url;

- (IBAction)play:(id)sender {
    if (self.playing) {
        self.playing = NO;
        [self.audioPlayer pause];
        [self.playMusic setTitle:@"Play Song" forState:UIControlStateNormal];
    } else {
        self.playing = YES;
        if (self.playState) { // Logic to resume
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
            self.audioPlayer.numberOfLoops = 0;
            
            [self.audioPlayer setMeteringEnabled:YES];
            self.playState = NO;
            self.audioPlayer.delegate = self;
            self.seek.value = 0;
            self.seek.minimumValue = 0;
            self.seek.maximumValue = self.audioPlayer.duration;
        }
        
        [self.audioPlayer play];
        [self.playMusic setTitle:@"Pause Song" forState:UIControlStateNormal];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)selectMusic:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    [picker setDelegate:self];
    [picker setAllowsPickingMultipleItems: NO];
    [self presentViewController:picker animated:YES completion:NULL];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.seek.value = 0.0;
    [self.seek setUserInteractionEnabled:NO];
    [self.playMusic setHidden:YES];
    // Do any additional setup after loading the view.
}

- (IBAction)intensity:(UISlider *)sender {
   
    
    if (sender.value > 20 && sender.value < 40) {
        self.intensityLabel.text = @"LOW";
    } else if (sender.value > 40 && sender.value < 70) {
        self.intensityLabel.text = @"MEDIUM";
    } else if (sender.value > 70) {
        self.intensityLabel.text = @"HIGH";
    }
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.motionManager stopAccelerometerUpdates];
    [self.audioPlayer stop];
    [self.mlLights random];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.motionManager = nil;
    [self startAccelerometer];
    [self.mlLights random];
    self.intensity = 0;
    self.playing = self.playState = NO;

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) processAccelerationData:(CMAcceleration) acceleration {
 
    int intensity = (ABS(acceleration.x) + ABS(acceleration.y) + ABS(acceleration.z)) * 254 / 20;
    if (intensity > 254) {
        intensity = 254;
    }
    if (ABS(self.intensity - intensity) > (int) self.intensitySlider.value ) {
        [self.mlLights random];
        self.intensity = intensity;
    }
    if (self.audioPlayer != nil) {
        self.seek.value = self.audioPlayer.currentTime;
    }
   
}
- (IBAction)seek:(UISlider *)sender {
    if (self.audioPlayer != nil) {
        self.audioPlayer.currentTime = self.seek.value;
    }
}
- (void) startAccelerometer {
    
    if (self.motionManager == nil) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = .1;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                     [self processAccelerationData:accelerometerData.acceleration];
                                                     if(error){
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
    }}

#pragma -- mark Music Picker Delegate 
#pragma mark - Media Picker Delegate


- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    // remove the media picker screen
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // grab the first selection (media picker is capable of returning more than one selected item,
    // but this app only deals with one song at a time)
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:0];
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    UIImage *image = [[item valueForProperty:MPMediaItemPropertyArtwork]
                      imageWithSize:self.musicView.bounds.size ];
    self.url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    [self.navigationItem setTitle:title];
    [self.musicView setImage:image];
    [self.playMusic setHidden:NO];
    [self.seek setUserInteractionEnabled:YES];
    self.playState = YES;
    
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.playing  = NO;
    self.playState = YES;
    [self.playMusic setTitle:@"Play Song" forState:UIControlStateNormal];
    self.seek.value = 0;
    self.seek.minimumValue = 0;
    
}

@end
