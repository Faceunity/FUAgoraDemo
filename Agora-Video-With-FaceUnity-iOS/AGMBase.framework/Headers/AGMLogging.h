/*
 *  Copyright 2015 The AgoraAGM project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#import "AGMMacros.h"

// Subset of AGM::LoggingSeverity.
typedef NS_ENUM(NSInteger, AGMLoggingSeverity) {
  AGMLoggingSeverityVerbose,
  AGMLoggingSeverityInfo,
  AGMLoggingSeverityWarning,
  AGMLoggingSeverityError,
  AGMLoggingSeverityDebug,
};

// Logs the log string to the AgoraAGM logstream for the given severity.
AGM_EXTERN void AGMLogEx(AGMLoggingSeverity severity, NSString* log_string);

//#define AGMLogString(format, ...)                                           \
//  [NSString stringWithFormat:@"(%@:%d %s): " format, AGMFileName(__FILE__), \
//                             __LINE__, __FUNCTION__, ##__VA_ARGS__]
#define AGMLogString(format, ...)                                           \
  [NSString stringWithFormat:@"" format, ##__VA_ARGS__]


#define AGMLogFormat(severity, format, ...)                     \
  do {                                                          \
    NSString* log_string = AGMLogString(format, ##__VA_ARGS__); \
    [AGMLogging setLogLevel:severity info:log_string]; \
  } while (false)

#define AGMLogVerbose(format, ...) \
  AGMLogFormat(AGMLoggingSeverityVerbose, format, ##__VA_ARGS__)

#define AGMLogInfo(format, ...) \
  AGMLogFormat(AGMLoggingSeverityInfo, format, ##__VA_ARGS__)

#define AGMLogWarning(format, ...) \
  AGMLogFormat(AGMLoggingSeverityWarning, format, ##__VA_ARGS__)

#define AGMLogError(format, ...) \
  AGMLogFormat(AGMLoggingSeverityError, format, ##__VA_ARGS__)

#if !defined(NDEBUG)
#define AGMLogDebug(format, ...) AGMLogInfo(format, ##__VA_ARGS__)
#else
#define AGMLogDebug(format, ...) \
  do {                           \
  } while (false)
#endif

//#define AGMLog(format, ...) AGMLogInfo(format, ##__VA_ARGS__)

@interface AGMLogging : NSObject

+ (instancetype)defaultLogging;

+ (void)setLogLevel:(AGMLoggingSeverity)level info:(NSString *)info;

- (NSString *)logFilePath;
// Disable console print.
- (void)disableDebug;

@end
