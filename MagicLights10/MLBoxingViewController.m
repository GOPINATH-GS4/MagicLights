//
//  MLBoxingViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/28/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLBoxingViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <Slt/Slt.h>
#import <OpenEars/FliteController.h>

#define RANGE_FACTOR 25

@interface MLBoxingViewController ()
@property (nonatomic, strong) Slt *slt;
@property (nonatomic, strong) FliteController *fliteController;
@property (weak, nonatomic) IBOutlet UILabel *punchStrength;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (atomic) BOOL speechInProgress;
@property (weak, nonatomic) IBOutlet UILabel *insult;
@property (strong, nonatomic) NSArray *insults;
@end


int brightness = 0;
@implementation MLBoxingViewController
@synthesize motionManager = _motionManager;
@synthesize slt = _slt;
@synthesize insults = _insults;

- (IBAction)retry:(id)sender {
    [self.mlLights random];
    [self.mlLights brightness:[NSNumber numberWithInt:50]];
  
}
// Lazily allocated slt voice.
- (Slt *)slt {
	if (_slt == nil) {
		_slt = [[Slt alloc] init];
	}
	return _slt;
}

// Lazily allocated FliteController.
- (FliteController *)fliteController {
	if (_fliteController == nil) {
		_fliteController = [[FliteController alloc] init];
        
	}
	return _fliteController;
}

- (NSArray *) insults {
    if (_insults == nil) {
        _insults = [[NSArray alloc] initWithObjects:
                        [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0], @"INDEX",
                                                                    @"A baby can kick better than this ...", @"INSULT", nil],
                        [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1], @"INDEX",
                                                                     @"You punch like a girl ...", @"INSULT", nil],
                        [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:2], @"INDEX",
                                                                    @"Not bad for a 50 year old ...", @"INSULT", nil],
                        [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:3], @"INDEX",
                                                                    @"My grandma can do better than this ...", @"INSULT", nil],
                        [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:4], @"INDEX",
                                                                    @"Is this all you got? ... Pathetic ... ", @"INSULT", nil],
                        [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:5], @"INDEX",
                                                                    @"Did you punch already? ... ", @"INSULT", nil],
                        [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:6], @"INDEX",
                                                                    @"Did you punch? or sneeze? ... ", @"INSULT", nil],
                        [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:7], @"INDEX",
                                                                    @"Finally ... , something is moving ... ", @"INSULT", nil],
                        [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:8], @"INDEX",
                                                                    @"Are you Mike Tyson? ... ", @"INSULT", nil], nil];

    }
    return _insults;
}
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
    [self startAccelerometer];
    [self.mlLights random];
    [self.mlLights brightness:[NSNumber numberWithInt:50]];
   
    self.punchStrength.text = @"0";
    // Do any additional setup after loading the view.
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.motionManager stopAccelerometerUpdates];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
- (void) processAccelerationData:(CMAcceleration) acceleration {


   
    if (self.speechInProgress == YES) {
        return;
    }
   
    int brightness = (ABS(acceleration.x) + ABS(acceleration.y)  + ABS(acceleration.z)) * 254 / 20;
 

    if (brightness < 50) {
        return;
    }
    if (brightness > 254) {
        brightness = 254;
    }
    int index = brightness / RANGE_FACTOR;
    
    index -= 2;
    NSLog(@"SpeechInProgress value @%@,Brightness %d, index %d", ((self.speechInProgress) ? @"YES": @"NO"), brightness, index);
    if (index <0 && index > 8) {
        return;
    } else {
        
       self.speechInProgress = YES;
       
        NSString *insult = [[self.insults objectAtIndex:index] valueForKey:@"INSULT"];
        if ([self.fliteController speechInProgress]) {
            [self.fliteController interruptTalking];
        }
        [self.fliteController say:insult withVoice:self.slt];
        self.speechInProgress = NO;
       
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


@end
