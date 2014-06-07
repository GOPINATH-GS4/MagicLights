//
//  MLEffectsTableViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/22/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLEffectsTableViewController.h"


@interface MLEffectsTableViewController ()
@property (weak, nonatomic) IBOutlet UIStepper *randomStepper;


@property (weak, nonatomic) IBOutlet UILabel *randomLabel;
@property (weak, nonatomic) IBOutlet UILabel *policeLabel;
@property (weak, nonatomic) IBOutlet UILabel *discoLabel;
@property (weak, nonatomic) IBOutlet UIStepper *discoStepper;
@property (weak, nonatomic) IBOutlet UIStepper *policeStepper;
@property (weak, nonatomic) IBOutlet UISwitch *onOff;


@end

@implementation MLEffectsTableViewController

@synthesize mlLights = _mlLights;

- (IBAction)randomStepperAction:(UIStepper *)sender {
    [self.mlLights setupTimerEventWithTimerInterval:(int) sender.value
                forEffect:@"Random"];
}
- (IBAction)policeStepper:(UIStepper *)sender {
    [self.mlLights setupTimerEventWithTimerInterval:(int) sender.value
                                          forEffect:@"Police"];
}
- (IBAction)discoStepper:(UIStepper *)sender {
    [self.mlLights setupTimerEventWithTimerInterval:(int) sender.value
                                          forEffect:@"Disco"];
}


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
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.mlLights stopTimer];
    [self.mlLights colorEffect:EFFECT_NONE];
    [self.mlLights lightsOnOff:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onOff:(id)sender {
    [self.mlLights lightsOnOff:self.onOff.on];
}
#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.mlLights stopTimer];
    NSString *effect;
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 9) {
                [self.mlLights lightsOnOff:self.onOff.on];
            }
            else {
                effect = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                [self.mlLights effects:effect];
            }
            break;
        case 1:
            effect = [self getRestorationIdForCell:[self.tableView cellForRowAtIndexPath:indexPath]
                                       inIndexPath:indexPath];
            switch (indexPath.row) {
                case 0:
                    [self.mlLights setupTimerEventWithTimerInterval:(int) self.randomStepper.value
                                                          forEffect:@"Random"];
                    self.randomLabel.text = [NSString stringWithFormat:@"%d", (int) self.randomStepper.value];

                    break;
                case 1:
                    [self.mlLights setupTimerEventWithTimerInterval:(int) self.policeStepper.value
                                                          forEffect:@"Police"];
                    self.policeLabel.text = [NSString stringWithFormat:@"%d", (int) self.policeStepper.value];

                    break;
                case 2:
                    [self.mlLights setupTimerEventWithTimerInterval:(int) self.discoStepper.value
                                                          forEffect:@"Disco"];
                    self.discoLabel.text = [NSString stringWithFormat:@"%d", (int) self.discoStepper.value];
                    break;
                case 3:
                    [self.mlLights colorEffect:EFFECT_COLORLOOP];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (NSString *) getRestorationIdForCell:(UITableViewCell *) cell inIndexPath:(NSIndexPath *) indexPath {
    for (id object in [cell.contentView subviews] ) {
        if ([object isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *) object;
            NSLog(@"%@,%d" , label.restorationIdentifier, (int) indexPath.row);
            if ([label.restorationIdentifier isEqualToString:[NSString stringWithFormat:@"%d", (int) indexPath.row]]) {
                return label.text;
            }
        }
    }
    return nil;
}

@end
