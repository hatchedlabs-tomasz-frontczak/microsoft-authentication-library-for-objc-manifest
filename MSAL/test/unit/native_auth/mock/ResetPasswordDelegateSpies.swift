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
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

@testable import MSAL

class ResetPasswordResendCodeDelegateSpy: ResetPasswordResendCodeDelegate {
    private(set) var error: ResendCodeError?
    private(set) var newState: ResetPasswordCodeSentState?
    private(set) var displayName: String?
    private(set) var codeLength: Int?

    func onResetPasswordResendCodeError(error: ResendCodeError, newState: ResetPasswordCodeSentState?) {
        self.error = error
        self.newState = newState
    }

    func onResetPasswordResendCodeSent(newState: ResetPasswordCodeSentState, displayName: String, codeLength: Int) {
        self.newState = newState
        self.displayName = displayName
        self.codeLength = codeLength
    }
}

class ResetPasswordVerifyCodeDelegateSpy: ResetPasswordVerifyCodeDelegate {
    private(set) var error: VerifyCodeError?
    private(set) var newCodeSentState: ResetPasswordCodeSentState?
    private(set) var newPasswordRequiredState: ResetPasswordRequiredState?

    func onResetPasswordVerifyCodeError(error: VerifyCodeError, newState: ResetPasswordCodeSentState?) {
        self.error = error
        newCodeSentState = newState
    }

    func onPasswordRequired(newState: ResetPasswordRequiredState) {
        newPasswordRequiredState = newState
    }
}

class ResetPasswordRequiredDelegateSpy: ResetPasswordRequiredDelegate {
    private(set) var error: PasswordRequiredError?
    private(set) var newPasswordRequiredState: ResetPasswordRequiredState?
    private(set) var resetPasswordCompletedCalled = false

    func onResetPasswordRequiredError(error: PasswordRequiredError, newState: ResetPasswordRequiredState?) {
        self.error = error
        newPasswordRequiredState = newState
    }

    func onResetPasswordCompleted() {
        resetPasswordCompletedCalled = true
    }
}
