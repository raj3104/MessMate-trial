//
//  RegisterViewController.swift
//  MessMate
//
//  Created by Divyansh Singhal on 09/02/25.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var errorDescription: UILabel!
    @IBOutlet weak var registerImageLeading: NSLayoutConstraint!
    @IBOutlet weak var registerImage: UIImageView!
    @IBOutlet weak var registerText: UILabel!
    var register=["R","e","g","i","s","t","e","r"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        registerText.text=""
        registerText.alpha=0.1
       
        registerImage.alpha=0.1
        registerImageLeading.constant = -100
        animateRegister()
        blurRegisterandRegisterImage()

       
    }
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBAction func registerButton(_ sender: UIButton) {
        if let email=emailText, let password=passwordText {
            errorDescription.text=""
            
            if let password=confirmPassword.text{
                errorDescription.text=""
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e=error{
                        print(e.localizedDescription)
                        errorDescription.text=e.localizedDescription
                    }
                    else{
                        errorDescription.text=""
                        //navigate to the chat view controller
                        self.performSegue(withIdentifier: "registerToMM", sender: self)
                    }
                   
                }
            }
            else{
                errorDescription.text="Passwords don't match"
            }
            
        } else{
            errorDescription.text="Please enter all fields"
        }
        
    }
    @IBOutlet weak var confirmPassword: UITextField!
    func animateRegister(){
        for i in 0..<register.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                self.registerText.text! += self.register[i]
            }
        }
        
        
        
        
        
    }
    
    func blurRegisterandRegisterImage(){
        UIView.animate(withDuration: 2.0, animations: {
            self.registerText.alpha=1.0
            self.registerImageLeading.constant = 0
            self.registerImage.alpha=1.0
        })
    }
    

   

}
