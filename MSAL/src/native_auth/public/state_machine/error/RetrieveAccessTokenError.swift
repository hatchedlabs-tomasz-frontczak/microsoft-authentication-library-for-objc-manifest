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

@objcMembers
public class RetrieveAccessTokenError: MSALNativeAuthError {
    let type: RetrieveAccessTokenErrorType

    init(type: RetrieveAccessTokenErrorType, message: String? = nil) {
        self.type = type
        super.init(identifier: type.rawValue, message: message)
    }

    /// Describes why an error occurred and provides more information about the error.
    public override var errorDescription: String? {
        if let description = super.errorDescription {
            return description
        }

        switch type {
        case .browserRequired:
            return MSALNativeAuthErrorMessage.browserRequired
        case .refreshTokenExpired:
            return MSALNativeAuthErrorMessage.refreshTokenExpired
        case .tokenNotFound:
            return MSALNativeAuthErrorMessage.tokenNotFound
        case .generalError:
            return MSALNativeAuthErrorMessage.generalError
        }
    }

    /// Returns `true` if a browser is required to continue the operation.
    public var isBrowserRequired: Bool {
        return type == .browserRequired
    }

    /// Returns `true` if the refresh token has expired.
    public var isRefreshTokenExpired: Bool {
        return type == .refreshTokenExpired
    }

    /// Returns `true` if the existing token cannot be found.
    public var isTokenNotFound: Bool {
        return type == .tokenNotFound
    }
}

@objc
public enum RetrieveAccessTokenErrorType: Int, CaseIterable {
    case browserRequired
    case refreshTokenExpired
    case tokenNotFound
    case generalError
}
