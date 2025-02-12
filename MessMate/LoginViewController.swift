//
//  LoginViewController.swift
//  MessMate
//
//  Created by Divyansh Singhal on 08/02/25.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth

class LoginViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingCircle.isHidden = true  // Ensure it's hidden initially
    }

    @IBOutlet weak var errorDescription: UILabel!
    @IBOutlet weak var passwordtext: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var loginButtonReal: UIButton!
    @IBOutlet weak var loadingCircle: UIActivityIndicatorView!

    @IBOutlet weak var loginText: UILabel!
    @IBOutlet weak var loginImage: UIImageView!
    @IBOutlet weak var imageLeading: NSLayoutConstraint!  // ✅ Kept untouched
    @IBOutlet weak var loginTrailing: NSLayoutConstraint! // ✅ Kept untouched

    var login = ["L", "o", "g", "i", "n"]

    @IBAction func realLogin(_ sender: UIButton) {
        // Start loading animation and disable login button
        loadingCircle.isHidden = false
        loadingCircle.startAnimating()
        loginButtonReal.isEnabled = false
        
        guard let email = emailText.text, let password = passwordtext.text, !email.isEmpty, !password.isEmpty else {
            errorDescription.text = "Please enter all fields"
            stopLoading()
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    // Login failed, show error and re-enable button
                    strongSelf.errorDescription.text = error.localizedDescription
                    strongSelf.stopLoading()
                } else {
                    // Login successful, transition to AccountViewController
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let accountDetailsVC = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as? AccountViewController {
                        strongSelf.stopLoading()
                        strongSelf.navigationController?.pushViewController(accountDetailsVC, animated: true)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        // Kept all existing animations and constraints intact
        loadingCircle.isHidden = true
        loginText.text = ""
        loginText.alpha = 0.1
        loginImage.alpha = 0.1
        imageLeading.constant = -100  // ✅ Kept untouched
        animateLogin()
        blurLoginandLoginImage()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)  // Dismisses the keyboard
    }
    
    private func stopLoading() {
        loadingCircle.stopAnimating()
        loadingCircle.isHidden = true
        loginButtonReal.isEnabled = true
    }

    func animateLogin() {
        for i in 0..<login.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                self.loginText.text! += self.login[i]
            }
        }
    }

    func blurLoginandLoginImage() {
        UIView.animate(withDuration: 2.0, animations: {
            self.loginText.alpha = 1.0
            self.imageLeading.constant = 0  // ✅ Kept untouched
            self.loginImage.alpha = 1.0
        })
    }
}
