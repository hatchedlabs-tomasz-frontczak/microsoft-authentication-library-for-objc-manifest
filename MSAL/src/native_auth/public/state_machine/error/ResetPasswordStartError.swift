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

import Foundation

@objc
public class ResetPasswordStartError: MSALNativeAuthError {
    /// An error type indicating the type of error that occurred
    @objc public let type: ResetPasswordStartErrorType

    init(type: ResetPasswordStartErrorType, message: String? = nil) {
        self.type = type
        super.init(message: message)
    }

    public override var errorDescription: String? {
        if let description = super.errorDescription {
            return description
        }

        switch type {
        case .browserRequired:
            return "Browser required"
        case .generalError:
            return "General error"
        case .userDoesNotHavePassword:
            return "User does not have a password"
        case .userNotFound:
            return "User not found"
        case .invalidUsername:
            return "Invalid username"
        }
    }
}

@objc
public enum ResetPasswordStartErrorType: Int {
    case browserRequired
    case generalError
    case userDoesNotHavePassword
    case userNotFound
    case invalidUsername
}
