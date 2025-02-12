import UIKit
import ObjectiveC

private var activityIndicatorKey: UInt8 = 0
private var originalTitleKey: UInt8 = 0
private var originalWidthKey: UInt8 = 0

extension UIButton {
    
    private var activityIndicator: UIActivityIndicatorView {
        get {
            if let indicator = objc_getAssociatedObject(self, &activityIndicatorKey) as? UIActivityIndicatorView {
                return indicator
            } else {
                let indicator = UIActivityIndicatorView(style: .medium)
                indicator.color = self.titleColor(for: .normal)
                indicator.hidesWhenStopped = true
                indicator.translatesAutoresizingMaskIntoConstraints = false
                objc_setAssociatedObject(self, &activityIndicatorKey, indicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return indicator
            }
        }
    }
    
    private var originalTitle: String? {
        get { return objc_getAssociatedObject(self, &originalTitleKey) as? String }
        set { objc_setAssociatedObject(self, &originalTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var originalWidth: CGFloat {
        get { return (objc_getAssociatedObject(self, &originalWidthKey) as? CGFloat) ?? self.frame.width }
        set { objc_setAssociatedObject(self, &originalWidthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func startLoading() {
        originalWidth = self.frame.width
        originalTitle = self.title(for: .normal)
        
        self.setTitle("", for: .normal)
        self.isUserInteractionEnabled = false
        
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layer.cornerRadius = self.frame.height / 2
            self.frame.size.width = self.frame.height
            self.layoutIfNeeded()
        }) { _ in
            self.activityIndicator.startAnimating()
        }
    }
    
    func stopLoading(success: Bool) {
        activityIndicator.stopAnimating()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.size.width = self.originalWidth
            self.layer.cornerRadius = 10
            self.layoutIfNeeded()
        }) { _ in
            self.setTitle(self.originalTitle, for: .normal)
            self.isUserInteractionEnabled = true
            
            if !success {
                UIView.animate(withDuration: 0.2, animations: {
                    self.backgroundColor = .systemRed
                }) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.backgroundColor = .label
                    }
                }
            }
        }
    }
}
