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

@_implementationOnly import MSAL_Private

protocol MSALNativeAuthTokenResponseValidating {
    func validate(
        context: MSALNativeAuthRequestContext,
        msidConfiguration: MSIDConfiguration,
        result: Result<MSIDCIAMTokenResponse, Error>
    ) -> MSALNativeAuthTokenValidatedResponse
}

final class MSALNativeAuthTokenResponseValidator: MSALNativeAuthTokenResponseValidating {
    private let tokenResponseHandler: MSALNativeAuthTokenResponseHandling
    private let factory: MSALNativeAuthResultBuildable

    init(
        tokenResponseHandler: MSALNativeAuthTokenResponseHandling,
        factory: MSALNativeAuthResultBuildable
    ) {
        self.tokenResponseHandler = tokenResponseHandler
        self.factory = factory
    }

    func validate(
        context: MSALNativeAuthRequestContext,
        msidConfiguration: MSIDConfiguration,
        result: Result<MSIDCIAMTokenResponse, Error>
    ) -> MSALNativeAuthTokenValidatedResponse {
        switch result {
        case .success(let tokenResponse):
            guard let tokenResult = validateAndConvertTokenResponse(
                tokenResponse,
                context: context,
                msidConfiguration: msidConfiguration
            ) else {
                return .error(.invalidServerResponse)
            }
            guard let userAccountResult = factory.makeUserAccountResult(
                tokenResult: tokenResult,
                context: context
            ) else {
                return .error(.invalidServerResponse)
            }
            return .success(userAccountResult, tokenResult, tokenResponse)
        case .failure(let tokenResponseError):
            guard let tokenResponseError =
                    tokenResponseError as? MSALNativeAuthTokenResponseError else {
                MSALLogger.log(
                    level: .error,
                    context: context,
                    format: "Token: Error type not expected, error: \(tokenResponseError)")
                return .error(.invalidServerResponse)
            }
            return handleFailedTokenResult(context, tokenResponseError)
        }
    }

    private func handleFailedTokenResult(
        _ context: MSALNativeAuthRequestContext,
        _ responseError: MSALNativeAuthTokenResponseError) -> MSALNativeAuthTokenValidatedResponse {
            switch responseError.error {
            case .invalidRequest:
                return .error(.invalidRequest)
            case .invalidClient:
                return .error(.invalidClient)
            case .invalidGrant:
                return handleInvalidGrantErrorCodes(errorCodes: responseError.errorCodes, context: context)
            case .expiredToken:
                return .error(.expiredToken)
            case .expiredRefreshToken:
                return .error(.expiredRefreshToken)
            case .unsupportedChallengeType:
                return .error(.unsupportedChallengeType)
            case .invalidScope:
                return .error(.invalidScope)
            case .authorizationPending:
                return .error(.authorizationPending)
            case .slowDown:
                return .error(.slowDown)
            }
        }

    private func validateAndConvertTokenResponse(
        _ tokenResponse: MSIDTokenResponse,
        context: MSALNativeAuthRequestContext,
        msidConfiguration: MSIDConfiguration
    ) -> MSIDTokenResult? {
        do {
            let displayableId = tokenResponse.idTokenObj?.username()
            let homeAccountId = tokenResponse.idTokenObj?.uniqueId
            return try tokenResponseHandler.handle(
                context: context,
                accountIdentifier: .init(displayableId: displayableId, homeAccountId: homeAccountId),
                tokenResponse: tokenResponse,
                configuration: msidConfiguration,
                validateAccount: true
            )
        } catch {
            MSALLogger.log(
                level: .error,
                context: context,
                format: "Response validation error: \(error)"
            )
            return nil
        }
    }

    private func handleInvalidGrantErrorCodes(errorCodes: [Int]?, context: MSALNativeAuthRequestContext) -> MSALNativeAuthTokenValidatedResponse {
        if let knownError = errorCodes?.compactMap({ convertErrorCodeToApiErrorCode($0, context) }).first {
            return .error(convertErrorCodeToErrorType(knownError))
        } else {
            MSALLogger.log(level: .error, context: context, format: "/token error - Empty error_codes received")
            return .error(.generalError)
        }
    }

    private func convertErrorCodeToApiErrorCode(_ errorCode: Int, _ context: MSALNativeAuthRequestContext) -> MSALNativeAuthESTSAPIErrorCodes? {
        if let error = MSALNativeAuthESTSAPIErrorCodes(rawValue: errorCode) {
            return error
        } else {
            MSALLogger.log(level: .error, context: context, format: "/token error - Unknown code received in error_codes: \(errorCode)")
            return nil
        }
    }

    private func convertErrorCodeToErrorType(_ errorCode: MSALNativeAuthESTSAPIErrorCodes) -> MSALNativeAuthTokenValidatedErrorType {
        switch errorCode {
        case .userNotFound:
            return .userNotFound
        case .invalidCredentials:
            return .invalidPassword
        case .invalidAuthenticationType:
            return .invalidAuthenticationType
        case .invalidOTP:
            return .invalidOOBCode
        case .strongAuthRequired:
            return .strongAuthRequired
        case .invalidPasswordResetToken:
            return .generalError
        }
    }
}
