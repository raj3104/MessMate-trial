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
    
    
    @IBOutlet weak var errorDescription: UILabel!
    
    @IBOutlet weak var passwordtext: UITextField!
    @IBAction func loginButtonPressed(_ sender: UIButton) {
       
        if let email=emailText.text, let password=passwordtext.text{
            errorDescription.text=""
            Auth.auth().signIn(withEmail: email, password: password){
                authResult, error in
                if let e=error{
                    print(e.localizedDescription)
                    self.errorDescription.text=e.localizedDescription
                    
                }
                else{
                    self.performSegue(withIdentifier: "loginToMM", sender: self)
                }
                
                }
        }else{
            errorDescription.text="Please enter all fields"
        }
    }
    
    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginText: UILabel!
    var login=["L","o","g","i","n"]
    
    @IBOutlet weak var loginTrailing: NSLayoutConstraint!
    @IBOutlet weak var imageLeading: NSLayoutConstraint!
    @IBOutlet weak var loginImage: UIImageView!
    @IBOutlet weak var emailText: UITextField!
    
    @IBAction func realLogin(_ sender: UIButton) {
        
        if let otp=passwordtext.text, !otp.isEmpty {
            let code=otp
            AuthManager.shared.verifyCode(smsCode: code) { [weak self] success in
                guard success else{return}
                DispatchQueue.main.async {
                    LoginViewController().title="Login Successful"
                }
            }
        }
    }
    
    @IBOutlet weak var loginButtonReal: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        passwordtext.isHidden=true
//        loginButton.setTitle("Send OTP", for: .normal)
        loginButtonReal.isHidden=true
        loginText.text=""
        loginText.alpha=0.1
       
        loginImage.alpha=0.1
        imageLeading.constant = -100
        animateLogin()
        blurLoginandLoginImage()
        
        
        
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)  // Dismisses the keyboard
    }
    
    
    
    
    func animateLogin(){
        for i in 0..<login.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                self.loginText.text! += self.login[i]
            }
        }
        
        
        
        
        
    }
    
    func blurLoginandLoginImage(){
        UIView.animate(withDuration: 2.0, animations: {
            self.loginText.alpha=1.0
            self.imageLeading.constant = 0
            self.loginImage.alpha=1.0
        })
    }
}
