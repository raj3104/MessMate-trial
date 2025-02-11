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
    
    var register = ["R", "e", "g", "i", "s", "t", "e", "r"]

    override func viewDidLoad() {
        super.viewDidLoad()
        registerButtoninfo.isEnabled = true
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

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                print("❌ Registration Error:", e.localizedDescription)
                self.errorDescription.text = e.localizedDescription
                return
            }
            
            guard let user = authResult?.user else { return }

            // ✅ Send Email Verification
            user.sendEmailVerification { error in
                if let error = error {
                    print("❌ Error sending verification email:", error.localizedDescription)
                    return
                }
                print("📩 Verification email sent!")
                self.registerButtoninfo.isEnabled = false
                UIView.animate(withDuration: 2.0, animations: {
                    self.registerButtoninfo.isEnabled=true
                })

                // ✅ Show Alert to Inform User
                self.showEmailVerificationAlert(user: user)
            }
        }
    }

    // ✅ Function to Show Alert After Email is Sent
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

    // ✅ Function to Resend Email Verification
    func resendVerificationEmail(user: FirebaseAuth.User) {
        user.sendEmailVerification { error in
            if let error = error {
                print("❌ Error resending email:", error.localizedDescription)
            } else {
                print("📩 Verification email resent!")
            }
        }
    }

    // ✅ Function to Wait for User to Verify Email
    func waitForEmailVerification(user: FirebaseAuth.User) {
        let checkInterval = 5.0 // Check every 5 seconds
        
        Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { timer in
            user.reload { error in
                if let error = error {
                    print("❌ Error reloading user:", error.localizedDescription)
                    return
                }
                
                if user.isEmailVerified {
                    print("✅ Email is verified!")
                    timer.invalidate() // Stop checking
                    
                    // ✅ Navigate to User Details Screen
                    self.navigateToUserDetails(userId: user.uid)
                } else {
                    print("⚠️ Email not verified yet. Retrying...")
                }
            }
        }
    }

    // ✅ Function to Navigate After Verification
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
