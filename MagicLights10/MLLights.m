//
//  MLLights.m
//  MagicLights
//
//  Created by janakiraman gopinath on 5/24/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import "MLLights.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface MLLights ()
@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;
@property (nonatomic, strong) NSDictionary *effectsDictionary;
@property (nonatomic, strong) NSTimer *timer;
@end
static int policeEffectIndex = 0;

@implementation MLLights
@synthesize phHueSDK = _phHueSDK;
@synthesize notificationManager = _notificationManager;
@synthesize cache = _cache;
@synthesize bridgeSearch =_bridgeSearch;
@synthesize currentBridgeIndex = _currentBridgeIndex;
@synthesize currentIp = _currentIp;
@synthesize effectsDictionary = _effectsDictionary;
@synthesize timer = _timer;

- (void) initPhHUE {
    [self.phHueSDK startUpSDK];
    [self.phHueSDK enableLogging:YES];
}

- (PHHueSDK *) phHueSDK {
    if (_phHueSDK == nil) {
        _phHueSDK = [[PHHueSDK alloc] init];
    }
    return _phHueSDK;
}

- (NSDictionary *) effectsDictionary {
    
    if (_effectsDictionary == nil) {
        _effectsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:254], @"saturation",
                          [NSNumber numberWithInt:254], @"brightness",
                          [NSNumber numberWithInt:21900],@"hue", nil],
                          @"Beach" ,
                         
                         [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:254], @"saturation",
                          [NSNumber numberWithInt:254], @"brightness",
                          [NSNumber numberWithInt:51900],@"hue", nil],
                         @"Volcano",
                         
                         [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:254], @"saturation",
                          [NSNumber numberWithInt:254], @"brightness",
                          [NSNumber numberWithInt:9420],@"hue", nil],
                         @"Desert",
                         
                         [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:254], @"saturation",
                          [NSNumber numberWithInt:254], @"brightness",
                          [NSNumber numberWithInt:46000],@"hue", nil],
                         @"Ocean",
                         
                         [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:254], @"saturation",
                          [NSNumber numberWithInt:254], @"brightness",
                          [NSNumber numberWithInt:32000],@"hue", nil],
                         @"Snow",
                         
                         [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:254], @"saturation",
                          [NSNumber numberWithInt:254], @"brightness",
                          [NSNumber numberWithInt:27000],@"hue", nil],
                         @"Mountain",
                         
                         [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:0], @"saturation",
                          [NSNumber numberWithInt:50], @"brightness",
                          [NSNumber numberWithInt:26000],@"hue", nil],
                         @"Cloudy",
                         
                         [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:132], @"saturation",
                          [NSNumber numberWithInt:93], @"brightness",
                          [NSNumber numberWithInt:40140],@"hue", nil],
                         @"Rain",
                        [[NSDictionary alloc] initWithObjectsAndKeys:
                         nil, @"saturation",
                         nil, @"brightness",
                         nil,@"hue", nil],
                        @"Blink",

                         nil];
    }
    return _effectsDictionary;
}

- (void) startupPhHUE
{
    
    if (self.phHueSDK != nil ) {
        
        self.notificationManager = [PHNotificationManager defaultManager];
        
        /*
         The SDK will send the following notifications in response to events:
         
         - LOCAL_CONNECTION_NOTIFICATION
         This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
         
         - NO_LOCAL_CONNECTION_NOTIFICATION
         This notification will notify that there is no connection with the bridge
         
         - NO_LOCAL_AUTHENTICATION_NOTIFICATION
         This notification will notify that there is no authentication against the bridge
         */
        
        [self.notificationManager registerObject:self withSelector:@selector(connected) forNotification:LOCAL_CONNECTION_NOTIFICATION];
        [self.notificationManager registerObject:self withSelector:@selector(notConnected) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
        [self.notificationManager registerObject:self withSelector:@selector(failedAuthentication) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
    
    }

}
- (void) effects:(NSString *) effect {
    
   
    NSNumber *brightness = [[self.effectsDictionary objectForKey:effect] objectForKey:@"brightness"];
    NSNumber *saturation = [[self.effectsDictionary objectForKey:effect] objectForKey:@"saturation"];
    NSNumber *hue = [[self.effectsDictionary objectForKey:effect] objectForKey:@"hue"];
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    for (PHLight *light in self.cache.lights.allValues) {
        
        if ([effect isEqualToString:@"Blink"]) {
            [self blinkLight:light blink:YES];
        }
        else {
            [self blinkLight:light blink:NO];
            [self setLightStateWithBrightness:brightness
                                        saturation:saturation
                                               hue:hue
                                          forLight:light];
        
        }
    }
    
}
- (void) police {
    switch (policeEffectIndex) {
        case 0:
            [self effects:@"Volcano"];
            break;
        case 1:
            [self effects:@"Ocean"];
            break;
        case 2:
            [self effects:@"Snow"];
            break;
            
        default:
            break;
    }
    policeEffectIndex++;
    if (policeEffectIndex >=3) {
        policeEffectIndex = 0;
    }
}
- (void) random {
    NSNumber *brightness = [NSNumber numberWithInt:254] ;
    NSNumber *saturation = [NSNumber numberWithInt:254] ;
    NSNumber *hue;
    for (PHLight *light in self.cache.lights.allValues) {
        NSString *randomSelection = [[self.effectsDictionary allKeys] objectAtIndex:(arc4random() % 6)];
        NSDictionary *randomDictionary = [self.effectsDictionary objectForKey:randomSelection];
        
        hue = [randomDictionary objectForKey:@"hue"];
        [self setLightStateWithBrightness:brightness
                               saturation:saturation
                                      hue:hue
                                 forLight:light];
    }
}
- (void) disco {
    [self random];
}
- (void) brightness:(NSNumber *) brightness {
    
    NSNumber *hue, *saturation;
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    for (PHLight *light in self.cache.lights.allValues) {
        
        [self setLightStateWithBrightness:brightness
                               saturation:saturation
                                      hue:hue
                                 forLight:light];
    }
    
}
- (void) timedEffects:(NSString *) effect withEffectBlock:(NSNumber * (^)()) block {
    
    NSNumber *brightness = [NSNumber numberWithInt:254];
    NSNumber *saturation = [NSNumber numberWithInt:254];
    NSNumber *hue;
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    BOOL semaphore = YES;
    
    for (PHLight *light in self.cache.lights.allValues) {
        
        
        if ([effect isEqualToString:@"random"] || [effect isEqualToString:@"disco"]) {
            hue = block();
        }
        else if ([effect isEqualToString:@"police"] && semaphore) {
            hue = block();
            semaphore = NO;
        }
        else if ([effect isEqualToString:@"disco"]) {
            
        }
        [self setLightStateWithBrightness:brightness
                                        saturation:saturation
                                               hue:hue
                                          forLight:light];
    }
    
    
}

- (void) connected {
    [self.connectionSource localConnection];
}
- (void) notConnected {
    [self.connectionSource noLocalConnection];
    
}
- (void) failedAuthentication {
    [self.connectionSource notAuthenticated];
}
/**
 Starts the local heartbeat with a 10 second interval
 */
- (void)enableLocalHeartbeat:(int) interval {
    /***************************************************
     The heartbeat processing collects data from the bridge
     so now try to see if we have a bridge already connected
     *****************************************************/
    
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    if (self.cache != nil && self.cache.bridgeConfiguration != nil && self.cache.bridgeConfiguration.ipaddress != nil) {
        [self.phHueSDK enableLocalConnectionUsingInterval:interval];
    }
    
}

- (void) removeNotifications:(id) sender{
    [[NSNotificationCenter defaultCenter] removeObserver:sender];
}
/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat {
    [self.phHueSDK disableLocalConnection];
    
}


- (void)searchForBridges {
    // Stop heartbeats
    
    
    // Show search screen
    NSLog(@"Searching.....");
    /***************************************************
     A bridge search is started using UPnP to find local bridges
     *****************************************************/
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *ipaddress = [userDefaults objectForKey:@"ipaddress"];
    NSInteger minutes = [self compareDates:[userDefaults objectForKey:@"date"]];
    
    if (ipaddress == nil || ![ipaddress isEqualToString:[self getIPAddress]] ||
            minutes > (3 * 60) ) {
       
    // Start search
        self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:YES];
        [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        // Done with search, remove loading view
        
        /***************************************************
         The search is complete, check whether we found a bridge
         *****************************************************/
        
        // Check for results
            if (bridgesFound.count > 0) {
            
            // Results were found, show options to user (from a user point of view, you should select automatically when there is only one bridge found)
            
            
                NSLog(@"BRIDGES VALUE %@", bridgesFound);
                self.bridges = bridgesFound;
            
            /***************************************************
             Use the list of bridges, present them to the user, so one can be selected.
             *****************************************************/
                [self.connectionSource foundBridges:self.bridges];
                [userDefaults setObject:self.bridges forKey:@"bridges"];
                [userDefaults setObject:[self getIPAddress] forKey:@"ipaddress"];
                [userDefaults setObject:[NSDate date] forKey:@"date"];
                NSDate *date = [NSDate date];
                NSLog(@"Date %@", date);
                
                [userDefaults synchronize];
            
            }
            else {
            /***************************************************
             No bridge was found was found. Tell the user and offer to retry..
             *****************************************************/
            
            // No bridges were found, show this to the user
                [self.connectionSource notFoundBridges];
            
            }
        }];
    }
    else {
        self.bridges = [userDefaults objectForKey:@"bridges"];
        [self.connectionSource foundBridges:self.bridges];
    }
   
}
- (int) getNumberOfLights {
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    return  (int) [[[self.cache lights] allKeys] count];

}
- (void) threadwithName:(NSString *) queueName usingCompletionBlock:(void (^)())block {
    dispatch_async(dispatch_get_main_queue(), block);
}

- (void) setBridgeToUseWithIpAddress:(NSString *) ip
                          macAddress:(NSString *)mac {
    
    [self.phHueSDK setBridgeToUseWithIpAddress:ip
                                    macAddress:mac];
    [self enableLocalHeartbeat:10];
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    self.currentIp = ip;
    
    if ([[self.bridges allKeys] containsObject:mac]) {
        for (int i = 0; i < [[self.bridges allKeys] count]; i++) {
            if ([[[self.bridges allKeys] objectAtIndex:i] isEqualToString:mac]) {
                self.currentBridgeIndex = i;
                break;
            }
        }
    }
    
}
- (void) setLightStateWithBrightness:(NSNumber *) brightness
                          saturation:(NSNumber *) saturation
                                 hue:(NSNumber *) hue {
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    for (PHLight *light in self.cache.lights.allValues) {
        
        [self setLightStateWithBrightness:brightness
                               saturation:saturation
                                      hue:hue
                                 forLight:light];
    }

}
- (void) blinkLight:(PHLight *) light blink:(BOOL) blink {
    PHLightState *blinkState = [[PHLightState alloc] init];
    blinkState.alert = (blink) ? ALERT_LSELECT:ALERT_NONE;
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    [bridgeSendAPI updateLightStateForId:light.identifier withLighState:blinkState completionHandler:^(NSArray *errors) {
        // Check for errors
        if (errors != nil) {
            NSLog(@"Error blinking Lights ... ");
        }
        
    }];

}
- (void) renameLight:(PHLight *) light withNewName:(NSString *) name notifySender:(id)sender {
   
    light.name = name;
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    [bridgeSendAPI updateLightWithLight:light completionHandler:^(NSArray *errors) {
        
        if (errors != nil) {
            NSLog(@"Error %@", errors);
        } {
            
            SEL selector = NSSelectorFromString(@"notifyBack");
            IMP imp = [sender methodForSelector:selector];
            
            if ([sender respondsToSelector:selector]) {
                void (*func)(id, SEL) = (void *)imp;
                func(sender, selector);
            }
        }
    }];
}
- (void) lightsOnOff:(BOOL) onOff {
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    for (PHLight *light in self.cache.lights.allValues) {
        
        [self lightOnOff:onOff forLight:light];
    }
}
- (void) lightOnOff:(BOOL) onOff forLight:(PHLight *) light {
    PHLightState *lightState = [[PHLightState alloc] init];
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    [lightState setOnBool:onOff];
    [bridgeSendAPI updateLightStateForId:light.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
        if (errors != nil) {
            NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
            
            NSLog(@"Response: %@",message);
        }
        
    }];

}
- (void) timedEffects:(NSTimer *) timer {
    
    if ([timer.userInfo isEqualToString:@"Random"]) {
        [self random];
    } else if ([timer.userInfo isEqualToString:@"Police"]) {
        [self police];
    } else if ([timer.userInfo isEqualToString:@"Disco"]) {
        [self disco];
    }
    
}
- (void) setupTimerEventWithTimerInterval:(int) interval
               forEffect:(NSString *) effect{
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:interval
                                         target:self selector:@selector(timedEffects:)
                                       userInfo:effect
                                        repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}
- (void) stopTimer {
    [self.timer invalidate];
}

- (void) colorEffect:(PHLightEffectMode) effect
{
    self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    PHLightState *lightState = [[PHLightState alloc] init];
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];

    
    for (PHLight *light in self.cache.lights.allValues) {
    
        lightState.effect = effect;
        [bridgeSendAPI updateLightStateForId:light.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
        }];
    }
}
-(void) setLightStateWithBrightness:(NSNumber *) brightness
                         saturation:(NSNumber *) saturation
                                hue:(NSNumber *) hue
                           forLight:(PHLight *) light {
    
    
    [self threadwithName:light.identifier usingCompletionBlock:^(void) {
        PHLightState *lightState = [[PHLightState alloc] init];
       id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
        
        [lightState setEffect:EFFECT_NONE];
        
        [lightState setBrightness:brightness];
        [lightState setSaturation:saturation];
        [lightState setHue:hue];
        [bridgeSendAPI updateLightStateForId:light.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            } else {
                self.cache = [PHBridgeResourcesReader readBridgeResourcesCache];
            }
            
        }];
    }];
    
}
#pragma --mark utility functions

- (NSInteger) compareDates:(NSDate *)date
{
    NSDate *date1 = date;
    NSDate *date2 = [NSDate date];
    NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
    double secondsInMinute = 60;
    NSInteger differenceInMinutes = distanceBetweenDates / secondsInMinute ;
    
    return differenceInMinutes;
}

// Get IP Address
- (NSString *)  getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

@end