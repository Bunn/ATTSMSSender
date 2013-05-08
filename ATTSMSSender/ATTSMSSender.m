//
// Copyright (c) 2013 IdevZilla (http://idevzilla.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE


#import "ATTSMSSender.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

#warning CLIENT_ID and CLIENT_SECRET should be configured.

#define CLIENT_ID @""
#define CLIENT_SECRET @""

#define BASE_URL @"https://api.att.com/"

@implementation ATTSMSSender

- (void)sendSMSWithNumber:(NSString *)number andMessage:(NSString *)message
              withSuccess:(void (^)())success
               andFailure:(void(^)(NSError *error, NSData *responseData))failure {
    
    if ([number length] <= 0 && [message length] <= 0) {
        NSError *error = [[NSError alloc] initWithDomain:@"ATTSMSSenderDomain" code:-1001 userInfo:@{@"message": @"Phone number or message cannot be empty."}];
        failure(error, nil);
        return;
    }
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    [httpClient setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    NSDictionary *jsonDictionary = @{@"client_id" : CLIENT_ID,
                                     @"client_secret" : CLIENT_SECRET,
                                     @"grant_type" : @"client_credentials",
                                     @"scope": @"SMS"};
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"oauth/token" parameters:jsonDictionary];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = responseObject;
        [self sendSMSWithToken:response[@"access_token"] number:number andMessage:message withSuccess:success andFailure:failure];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        __block NSData *responseData = operation.responseData;
        failure(error, responseData);
    }];
    [operation start];
}

- (void)sendSMSWithToken:(NSString *)token number:(NSString *)number andMessage:(NSString *)message
             withSuccess:(void (^)())success
              andFailure:(void(^)(NSError *error, NSData *responseData))failure {
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@",token]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    [httpClient setDefaultHeader:@"Content-Type" value:@"application/json"];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    
    NSDictionary *jsonDictionary = @{@"outboundSMSRequest" : @{@"address": [NSString stringWithFormat:@"tel:%@",number],
                                                               @"message": message}};
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"sms/v3/messaging/outbox" parameters:jsonDictionary];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        __block NSData *responseData = operation.responseData;
        failure(error, responseData);
        
    }];
    [operation start];
}

@end
