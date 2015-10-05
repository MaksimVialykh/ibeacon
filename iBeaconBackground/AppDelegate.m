//
//  AppDelegate.m
//  iBeaconBackground
//
//  Created by Maksim Vialykh on 05.10.15.
//  Copyright © 2015 NEKLO. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate () <CLLocationManagerDelegate>

@end

@implementation AppDelegate {
    CLLocationManager *_locationManger;
}


#pragma mark - CLLocationManagerDelegate
#pragma mark - Region state

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLBeaconRegion *)region {
    [self showNotificationForRegion:region withState:CLRegionStateInside];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLBeaconRegion *)region {
    [self showNotificationForRegion:region withState:CLRegionStateOutside];
}

#pragma mark - Manager state

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"locationManager:%@ didChangeAuthorizationStatus:%d", manager, status);
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self startMonitoring];
    }
}


#pragma mark - Work
#pragma marl - Location

- (void)requestLocationPermissonsAndStartMonitoring {
    NSString *locationAlwaysUsageDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"];
    
    NSAssert(locationAlwaysUsageDescription.length > 0, @"***BeaconSmartStore***\nBSSLocationManager Add NSLocationAlwaysUsageDescription value to info.plist file");
    
    if ([_locationManger respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self startMonitoring];
        } else {
            [_locationManger requestAlwaysAuthorization];
        }
    } else {
        [self startMonitoring];
    }
}

- (void)startMonitoring {
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"]
                                                                     major:50395
                                                                     minor:10623
                                                                identifier:@"75724970696f"];
    [_locationManger startMonitoringForRegion:region];
}

- (void)stopMonitoring {
    NSArray *regions = [_locationManger.monitoredRegions copy];
    [regions enumerateObjectsUsingBlock:^(__kindof CLRegion * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_locationManger stopMonitoringForRegion:obj];
    }];
}

#pragma mark - Notifications

- (void)requestNotificationPermissions {
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 8) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                             | UIUserNotificationTypeSound
                                                                                             | UIUserNotificationTypeAlert)
                                                                                 categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

- (void)showNotificationForRegion:(CLBeaconRegion *)region withState:(CLRegionState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        UILocalNotification *notification = [UILocalNotification new];
        
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.fireDate = [NSDate date];
        notification.alertAction = NSLocalizedString(@"powered by NEKLO", nil);
        notification.alertBody = [NSString stringWithFormat:@"%@_%@_%@ has state: %@",
                                  region.proximityUUID.UUIDString,
                                  region.major,
                                  region.minor,
                                  state == CLRegionStateInside ? @"inside" : @"outside"];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.userInfo = @{@"state": @(state),
                                  @"regionID": region.identifier};
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    });
}


#pragma mark - UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _locationManger = [CLLocationManager new];
    _locationManger.delegate = self;
    [self requestLocationPermissonsAndStartMonitoring];
    [self requestNotificationPermissions];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
