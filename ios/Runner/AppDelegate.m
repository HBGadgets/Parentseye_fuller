#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"
#import <workmanager/WorkmanagerPlugin.h>
#import <Firebase.h>
#import <UserNotifications/UserNotifications.h>
#import <Flutter/Flutter.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      [FIRApp configure];
    
    // Provide Google Maps API key
    [GMSServices provideAPIKey:@"AIzaSyAvHHoPKPwRFui0undeEUrz00-8w6qFtik"];
    
    // Register generated plugins
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    // Register WorkManager plugin task
    [WorkmanagerPlugin registerTaskWithIdentifier:@"resetRouteDetails"];
    
    // Set up notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [application registerForRemoteNotifications];
            });
        }
    }];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// APNs Token received from Apple
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Pass device token to Firebase
    [FIRMessaging messaging].APNSToken = deviceToken;
    
    // Convert token to string
    const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          tokenBytes[0], tokenBytes[1], tokenBytes[2], tokenBytes[3], tokenBytes[4], tokenBytes[5], tokenBytes[6], tokenBytes[7],
                          tokenBytes[8], tokenBytes[9], tokenBytes[10], tokenBytes[11], tokenBytes[12], tokenBytes[13], tokenBytes[14], tokenBytes[15]];
    
    NSLog(@"APNs Device Token: %@", hexToken);
}

// Handle error in registration for notifications
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote notifications: %@", error);
}

// Handle notification while the app is in foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
}

// Handle when a notification is tapped by the user and app is in background or closed
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    // Handle the notification response here
    completionHandler();
}

@end
