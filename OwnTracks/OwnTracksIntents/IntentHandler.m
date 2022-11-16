//
//  IntentHandler.m
//  OwnTracksIntents
//
//  Created by Christoph Krey on 29.06.20.
//  Copyright © 2020 OwnTracks. All rights reserved.
//

#import "IntentHandler.h"
#import "OwnTracksSendNowIntent.h"
#import "OwnTracksChangeMonitoringIntent.h"
#import "OwnTracksEnum.h"
#import "OwnTracksTagIntent.h"
#import "OwnTracksPOIIntent.h"

@interface IntentHandler () <OwnTracksSendNowIntentHandling, OwnTracksChangeMonitoringIntentHandling, OwnTracksTagIntentHandling, OwnTracksPOIIntentHandling>

@end

@implementation IntentHandler

- (id)handlerForIntent:(INIntent *)intent {
    // This is the default implementation.  If you want different objects to handle different intents,
    // you can override this and return the handler you want for that particular intent.
    
    return self;
}

- (void)handleSendNow:(nonnull OwnTracksSendNowIntent *)intent
           completion:(nonnull void (^)(OwnTracksSendNowIntentResponse * _Nonnull))completion {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.org.owntracks.Owntracks"];
    [shared setObject:[NSDate date] forKey:@"sendNow"];
    [shared synchronize];

    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:@"org.mqttitude.MQTTitude.sendNow"];
    OwnTracksSendNowIntentResponse *response = [[OwnTracksSendNowIntentResponse alloc] initWithCode:OwnTracksSendNowIntentResponseCodeSuccess userActivity:userActivity];
    completion(response);
}

- (void)handleChangeMonitoring:(nonnull OwnTracksChangeMonitoringIntent *)intent
                    completion:(nonnull void (^)(OwnTracksChangeMonitoringIntentResponse * _Nonnull))completion {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.org.owntracks.Owntracks"];
    NSInteger monitoring = [shared integerForKey:@"monitoring"];
    switch (intent.monitoring) {
        case OwnTracksEnumQuiet:
            monitoring = -1;
            break;
        case OwnTracksEnumManual:
            monitoring = 0;
            break;
        case OwnTracksEnumSignificant:
            monitoring = 1;
            break;
        case OwnTracksEnumMove:
            monitoring = 2;
            break;
        default:
            break;
    }
    [shared setInteger:monitoring forKey:@"monitoring"];
    [shared synchronize];

    OwnTracksChangeMonitoringIntentResponse *response = [[OwnTracksChangeMonitoringIntentResponse alloc] initWithCode:OwnTracksChangeMonitoringIntentResponseCodeSuccess userActivity:nil];
    completion(response);
}

- (void)resolveMonitoringForChangeMonitoring:(nonnull OwnTracksChangeMonitoringIntent *)intent
                              withCompletion:(nonnull void (^)(OwnTracksEnumResolutionResult * _Nonnull))completion {
    if (intent.monitoring == OwnTracksEnumQuiet ||
        intent.monitoring == OwnTracksEnumManual ||
        intent.monitoring == OwnTracksEnumSignificant ||
        intent.monitoring == OwnTracksEnumMove) {
        OwnTracksEnumResolutionResult *result = [OwnTracksEnumResolutionResult successWithResolvedEnum:intent.monitoring];
        completion(result);
    } else {
        OwnTracksEnumResolutionResult *result = [OwnTracksEnumResolutionResult confirmationRequiredWithEnumToConfirm:intent.monitoring];
        completion(result);
    }
}

- (void)handleTag:(OwnTracksTagIntent *)intent
       completion:(void (^)(OwnTracksTagIntentResponse * _Nonnull))completion {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.org.owntracks.Owntracks"];
    [shared setObject:intent.tag forKey:@"tag"];
    [shared synchronize];

    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:@"org.mqttitude.MQTTitude.sendNow"];
    OwnTracksTagIntentResponse *response = [[OwnTracksTagIntentResponse alloc] initWithCode:OwnTracksTagIntentResponseCodeSuccess userActivity:userActivity];
    completion(response);
}

- (void)resolveTagForTag:(OwnTracksTagIntent *)intent withCompletion:(void (^)(INStringResolutionResult * _Nonnull))completion {
    INStringResolutionResult *result = [INStringResolutionResult successWithResolvedString:intent.tag];
    completion(result);
}

- (void)handlePOI:(OwnTracksPOIIntent *)intent
       completion:(void (^)(OwnTracksPOIIntentResponse * _Nonnull))completion {

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.org.owntracks.Owntracks"];
    [shared setObject:intent.POI forKey:@"POI"];
    [shared synchronize];

    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:@"org.mqttitude.MQTTitude.sendNow"];
    OwnTracksPOIIntentResponse *response = [[OwnTracksPOIIntentResponse alloc] initWithCode:OwnTracksPOIIntentResponseCodeSuccess userActivity:userActivity];
    completion(response);
}

- (void)resolvePOIForPOI:(OwnTracksPOIIntent *)intent withCompletion:(void (^)(INStringResolutionResult * _Nonnull))completion {
    INStringResolutionResult *result = [INStringResolutionResult successWithResolvedString:intent.POI];
    completion(result);
}

@end
