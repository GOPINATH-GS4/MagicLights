//
//  MLMusicViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/28/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLMusicViewController.h"
#import  <AVFoundation/AVFoundation.h>


@interface MLMusicViewController ()

@property (weak, nonatomic) IBOutlet UIButton *selectMusic;
@property (weak, nonatomic) IBOutlet UISlider *seek;
@property (weak, nonatomic) IBOutlet UIImageView *musicView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSURL *url;
@property (weak, nonatomic) IBOutlet UIButton *play;
@property (nonatomic) BOOL playState;
@property (nonatomic) BOOL playing;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MLMusicViewController 
@synthesize audioPlayer = _audioPlayer;
@synthesize url = _url;
@synthesize playing = _playing;
@synthesize playState = _playState;

float mTable[801];
float MinDecibels;
float mScaleFactor;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.seek.minimumValue = 0;
    self.seek.value = 0.0;
    [self.seek setValue:0.0 animated:YES];
    [self.progressView setProgress:0 animated:YES];
    [self.seek setUserInteractionEnabled:NO];
       // Do any additional setup after loading the view.
}
- (void) viewWillDisappear:(BOOL)animated {
    //free(mTable);
    [self.audioPlayer stop];
    //[self.timer invalidate];
    [self.mlLights random];
    
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.play setHidden:YES];
    self.playing = self.playState = NO;
    [self makeMeterTable:-80  root:1.5];
    
    [self.mlLights random];
}
- (IBAction)seek:(UISlider *)sender {
    [self.audioPlayer stop];
    
    self.audioPlayer.currentTime = self.seek.value;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)selectMusic:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    [picker setDelegate:self];
    [picker setAllowsPickingMultipleItems: NO];
    [self presentViewController:picker animated:YES completion:NULL];
}
- (IBAction)play:(id)sender {
    
    if (self.playing) {
        [self.seek setUserInteractionEnabled:NO];
        self.playing = NO;
        [self.audioPlayer pause];
        [self.play setTitle:@"Play Song" forState:UIControlStateNormal];
    } else {
        
        self.playing = YES;
        if (self.playState) { // Logic to resume
         
           
            [self.play setTitle:@"Play Song" forState:UIControlStateNormal];
            self.seek.value = 0;
            self.seek.minimumValue = 0;
            self.progressView.progress = 0;
            
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
            [self.audioPlayer setMeteringEnabled:YES];
          
            self.audioPlayer.numberOfLoops = 0;
            self.audioPlayer.delegate = self;
          
            self.seek.maximumValue = self.audioPlayer.duration;
            self.playState = NO;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
        [self.seek setUserInteractionEnabled:YES];
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        [self.play setTitle:@"Pause Song" forState:UIControlStateNormal];
    }
   
}
float ValueAt(float inDecibels)
{
    if (inDecibels < MinDecibels) return  0.;
    if (inDecibels >= 0.) return 1.;
    int index = (int)(inDecibels * mScaleFactor);
    return mTable[index];
}
- (void)update
{
    float scale = 0.5;
    if (self.audioPlayer.playing )
    {
        // upate the UIProgress
        
        [self updateSliders];
        [self.audioPlayer updateMeters];
        
        float power = 0.0f;
        for (int i = 0; i < [self.audioPlayer numberOfChannels]; i++) {
            power += [self.audioPlayer averagePowerForChannel:i];
            
        }
        power /= [self.audioPlayer numberOfChannels];
        
        float level = ValueAt(power);
        scale = level * 5;
        NSLog(@"SCALE %f %f %f %f" , scale, power, level,[self printMeterTable]);
        int brightness = (int) (level * 254);
        if (brightness > 0 && brightness < 50) {
            brightness = 25;
        }
        else if (brightness > 50 && brightness < 100) {
            brightness = 75;
        }
        else if (brightness > 100 && brightness < 150) {
            brightness = 125;
        } else if (brightness > 150 && brightness < 200) {
            brightness = 175;
        }
        else if (brightness > 200)
            brightness = 225;
        
        [self.mlLights brightness:[NSNumber numberWithInt:brightness]];
    }
    
}
#pragma -- mark meterTable 
double DbToAmp(double inDb)
{
	return pow(10., 0.05 * inDb);
}
- (void) makeMeterTable:(float) minDecibels root:(float) root
{
    if (minDecibels >= 0.)
	{
		NSLog(@"Min Decibels cannot be positive");
		return;
	}
    MinDecibels = minDecibels;
    
    
	double minAmp = DbToAmp(minDecibels);
	double ampRange = 1. - minAmp;
	double invAmpRange = 1. / ampRange;
	float decibelResolution = minDecibels / (800 - 1);
    mScaleFactor = (1./decibelResolution);
    
	double rroot = 1. / root;
	for (size_t i = 0; i < 800; ++i) {
		double decibels = i * decibelResolution;
		double amp = DbToAmp(decibels);
		double adjAmp = (amp - minAmp) * invAmpRange;
		mTable[i] = pow(adjAmp, rroot);
	}

}
- (float) printMeterTable
{
    float sum = 0.0;
    for (int i = 0; i < 800; i++)
        sum += mTable[i];
    return sum;
}

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
    self.playState = YES;
    [self.play setHidden:NO];
    [self.play setTitle:@"Play Song" forState:UIControlStateNormal];
    self.seek.value = 0;
    self.seek.minimumValue = 0;
    self.progressView.progress = 0;
   
}
- (void) updateSliders {
    [self.seek setValue:self.audioPlayer.currentTime animated:YES];
    
    self.progressView.progress = self.audioPlayer.currentTime/self.audioPlayer.duration;
}
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
}
- (void) audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    
}
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.timer invalidate];
   
    self.playing  = NO;
    self.playState = YES;
    [self.play setTitle:@"Play Song" forState:UIControlStateNormal];
    self.seek.value = 0;
    self.seek.minimumValue = 0;
    self.progressView.progress = 0;

    
}

@end
