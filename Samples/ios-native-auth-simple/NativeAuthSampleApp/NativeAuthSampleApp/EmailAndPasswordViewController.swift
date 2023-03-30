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

import UIKit
import MSAL

class EmailAndPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!

    var appContext: MSALNativeAuthPublicClientApplication!

    override func viewDidLoad() {
        super.viewDidLoad()

        appContext = MSALNativeAuthPublicClientApplication(
            configuration: MSALNativeAuthPublicClientApplicationConfig(
                clientId: "clientId",
                authority: URL(string: "https://example.com")!,
                tenantName: "tenant"))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // TODO: Call appContext.getUserAccount() and update UI accordingly
    }

    @IBAction func signInTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            resultTextView.text = "email or password not set"
            return
        }

        showOTPModal()
    }

    func showOTPModal() {
        guard let otpViewController = storyboard?.instantiateViewController(
            withIdentifier: "OTPViewController") as? OTPViewController else {
            return
        }

        otpViewController.otpSubmittedCallback = { [self] otp in
            DispatchQueue.main.async { [self] in
                Task {
                    showResultText("Submitted OTP: \(otp)")
                    dismiss(animated: true)

                    updateUI()
                }
            }
        }

        present(otpViewController, animated: true)
    }

    func showResultText(_ text: String) {
        resultTextView.text = text
    }

    func updateUI() {
        let signedIn = true

        if signedIn {
            signUpButton.isEnabled = false
            signInButton.isEnabled = false
            signOutButton.isEnabled = true
        } else {
            signUpButton.isEnabled = true
            signInButton.isEnabled = true
            signOutButton.isEnabled = false
        }
    }

}
