//
//  RegisterViewController.swift
//  MessMate
//
//  Created by Divyansh Singhal on 09/02/25.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var errorDescription: UILabel!
    @IBOutlet weak var registerImageLeading: NSLayoutConstraint!
    @IBOutlet weak var registerImage: UIImageView!
    @IBOutlet weak var registerText: UILabel!
    var register = ["R", "e", "g", "i", "s", "t", "e", "r"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        registerText.text = ""
        registerText.alpha = 0.1
        registerImage.alpha = 0.1
        registerImageLeading.constant = -100
        animateRegister()
        blurRegisterandRegisterImage()
    }
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
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
                print(e.localizedDescription)
                self.errorDescription.text = e.localizedDescription
                return
            }
            
            guard let user = authResult?.user else { return }
            let userId = user.uid
            
            // Navigate to UserDetailsViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewControllerIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any]

            print("Available ViewControllers:", viewControllerIdentifiers ?? "None found")

            if let userDetailsVC = storyboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as? UserDetailsViewController {
                userDetailsVC.userId = userId
                self.navigationController?.pushViewController(userDetailsVC, animated: true)
            } else {
                print("❌ Error: UserDetailsViewController not found in storyboard")
            }

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
