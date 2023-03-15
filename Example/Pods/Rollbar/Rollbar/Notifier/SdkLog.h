//  Copyright (c) 2018 Rollbar Inc. All rights reserved.

#import <Foundation/Foundation.h>

/// SDK-wide logging function.
/// Use it for all the SDK development/debugging needs.
/// @param format logged message format
void SdkLog(NSString *format, ...);// DEPRECATED_MSG_ATTRIBUTE("In v2, use RollbarSdkLog instead.");
