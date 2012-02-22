//
//  MASTOrmmaHelper.h
//  Copyright (c) Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASTOrmmaAdaptor.h"
#import "MASTReachability.h"

@interface MASTOrmmaHelper : NSObject

+ (NSString*)registerOrmmaUpCaseObject;
+ (NSString*)signalReadyInWebView;
+ (NSString*)nativeCallComplete:(NSString*)command;

+ (NSString*)setState:(ORMMAState)state;
+ (NSString*)setViewable:(BOOL)viewable;
+ (NSString*)setNetwork:(MASTNetworkStatus)status;
+ (NSString*)setSize:(CGSize)size;
+ (NSString*)setMaxSize:(CGSize)size;
+ (NSString*)setScreenSize:(CGSize)size;
+ (NSString*)setDefaultPosition:(CGRect)frame;
+ (NSString*)setPlacementInterstitial:(BOOL)interstitial;
+ (NSString*)setExpandPropertiesWithMaxSize:(CGSize)size;
+ (NSString*)setOrientation:(UIDeviceOrientation)orientation;
+ (NSString*)setSupports:(NSArray*)supports;
+ (NSString*)setKeyboardShow:(BOOL)isShow;
+ (NSString*)setTilt:(UIAcceleration*)acceleration;
+ (NSString*)setHeading:(CGFloat)heading;
+ (NSString*)setLatitude:(CGFloat)latitude longitude:(CGFloat)longitude accuracy:(CGFloat)accuracy;
+ (NSString*)fireResponseEvent:(NSString*)response uri:(NSString*)uri;

+ (NSString*)fireChangeEvent:(NSString*)value;
+ (NSString*)fireShakeEventInWebView;
+ (NSString*)fireError:(NSString*)message forEvent:(NSString*)event;

+ (CGSize)screenSizeForOrientation:(UIDeviceOrientation)orientation;
+ (NSDictionary *)parametersFromJSCall:(NSString *)parameterString;
+ (CGFloat)floatFromDictionary:(NSDictionary*)dictionary
						forKey:(NSString*)key;
+ (NSString*)requiredStringFromDictionary:(NSDictionary*)dictionary
                                   forKey:(NSString *)key;
+ (BOOL)booleanFromDictionary:(NSDictionary *)dictionary
					   forKey:(NSString *)key;

@end