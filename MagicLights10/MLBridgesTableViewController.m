//
//  MLBridgesTableViewController.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/17/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLBridgesTableViewController.h"
#import "MLMainMenuTableViewController.h"

@interface MLBridgesTableViewController ()

@property (nonatomic, strong) NSDictionary *bridges;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIAlertView *noBridgeFoundAlert;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refresh;

@end


@implementation MLBridgesTableViewController


@synthesize spinner = _spinner;
@synthesize bridges = _bridges;
@synthesize mlLights = _mlLights;


@synthesize noBridgeFoundAlert = _noBridgeFoundAlert;


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
    self.mlLights.connectionSource  = self;
    [self.spinner startAnimating];
    [self.mlLights searchForBridges];

   
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

    return self.bridges.count;
}


- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.center = CGPointMake(self.tableView.frame.size.width/2 , self.tableView.frame.size.height/2);
        _spinner.frame = CGRectMake(_spinner.frame.origin.x - 40, _spinner.frame.origin.y - 40, 80, 80);
        _spinner.backgroundColor = [UIColor whiteColor];
        _spinner.color = [UIColor redColor];
        [self.tableView addSubview:_spinner];
    }
    return _spinner;
}

- (IBAction)refresh:(id)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"ipaddress"];
    [userDefaults removeObjectForKey:@"bridges"];
    [userDefaults removeObjectForKey:@"date"];
    
    [userDefaults synchronize];
    
    [self.spinner startAnimating];
    [self.mlLights searchForBridges];
    
}
#pragma --mark connectsource delegates 
- (void) notFoundBridges {
    self.noBridgeFoundAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No bridges", @"No bridge found alert title")
                                                         message:NSLocalizedString(@"Could not find bridge", @"No bridge found alert message")
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"Retry", @"No bridge found alert retry button"),NSLocalizedString(@"Cancel", @"No bridge found alert cancel button"), nil];
    self.noBridgeFoundAlert.tag = 1;
    [self.noBridgeFoundAlert show];
}
- (void)foundBridges:(NSDictionary *)bridges {
    [self.spinner stopAnimating];
    self.bridges = bridges;
    [self.tableView reloadData];
}

#pragma mark - HueSDK

#pragma mark -- TableView DataSources and Delgates


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"bridge";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    cell.textLabel.text = [[self.bridges allKeys] objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.bridges valueForKey:cell.textLabel.text];
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [cell.accessoryView removeFromSuperview];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    CGRect frame = CGRectMake(0.0, 0.0, 60, 30);
    button.frame = frame;
    /* UIImage *image =  [UIImage imageNamed:@"connect.png"];
    [button setImage:image forState:UIControlStateNormal];
    */
   
    [button setTitle:@"Connect" forState:UIControlStateNormal];
    [button setUserInteractionEnabled:YES];
    button.tag = indexPath.row;
    cell.accessoryView = button;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
   [button addTarget:self action:@selector(checkButtonTapped:)  forControlEvents:UIControlEventTouchUpInside];
}
- (void) checkButtonTapped:(UIButton *) button  {
   
    NSString *mac = [[self.bridges allKeys] objectAtIndex:button.tag];
    NSString *ip = [self.bridges objectForKey:mac];
    MLMainMenuTableViewController *mainMenuViewController = [[self.navigationController viewControllers] objectAtIndex:0];
    
    
    [self.mlLights setBridgeToUseWithIpAddress:ip
                                    macAddress:mac];
    mainMenuViewController.mlLights = self.mlLights;
    
    mainMenuViewController.mlLights.currentIp = ip;
    mainMenuViewController.bridgeScanned = YES;
    [self.navigationController popToViewController:mainMenuViewController animated:YES];
}


@end
