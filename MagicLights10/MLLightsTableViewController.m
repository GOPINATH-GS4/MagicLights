//
//  MLLightsTableViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/18/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLLightsTableViewController.h"

@interface MLLightsTableViewController ()
@property (nonatomic, strong) UIAlertView *linkAlert;

@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) NSMutableArray *sliders;
@end

@implementation MLLightsTableViewController

@synthesize linkAlert = _linkAlert;
@synthesize labels = _labels;
@synthesize sliders = _sliders;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sliders = nil;
    self.labels = nil;
    
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *) labels {
    
    if (_labels == nil) {
        _labels = [[NSMutableArray alloc] initWithCapacity:100];
    }
    return _labels;
}

- (NSMutableArray *) sliders {
    
    if (_sliders == nil) {
        _sliders = [[NSMutableArray alloc] initWithCapacity:100];
    }
    return _sliders;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"HUE";
        case 1:
            return @"BRIGHTNESS";
        case 2:
            return @"SATURATION";
            
        default:
            break;
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.mlLights getNumberOfLights];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"lights";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *views = [cell.contentView subviews];
    
    int HBS = (int) ((indexPath.section * [self.mlLights getNumberOfLights]) + indexPath.row);
    for (int i = 0; i < [views count]; i++) {
        if ([[views objectAtIndex:i] isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)[views objectAtIndex:i];
            
            if ([label.restorationIdentifier isEqualToString:@"name"]) {
                PHLight *light = [[self.mlLights.cache.lights allValues] objectAtIndex:indexPath.row];
                
                label.text = light.name;
            } else if ([label.restorationIdentifier isEqualToString:@"value"]) {
                label.tag = HBS;
                
                if (HBS >= [self.labels count]) {
                    [self.labels setObject:@"" atIndexedSubscript:HBS];
                }
                
                label.text = [self.labels objectAtIndex:HBS];
                
            }
            
        }
        else if ([[views objectAtIndex:i] isKindOfClass:[UISlider class]]) {
            UISlider *slider =(UISlider *)[views objectAtIndex:i];
            slider.enabled = YES;
            slider.multipleTouchEnabled = NO;
            slider.tag = HBS;
            
            if (HBS >= [self.sliders count]) {
                NSNumber *value;
                if (indexPath.section == 0) {
                    value = [NSNumber numberWithInt:25000];
                } else {
                    value = [NSNumber numberWithInt:128];

                }
                [self.sliders setObject:value atIndexedSubscript:HBS];
            }
            
           
            
            switch (indexPath.section) {
                case 0:
                    slider.tag = 100 + indexPath.row;
                    slider.minimumValue = 0;
                    slider.maximumValue = 65535;
                   
                    break;
                case 1:
                    slider.tag = 200 + indexPath.row;
                    slider.minimumValue = 0;
                    slider.maximumValue = 254;
                   
                    break;
                case 2:
                    slider.tag = 300 + indexPath.row;
                    slider.minimumValue = 0;
                    slider.maximumValue = 254;
                    
                    break;
                default:
                    break;
            }
            [slider setValue:((NSNumber *)[self.sliders objectAtIndex:HBS]).intValue animated:YES];
            [slider addTarget:self action:@selector(hueSelect:) forControlEvents:UIControlEventValueChanged];
            
        }
    }
}
- (void) hueSelect:(UISlider *) slider
{
    int HBS = (slider.tag >= 300) ? 2:(slider.tag >= 200) ? 1:0;
    NSNumber *hue, *brightness, *saturation;
    int lightId;
 
    switch (HBS) {
        case 0:
            lightId = (slider.tag) % 100;
            hue = [NSNumber numberWithInt:slider.value];
            break;
        case 1:
            lightId = (slider.tag % 200);
            brightness = [NSNumber numberWithInt:slider.value];
            break;
        case 2:
            lightId = (slider.tag % 300);
            saturation = [NSNumber numberWithInt:slider.value];
            break;
        default:
            break;
    }
    
    PHLight *light = [[self.mlLights.cache.lights allValues] objectAtIndex:lightId];
   
    
    [self.mlLights setLightStateWithBrightness:brightness
                                    saturation:saturation
                                           hue:hue
                                      forLight:light];
    int labelIndex = lightId + (HBS * [self.mlLights getNumberOfLights]);
    [self.sliders setObject:[NSNumber numberWithInt:slider.value] atIndexedSubscript:labelIndex];
    [self.labels setObject:[NSString stringWithFormat:@"%d", (int) slider.value] atIndexedSubscript:labelIndex];
    [self.tableView reloadData];
   /* ((UISlider *)[self.sliders objectAtIndex:labelIndex]).value = slider.value;
    ((UILabel *)[self.labels objectAtIndex:labelIndex]).text = [NSString stringWithFormat:@"%d", (int) slider.value];
    */
}

@end
