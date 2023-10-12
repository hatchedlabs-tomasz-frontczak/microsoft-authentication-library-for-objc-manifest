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

import Foundation

@_implementationOnly import MSAL_Private

final class MSALNativeAuthResponseErrorHandler<T: Decodable & Error>: NSObject, MSIDHttpRequestErrorHandling {
    private var customError: T?

    // swiftlint:disable:next function_parameter_count
    func handleError(
        _ error: Error?,
        httpResponse: HTTPURLResponse?,
        data: Data?,
        httpRequest: MSIDHttpRequestProtocol?,
        responseSerializer: MSIDResponseSerialization?,
        externalSSOContext ssoContext: MSIDExternalSSOContext?,
        context: MSIDRequestContext?,
        completionBlock: MSIDHttpRequestDidCompleteBlock?
    ) {
        let handler = MSIDAADRequestErrorHandler()
        handler.handleError(error,
                            httpResponse: httpResponse,
                            data: data,
                            httpRequest: httpRequest,
                            responseSerializer: responseSerializer,
                            externalSSOContext: ssoContext,
                            context: context,
                            handleCustomErrorBlock: {
                                self.handleCustomError(data: data, completionBlock: completionBlock)
                            },
                            completionBlock: completionBlock)
    }

    private func handleCustomError(
        data: Data?,
        completionBlock: MSIDHttpRequestDidCompleteBlock?
    ) {
        do {
            customError = try JSONDecoder().decode(T.self, from: data ?? Data())
            completionBlock?(nil, customError)
        } catch {
            completionBlock?(nil, error)
        }
    }
}
