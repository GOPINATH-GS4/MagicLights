//
//  MLVoiceCommandViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/27/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLVoiceCommandViewController.h"
#define kGetNbest 5

@interface MLVoiceCommandViewController ()
@property (nonatomic, strong) Slt *slt;
@property (nonatomic, strong) OpenEarsEventsObserver *openEarsEventsObserver; // A class whose delegate methods which will allow us to stay informed of changes in the Flite and Pocketsphinx statuses.
@property (nonatomic, strong) PocketsphinxController *pocketsphinxController; // The controller for Pocketsphinx (voice recognition).
@property (nonatomic, strong) FliteController *fliteController; // The controller for Flite (speech).
@property (nonatomic, strong) NSString *languageModelPath;
@property (nonatomic, strong) NSString *dictionaryPath;
@property (weak, nonatomic) IBOutlet UIButton *speakButton;
@property (nonatomic) BOOL listening;
@property (weak, nonatomic) IBOutlet UILabel *hypothesisLabel;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (strong, nonatomic) NSArray *effects;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation MLVoiceCommandViewController

@synthesize slt = _slt;
@synthesize openEarsEventsObserver = _openEarsEventsObserver;
@synthesize pocketsphinxController = _pocketsphinxController;
@synthesize fliteController = _fliteController;
@synthesize dictionaryPath = _dictionaryPath;
@synthesize languageModelPath = _languageModelPath;
@synthesize listening = _listening;
@synthesize hypothesisLabel = _hypothesisLabel;
@synthesize score = _score;
@synthesize mlLights = _mlLights;
@synthesize effects = _effects;
@synthesize statusLabel = _statusLabel;

#pragma mark -
#pragma mark Lazy Allocation
- (IBAction)speak:(UIButton *)sender {
    
    if (!self.listening) {
        [self.fliteController say:@"Voice recognition started ..." withVoice:self.slt];
        [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.languageModelPath dictionaryAtPath:self.dictionaryPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
        self.listening = YES;
        
    } else {
        [self.pocketsphinxController stopListening];
        self.listening = NO;
        [self.fliteController say:@"Voice recognition stopped" withVoice:self.slt];
    }
    
}

- (PocketsphinxController *)pocketsphinxController {
	if (_pocketsphinxController == nil) {
		_pocketsphinxController = [[PocketsphinxController alloc] init];
        //pocketsphinxController.verbosePocketSphinx = TRUE; // Uncomment me for verbose debug output
        _pocketsphinxController.outputAudio = TRUE;
#ifdef kGetNbest
        _pocketsphinxController.returnNbest = TRUE;
        _pocketsphinxController.nBestNumber = kGetNbest;
#endif
	}
	return _pocketsphinxController;
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

// Lazily allocated OpenEarsEventsObserver.
- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (_openEarsEventsObserver == nil) {
		_openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return _openEarsEventsObserver;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait;
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
   
    [self.openEarsEventsObserver setDelegate:self]; // Make this class the delegate of OpenEarsObserver so we can get all of the messages about what OpenEars is doing.
    self.listening = NO;
   
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    
    NSArray *spokenWords = [self capitalizeStringArray:(NSArray *) self.effects];
    

    NSString *name = @"effectsModel";
    NSError *err = [lmGenerator generateLanguageModelFromArray:spokenWords withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    
    NSDictionary *languageGeneratorResults = nil;
    
	
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
		
        self.languageModelPath = [languageGeneratorResults objectForKey:@"LMPath"];
        self.dictionaryPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
	
	
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.pocketsphinxController stopListening];
    self.speakButton.hidden = NO;
    self.listening = NO;
    [self.openEarsEventsObserver setDelegate:nil];
    [self.mlLights stopTimer];
    [self.mlLights colorEffect:EFFECT_NONE];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSArray *) capitalizeStringArray:(NSArray *) stringArray {
    NSMutableArray *capitalizedStringArray = [[NSMutableArray alloc] initWithCapacity:100];
    
    for (int i = 0; i < stringArray.count; i++) {
        [capitalizedStringArray addObject:[[stringArray objectAtIndex:i] uppercaseString]];
    }
    return capitalizedStringArray;
}
- (NSArray *) effects {
    if (_effects == nil) {
        _effects = [[NSArray alloc] initWithObjects:
                    @"Ocean",
                    @"Beach",
                    @"Volcano",
                    @"Desert",
                    @"Snow",
                    @"Mountain",
                    @"Cloudy",
                    @"Rain",
                    @"Lights On",
                    @"Lights Off",
                    @"Random",
                    @"Police",
                    @"Disco",
                    @"Color Loop",
                    @"Blink",
                    nil];
        
        
    }
    return _effects;
}
- (void) processCommand:(NSString *) command {
    
    int index = [self.effects indexOfObject:[command capitalizedString]];
    [self.mlLights colorEffect:EFFECT_NONE];
    [self.mlLights stopTimer];
    switch (index) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 14:
            [self.mlLights effects:[command capitalizedString]];
        case 8:
            [self.mlLights lightsOnOff:YES];
            break;
        case 9:
            [self.mlLights lightsOnOff:NO];
            break;
        case 10:
            [self.mlLights setupTimerEventWithTimerInterval:5 forEffect:[command capitalizedString]];
            break;
        case 11:
        case 12:
            [self.mlLights setupTimerEventWithTimerInterval:2 forEffect:[command capitalizedString]];
            break;
        case 13:
            [self.mlLights colorEffect:EFFECT_COLORLOOP];
            break;
        default:
            break;
    }
}
#pragma mark -- Deletegate for OpenEarsEventObserver
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    self.hypothesisLabel.text = hypothesis;
    self.score.text = recognitionScore;
    [self.pocketsphinxController stopListening];
    [self.fliteController say:[NSString stringWithFormat:@"You Said %@", hypothesis] withVoice:self.slt];
    
    [self processCommand:hypothesis];
    
    
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.languageModelPath dictionaryAtPath:self.dictionaryPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
    NSLog(@"Pocketsphinx calibration is complete."); // Log it.

    
	self.fliteController.duration_stretch = .9; // Change the speed
	self.fliteController.target_mean = 1.2; // Change the pitch
	self.fliteController.target_stddev = 1.5; // Change the variance
	
    // The same statement with the pitch and other voice values changed.
	
	self.fliteController.duration_stretch = 1.0; // Reset the speed
	self.fliteController.target_mean = 1.0; // Reset the pitch
	self.fliteController.target_stddev = 1.0; // Reset the variance
	NSLog(@"Pocketsphinx calibration is complete.");
   
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
    self.statusLabel.text = @"Listening...";
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
    self.speakButton.hidden = YES;
    self.statusLabel.text = @"Speech detected";
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
    self.speakButton.hidden = NO;
    self.statusLabel.text = @"Concluding utterance";
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
    self.statusLabel.text = @"Not Listening...";

}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}
- (void) audioInputDidBecomeAvailable {
	NSLog(@"The audio input is available"); // Log it.
	
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.languageModelPath dictionaryAtPath:self.dictionaryPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
}

// An optional delegate method of OpenEarsEventsObserver which informs that there was a change to the audio route (e.g. headphones were plugged in or unplugged).
- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
	NSLog(@"Audio route change. The new audio route is %@", newRoute); // Log it.
	   
	[self.pocketsphinxController stopListening]; // React to it by telling the Pocketsphinx loop to shut down and then start listening again on the new route
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.languageModelPath dictionaryAtPath:self.dictionaryPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
}

@end
