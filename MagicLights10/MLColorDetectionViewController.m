//
//  MLColorDetectionViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/31/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLColorDetectionViewController.h"
#define NUMBER_OF_BYTES_PER_PIXEL 4

#define REDHUE 65535
#define GREENHUE 25500
#define BLUEHUE 46920

#define SCALE_FACTOR .2
@interface MLColorDetectionViewController ()

@property (weak, nonatomic) IBOutlet UIButton *scan;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation MLColorDetectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)scan:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) processImage   {
    
    
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
}
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imageView.image = [info objectForKey:UIImagePickerControllerEditedImage];
   
    
    [self.mlLights threadwithName:@"ImageThread" usingCompletionBlock:^(void) {
        [self processImage];
        
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
