//
//  MLLights.h
//  MagicLights
//
//  Created by janakiraman gopinath on 5/24/14.
//  Copyright (c) 2014 gopi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HueSDK_iOS/HueSDK.h>


@protocol MLConnectionStatus
@optional
- (void) localConnection;
- (void) notAuthenticated;
- (void) noLocalConnection;
- (void) foundBridges:(NSDictionary *) bridges;
- (void) notFoundBridges;
@end

@interface MLLights : NSObject

@property (strong, nonatomic) PHHueSDK *phHueSDK;
@property (nonatomic, strong) PHNotificationManager *notificationManager;
@property (nonatomic, strong) id <MLConnectionStatus> connectionSource;
@property (nonatomic, strong) NSDictionary *bridges;
@property (nonatomic, strong) PHBridgeResourcesCache *cache;
@property (nonatomic) int currentBridgeIndex;
@property (nonatomic, strong) NSString *currentIp;


- (void) searchForBridges;
- (void) startupPhHUE;
- (void) initPhHUE;
- (int)  getNumberOfLights;
- (void) setLightStateWithBrightness:(NSNumber *) brightness
                          saturation:(NSNumber *) saturation
                                 hue:(NSNumber *) hue
                            forLight:(PHLight *) light;
- (void) setLightStateWithBrightness:(NSNumber *) brightness
                          saturation:(NSNumber *) saturation
                                 hue:(NSNumber *) hue;
- (void) renameLight:(PHLight *) light withNewName:(NSString *) name notifySender:(id) sender;

- (void) blinkLight:(PHLight *) light blink:(BOOL) blink;

- (void) threadwithName:(NSString *) queueName usingCompletionBlock:(void (^)())block;

- (void) effects:(NSString *) effect;
- (void) timedEffects:(NSString *) effect
      withEffectBlock:(NSNumber * (^)()) block;

- (void) setupTimerEventWithTimerInterval:(int) interval
                                forEffect:(NSString *) effect;
- (void) stopTimer;

- (void) setBridgeToUseWithIpAddress:(NSString *) ip
                          macAddress:(NSString *)mac;
- (void) brightness:(NSNumber *) brightness;

- (void) random;
- (void) police;
- (void) disco;
- (void) colorEffect:(PHLightEffectMode) effect;

- (void) lightsOnOff:(BOOL) onOff; // ALl lights OFF
- (void) lightOnOff:(BOOL) onOff forLight:(PHLight *) light; // All Lights On

- (void) enableLocalHeartbeat:(int) interval;
- (void) disableLocalHeartbeat;
- (void) removeNotifications:(id) sender;
@end
