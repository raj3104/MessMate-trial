import UIKit

class ViewController: UIViewController {
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateLoader()
        animateDesigns()
    }

    @IBOutlet weak var mainLogoView: UIView!
    @IBOutlet weak var leftDesignBottom: NSLayoutConstraint!
    @IBOutlet weak var rightDesignTop: NSLayoutConstraint!
    @IBOutlet weak var rightDesign: UIView!
    @IBOutlet weak var leftDesign: UIView!
    @IBOutlet weak var logoMain: UIImageView!
    @IBOutlet weak var loaderImageTop: NSLayoutConstraint!
    @IBOutlet weak var loaderImage: UIImageView!
    @IBOutlet weak var logoMainTop: NSLayoutConstraint!
    
    func animateLoader() {
        self.loaderImageTop.constant = -300
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.7, animations: {
            self.loaderImageTop.constant = self.view.bounds.height
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.loaderImageTop.constant = -300
            self.view.layoutIfNeeded()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.animateLoader()
            }
        })
    }
    
    func animateDesigns() {
        let moveDistance = mainLogoView.bounds.height
        
        self.view.layoutIfNeeded()
        leftDesignBottom.constant = 0
        rightDesignTop.constant = 0
        
        
        // Move leftDesign up
        UIView.animate(withDuration: 3.0, animations: {
            self.leftDesignBottom.constant = moveDistance-100
            self.rightDesignTop.constant = moveDistance-100
            self.rightDesign.alpha=1.0
            self.leftDesign.alpha=1.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 3.0, animations: {
                self.leftDesignBottom.constant = -(moveDistance-100)
                self.rightDesignTop.constant = -(moveDistance-100)
//                self.rightDesign.alpha=0.4
//                self.leftDesign.alpha=0.4
                self.view.layoutIfNeeded()
                
            })
           
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.animateDesigns()
            }
        })
        
        // Move rightDesign down
    }
}
