import UIKit

class LoginRegisterViewViewController: UIViewController {
    var login = ["L","o","g","i","n"," ","/"," ","R","e","g","i","s","t","e","r"]

    @IBOutlet weak var loginRegisterview: UIView!
    @IBOutlet weak var registerTop: NSLayoutConstraint!
    @IBOutlet weak var loginTop: NSLayoutConstraint!
    @IBOutlet weak var backButton: UINavigationItem!
    @IBOutlet weak var loginRegister: UILabel!

    @IBOutlet weak var blurText: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar (fixing the back button issue)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        loginRegister.alpha=0.1
        
        // Start text animation
        loginRegister.text = ""
        loginAnimate()
        designAnimate()
    }

    func loginAnimate() {
        
        for i in 0..<login.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                self.loginRegister.text! += self.login[i]
            }
        }
        blurTextAnimate()
        
    }
    
    func designAnimate(){
        loginTop.constant=0
        registerTop.constant=0
        UIView.animate(withDuration: 2.0, animations: {
            self.loginTop.constant=self.loginRegisterview.frame.height-100
            self.registerTop.constant=self.loginRegisterview.frame.height-100
            self.view.layoutIfNeeded()
        })
    }
    
    func blurTextAnimate(){
        UIView.animate(withDuration: 5.0, animations: {
            self.loginRegister.alpha=1.0
        })
    }
}
