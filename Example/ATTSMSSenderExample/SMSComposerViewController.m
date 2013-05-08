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
// THE SOFTWARE.


#import "SMSComposerViewController.h"
#import "ATTSMSSender.h"

@interface SMSComposerViewController ()

@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *messageTextField;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation SMSComposerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSInteger margin = 5;
    NSInteger textFieldHeight = 50;
    self.title = @"SMS Composer";

    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(margin, margin, self.view.frame.size.width - (margin * 2), textFieldHeight)];
    self.phoneTextField.backgroundColor = [UIColor blackColor];
    self.phoneTextField.font = [UIFont systemFontOfSize:25];
    self.phoneTextField.textAlignment = NSTextAlignmentCenter;
    self.phoneTextField.borderStyle = UITextBorderStyleBezel;
    self.phoneTextField.textColor = [UIColor whiteColor];
    self.phoneTextField.placeholder = @"Phone Number";
    self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.phoneTextField];
    [self.phoneTextField becomeFirstResponder];
    
    self.messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(margin, self.phoneTextField.frame.origin.y + self.phoneTextField.frame.size.height + margin, self.view.frame.size.width - (margin * 2), textFieldHeight)];
    self.messageTextField.backgroundColor = [UIColor blackColor];
    self.messageTextField.font = [UIFont systemFontOfSize:25];
    self.messageTextField.borderStyle = UITextBorderStyleBezel;
    self.messageTextField.textAlignment = NSTextAlignmentCenter;
    self.messageTextField.textColor = [UIColor whiteColor];
    self.messageTextField.placeholder = @"Message";
    self.messageTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.messageTextField.keyboardType = UIKeyboardTypeAlphabet;;
    self.messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.messageTextField];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame = CGRectMake(margin, self.messageTextField.frame.origin.y + self.messageTextField.frame.size.height + margin, self.view.frame.size.width - (margin * 2), 45);
    [sendButton setTitle:@"Send SMS" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, sendButton.frame.origin.y + sendButton.frame.size.height + margin, self.view.frame.size.width, 20)];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.text = @"Text Sent";
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.textColor = [UIColor yellowColor];
    self.statusLabel.shadowOffset = CGSizeMake(0, 1);
    self.statusLabel.shadowColor = [UIColor blackColor];
    self.statusLabel.hidden = YES;
    [self.view addSubview:self.statusLabel];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.center = self.statusLabel.center;
    [self.view addSubview:self.spinner];
}


#pragma mark - UIButton Methods

- (void)sendButtonPressed:(UIButton *)sendButton {
    ATTSMSSender *attService = [[ATTSMSSender alloc] init];
    [self.spinner startAnimating];
    self.statusLabel.text = @"";
    
    [attService sendSMSWithNumber:self.phoneTextField.text andMessage:self.messageTextField.text withSuccess:^{
        self.statusLabel.hidden = NO;
        self.statusLabel.textColor = [UIColor greenColor];
        self.statusLabel.text = @"SMS sent";
        [self.spinner stopAnimating];
    } andFailure:^(NSError *error, NSData *responseData) {
        NSLog(@"Error  [%@]", error);
        self.statusLabel.hidden = NO;
        self.statusLabel.textColor = [UIColor yellowColor];
        self.statusLabel.text = @"SMS could not be sent";
        [self.spinner stopAnimating];
    }];
}

@end
