import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var errorDescription: UILabel!
    @IBOutlet weak var registerImageLeading: NSLayoutConstraint!
    @IBOutlet weak var registerImage: UIImageView!
    @IBOutlet weak var registerText: UILabel!
    @IBOutlet weak var registerButtoninfo: UIButton!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var registerLoader: UIActivityIndicatorView!
    
    var register = ["R", "e", "g", "i", "s", "t", "e", "r"]

    override func viewDidLoad() {
        super.viewDidLoad()
        registerButtoninfo.isEnabled = true
        registerLoader.isHidden = true // Hide loader initially
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        registerText.text = ""
        registerText.alpha = 0.1
        registerImage.alpha = 0.1
        registerImageLeading.constant = -100
        animateRegister()
        blurRegisterandRegisterImage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        registerButtoninfo.isEnabled = true // Enable button when the view disappears
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        registerButtoninfo.sendActions(for: .touchUpInside)
        textField.resignFirstResponder()
        return true
    }

    @IBAction func registerButton(_ sender: UIButton) {
        guard let email = emailText.text, let password = passwordText.text, let confirmPassword = confirmPassword.text else {
            errorDescription.text = "Please enter all fields"
            return
        }
        
        if password != confirmPassword {
            errorDescription.text = "Passwords don't match"
            return
        }
        
        errorDescription.text = ""
        registerLoader.isHidden = false
        registerLoader.startAnimating() // Start loader
        registerButtoninfo.isEnabled = false // Disable register button

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                print("❌ Registration Error:", e.localizedDescription)
                self.errorDescription.text = e.localizedDescription
                self.registerLoader.stopAnimating()
                self.registerLoader.isHidden = true
                self.registerButtoninfo.isEnabled = true // Re-enable if there's an error
                return
            }
            
            guard let user = authResult?.user else { return }

            user.sendEmailVerification { error in
                if let error = error {
                    print("❌ Error sending verification email:", error.localizedDescription)
                    self.registerLoader.stopAnimating()
                    self.registerLoader.isHidden = true
                    self.registerButtoninfo.isEnabled = true // Re-enable if there's an error
                    return
                }
                
                print("📩 Verification email sent!")
                self.showEmailVerificationAlert(user: user)
            }
        }
    }

    func showEmailVerificationAlert(user: FirebaseAuth.User) {
        let alert = UIAlertController(
            title: "Verify Your Email",
            message: "A verification email has been sent to your email address. Please check your inbox and click the verification link.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.waitForEmailVerification(user: user)
        }))
        
        alert.addAction(UIAlertAction(title: "Resend Email", style: .default, handler: { _ in
            self.resendVerificationEmail(user: user)
        }))
        
        present(alert, animated: true)
    }

    func resendVerificationEmail(user: FirebaseAuth.User) {
        user.sendEmailVerification { error in
            if let error = error {
                print("❌ Error resending email:", error.localizedDescription)
            } else {
                print("📩 Verification email resent!")
            }
        }
    }

    func waitForEmailVerification(user: FirebaseAuth.User) {
        registerLoader.isHidden = false
        registerLoader.startAnimating() // Start loader while waiting for verification
        registerButtoninfo.isEnabled = false // Keep button disabled until verified

        let checkInterval = 5.0
        Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { timer in
            user.reload { error in
                if let error = error {
                    print("❌ Error reloading user:", error.localizedDescription)
                    return
                }
                
                if user.isEmailVerified {
                    print("✅ Email is verified!")
                    timer.invalidate()
                    
                    // Sign in the user again to complete the process
                    Auth.auth().signIn(withEmail: user.email!, password: self.passwordText.text!) { authResult, error in
                        if let error = error {
                            print("❌ Error signing in after verification:", error.localizedDescription)
                            self.errorDescription.text = "Error logging in: \(error.localizedDescription)"
                            self.registerLoader.stopAnimating()
                            self.registerLoader.isHidden = true
                            self.registerButtoninfo.isEnabled = true // Enable button in case of error
                            return
                        }

                        // Stop loader and navigate to details screen
                        DispatchQueue.main.async {
                            self.registerLoader.stopAnimating()
                            self.registerLoader.isHidden = true
                        }
                        
                        self.navigateToUserDetails(userId: user.uid)
                    }
                } else {
                    print("⚠️ Email not verified yet. Retrying...")
                }
            }
        }
    }

    func navigateToUserDetails(userId: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let userDetailsVC = storyboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as? UserDetailsViewController {
            userDetailsVC.userId = userId
            self.navigationController?.pushViewController(userDetailsVC, animated: true)
        } else {
            print("❌ Error: UserDetailsViewController not found in storyboard")
        }
    }

    func animateRegister() {
        for i in 0..<register.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                self.registerText.text! += self.register[i]
            }
        }
    }

    func blurRegisterandRegisterImage() {
        UIView.animate(withDuration: 2.0, animations: {
            self.registerText.alpha = 1.0
            self.registerImageLeading.constant = 0
            self.registerImage.alpha = 1.0
        })
    }
}
