//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ObjCViewController.h"
#import "NativeAuthSampleApp-Swift.h"
@import MSAL;



@interface ObjCViewController () <SignInStartDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

@property (strong) MSALNativeAuthPublicClientApplication *nativeAuth;
@property (strong) MSALNativeAuthUserAccount *account;

@end

@implementation ObjCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MSALPublicClientApplicationConfig *configuration = [[MSALPublicClientApplicationConfig alloc] initWithClientId:Configuration.clientId];

    NSError *error = nil;
    self.nativeAuth = [[MSALNativeAuthPublicClientApplication alloc]
                       initWithConfiguration:configuration
                       challengeTypes:MSALNativeAuthChallengeTypeOOB | MSALNativeAuthChallengeTypePassword
                       error:&error];

    if (error != nil) {
        NSLog(@"Unable to initialize MSAL %@", error);
    } else {
        NSLog(@"Initialized MSAL successfully");
    }
}

- (IBAction)signInPressed:(id)sender {
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;

    [self.nativeAuth signInUsername:email
                           password:password
                             scopes:nil
                      correlationId:nil
                           delegate:self];
}

- (IBAction)signOutPressed:(id)sender {
    if (self.account == nil) {
        NSLog(@"signOutPressed: Not currently signed in.");
        return;
    }

    self.account = nil;

    [self showResultText:@"Signed out."];

    [self updateUI];
}

- (void)showResultText:(NSString *)text {
    self.resultTextView.text = text;
}

- (void)updateUI {
    BOOL signedIn = (self.account != nil);

    self.signInButton.enabled = !signedIn;
    self.signOutButton.enabled = signedIn;
}

#pragma mark - Sign In Delegate methods

- (void)onSignInCodeSentWithNewState:(SignInCodeSentState * _Nonnull)newState displayName:(NSString * _Nonnull)displayName codeLength:(NSInteger)codeLength {
    NSLog(@"Unexpected state while signing in: Code Sent");
}

- (void)onSignInCompletedWithResult:(MSALNativeAuthUserAccount * _Nonnull)result {
    [self showResultText:[NSString stringWithFormat:@"Signed in successfully. Access Token: %@", result.accessToken]];

    self.account = result;

    [self updateUI];
}

- (void)onSignInErrorWithError:(SignInStartError * _Nonnull)error {
    switch (error.type) {
        case SignInStartErrorTypeInvalidUsername:
            [self showResultText:@"Invalid username."];
            break;

        case SignInStartErrorTypeInvalidPassword:
            [self showResultText:@"Invalid password."];
            break;

        default:
            [self showResultText:[NSString stringWithFormat:@"Unexpected error signing in: %@", @(error.type)]];
    }
}

@end
