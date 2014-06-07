//
//  MLConfigurationTableViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 6/1/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLConfigurationTableViewController.h"

@interface MLConfigurationTableViewController ()
@property (nonatomic, strong) PHLight  *selectedLight;
@end

@implementation MLConfigurationTableViewController

@synthesize selectedLight  = _selectedLight;


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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.mlLights getNumberOfLights];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lightName" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"lightName"];
        
    }
    PHLight *light = [[self.mlLights.cache.lights allValues] objectAtIndex:indexPath.row];
   
    cell.textLabel.text = light.name;
   
    return cell;
}

- (BOOL) validateLightName:(NSString *) lightName {
    NSString *error;
    
    if (lightName == nil || [lightName isEqual:[NSNull null]] || [lightName isEqualToString:@""]) {
        error = @"Light name cannot be NULL";
       
    } else {
        for (int i = 0; i < [[self.mlLights.cache.lights allValues] count]; i++) {
            PHLight *light = [[self.mlLights.cache.lights allValues] objectAtIndex:i];
            if ([light.name isEqualToString:lightName]) {
                error = [NSString stringWithFormat:@"Light with a name %@ already exisits", lightName];
            }
        }
    }
    if (error != nil) {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Light Name" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorView show];
        return NO;
    }
    else return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alertView;
    self.selectedLight =  [[self.mlLights.cache.lights allValues] objectAtIndex:indexPath.row];
    if (self.selectedLight != nil) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Light Name" message:@"Key in a name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].text = self.selectedLight.name;
        [self.mlLights blinkLight:self.selectedLight blink:YES];
    }
    else {
        alertView = [[UIAlertView alloc] initWithTitle:@"Light Name" message:@"Invalid light selection" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        alertView.alertViewStyle = UIAlertViewStyleDefault;

    }
    [alertView show];
    

    
}
- (void) notifyBack {
    [self.tableView reloadData];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.mlLights blinkLight:self.selectedLight blink:NO];
        return;
    }
    else {
        NSString *lightName = [[alertView textFieldAtIndex:0] text];
        if ([self validateLightName:lightName]) {
            [self.mlLights renameLight:self.selectedLight withNewName:lightName notifySender:self];
         
        }
        [self.mlLights blinkLight:self.selectedLight blink:NO];
       
    }
}
@end
