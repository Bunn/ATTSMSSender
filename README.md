## iOS AT&T SMS Sender

This is a very basic wrapper on top of AFNetwork to send SMS using AT&T's service.

## How To Get Started
- [Create an AT&T developer account](https://developer.att.com/developer/) to get your Client ID and Client Secret.
- In ATTSMSSender.m add your Client ID and Client Secret at the pre define location.

## Example Usage

``` objective-c
    ATTSMSSender *attService = [[ATTSMSSender alloc] init];
    [attService sendSMSWithNumber:@"PhoneNumber" andMessage:@"Message" withSuccess:^{
        NSLog(@"Success");
    } andFailure:^(NSError *error, NSData *responseData) {
        NSLog(@"Error  [%@]", error);
    }];
```
