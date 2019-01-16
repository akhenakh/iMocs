//
//  AppDelegate.m
//  iMocs
//
//  Created by akh on 2018-10-24.
//  Copyright © 2018 akh. All rights reserved.
//

#import "AppDelegate.h"
#import "TRVSEventSource.h"

@import NetworkExtension;
TRVSEventSource *eventSource;
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  
  
  return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
  // diable idle timer
  [UIApplication sharedApplication].idleTimerDisabled = YES;
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // connect to wifi
    [self connectToWiFI];
    
    TRVSEventSource *eventSource = [[TRVSEventSource alloc] initWithURL:[NSURL URLWithString:@"http://192.168.12.1:9403/sse"]];
    //eventSource.delegate = self;
    
    [eventSource addListenerForEvent:@"position" usingEventHandler:^(TRVSServerSentEvent *event, NSError *error) {
      if (error != nil) {
        NSLog(@"error SSE: %@", [error localizedDescription]);
      } else {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:event.data options:0 error:NULL];
        NSLog(@"%@", json);
      }
      }];
    
    [eventSource open];
  });
}

- (void) connectToWiFI {
  __block BOOL connected = NO;
  while (!connected) {
    NEHotspotConfiguration *configuration = [[NEHotspotConfiguration alloc] initWithSSID: @"mocs" passphrase:@"thisismocs" isWEP: NO];
    configuration.joinOnce = YES;
    [[NEHotspotConfigurationManager sharedManager] applyConfiguration: configuration completionHandler: ^ (NSError * _Nullable error) {
      if (error == nil) {
        NSLog (@"WIFI Is Connected!!");
        connected = YES;
        return;
      }
      if (error.code == NEHotspotConfigurationErrorAlreadyAssociated) {
        NSLog (@"WIFI was Connected!!");
        connected = YES;
        return;
      }
      NSLog (@"Error is: %@", error);
    }];
    [NSThread sleepForTimeInterval:0.5];
  }
}


- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
