//
//  MLColorScannerViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 6/3/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLColorScannerViewController.h"
#define NUMBER_OF_BYTES_PER_PIXEL 4

#define REDHUE 65535
#define GREENHUE 25500
#define BLUEHUE 46920

#define SCALE_FACTOR .2

@interface MLColorScannerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *scan;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *frameOutput;
@property (nonatomic, strong) CIContext *context;
@end
BOOL scan = NO;

@implementation MLColorScannerViewController

@synthesize context = _context;

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
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset352x288;
    
    self.videoDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] firstObject]; //:AVMediaTypeVideo];
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
    
    self.frameOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.frameOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [self.session addInput:self.videoInput];
    [self.session addOutput:self.frameOutput];
    
    [self.frameOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [self.session startRunning];
    
    scan = NO;

}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}
- (void)viewDidUnload
{
    self.imageView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   

}
-(CIContext *)context {
    if (!_context) _context = [CIContext contextWithOptions:nil];
    return _context;
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef ob = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:ob];
    CIImage *result = ciImage;
    ;
    CGImageRef ref = [self.context createCGImage:result fromRect:ciImage.extent];
    self.imageView.image = [UIImage imageWithCGImage:ref scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(ref);
    
    if (!scan) {
        return;
    }
   
    
    CGSize size = [[self.imageView image] size];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerRow = size.width * NUMBER_OF_BYTES_PER_PIXEL;
    NSUInteger bitsPerComponent = 8;
    unsigned char *pixels = (unsigned char *) malloc(sizeof(unsigned char) * bytesPerRow * size.height);
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 size.width,
                                                 size.height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)size.width, (CGFloat)size.height), [[self.imageView image] CGImage]);
    CGContextRelease(context);
    
    CGFloat redTotal,blueTotal,greenTotal;
    
    redTotal = blueTotal = greenTotal = 0.0;
    
    for (int i = 0; i < size.height; i++) {
        for (int j = 0; j < size.width; j++) {
            
            CGFloat red   = (CGFloat)pixels[i * (int) trunc(size.width) + (j * NUMBER_OF_BYTES_PER_PIXEL) ] / 255.0f;
            CGFloat green = (CGFloat)pixels[i * (int) trunc(size.width) + (j * NUMBER_OF_BYTES_PER_PIXEL) + 1] / 255.0f;
            CGFloat blue  = (CGFloat)pixels[i * (int) trunc(size.width) + (j * NUMBER_OF_BYTES_PER_PIXEL) + 2] / 255.0f;
            
            redTotal += red;
            greenTotal += green;
            blueTotal  += blue;
            
        }
    }
    
    CGFloat blue2Red = redTotal / blueTotal;
    CGFloat green2Blue = blueTotal / greenTotal;
    CGFloat green2Red = greenTotal / redTotal;
    NSNumber *hue;
    
    /*
     Hue line
     
     RED----------GREEN----------BLUE----------RED
     0           25500          46920         65535
     */
    
    if (blue2Red > green2Blue) {
        if (blue2Red > green2Red) { // Blue to red is dominant color
            
            if (blue2Red < SCALE_FACTOR || blue2Red > 1.0) {
                blue2Red = 1.0;
            }
            hue = [NSNumber numberWithInt:(int)REDHUE * blue2Red];
        }
        else { // Green to red is dominant color
            if (green2Red < SCALE_FACTOR || green2Red > 1.0 ) {
                green2Red = 1.0;
            }
            hue = [NSNumber numberWithInt:(int)GREENHUE * green2Red];
        }
    } else if (green2Blue > green2Red) {
        if (green2Blue < SCALE_FACTOR || green2Blue > 1.0 ) { // Green to Blue is dominant color
            green2Blue = 1.0;
        }
        hue = [NSNumber numberWithInt:(int)BLUEHUE * green2Blue];
    } else {
        // Green to red is dominant color
        if (green2Red < SCALE_FACTOR || green2Red > 1.0) {
            green2Red = 1.0;
        }
        hue = [NSNumber numberWithInt:(int)GREENHUE * green2Red];
    }
    NSNumber *brightness = [NSNumber numberWithInt:254];
    NSNumber *saturation = [NSNumber numberWithInt:254];
    [self.mlLights setLightStateWithBrightness:(NSNumber *) brightness
                                    saturation:(NSNumber *) saturation
                                           hue:(NSNumber *) hue];
    free(pixels);
    scan = NO;
}

- (IBAction)scan:(UIButton *)sender {
    scan = YES;
}

@end
