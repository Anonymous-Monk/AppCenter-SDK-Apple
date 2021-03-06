// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSHttpIngestion.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSStorageIngestion : MSHttpIngestion

/**
 * AppSecret for the application.
 */
@property(nonatomic) NSString *appSecret;

/**
 * Initialize the Ingestion.
 *
 * @param baseUrl Base url.
 * @param appSecret A unique and secret key used to identify the application.
 *
 * @return An ingestion instance.
 */
- (id)initWithBaseUrl:(nullable NSString *)baseUrl appSecret:(NSString *)appSecret;

@end

NS_ASSUME_NONNULL_END
