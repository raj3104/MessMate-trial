import UIKit
import FirebaseFirestore

class UserDetailsViewController: UIViewController {
    var userId: String?

    @IBOutlet weak var userName: UITextField!
    
    // Hostel selection buttons
    @IBOutlet weak var girlsHostelButton: UIButton!
    @IBOutlet weak var boysHostelButton: UIButton!
    
    // Mess selection buttons
    @IBOutlet weak var crclButton: UIButton!
    @IBOutlet weak var safalButton: UIButton!
    @IBOutlet weak var mayuriButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!

    // Variables to track selections
    var selectedHostel: String?
    var selectedMess: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        girlsHostelButton.addTarget(self, action: #selector(hostelSelected(_:)), for: .touchUpInside)
        boysHostelButton.addTarget(self, action: #selector(hostelSelected(_:)), for: .touchUpInside)
        crclButton.addTarget(self, action: #selector(messSelected(_:)), for: .touchUpInside)
        safalButton.addTarget(self, action: #selector(messSelected(_:)), for: .touchUpInside)
        mayuriButton.addTarget(self, action: #selector(messSelected(_:)), for: .touchUpInside)
        
        userName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        doneButton.isEnabled = true  // ✅ Always enabled
        doneButton.alpha = 1.0
    }

    // MARK: - Hostel Selection
    @objc func hostelSelected(_ sender: UIButton) {
        selectedHostel = sender.currentTitle
        
        // Visually indicate selection
        girlsHostelButton.alpha = sender == girlsHostelButton ? 1.0 : 0.4
        boysHostelButton.alpha = sender == boysHostelButton ? 1.0 : 0.4
    }
    @IBAction func hostelButtonSelected(_ sender: UIButton) {
        selectedHostel=sender.currentTitle
    }
    
    @IBAction func messButtonSelected(_ sender: UIButton){
        selectedMess=sender.currentTitle
        
    }

    @objc func messSelected(_ sender: UIButton) {
        selectedMess = sender.currentTitle
        
        // Visually indicate selection
        crclButton.alpha = sender == crclButton ? 1.0 : 0.5
        safalButton.alpha = sender == safalButton ? 1.0 : 0.5
        mayuriButton.alpha = sender == mayuriButton ? 1.0 : 0.5
    }
    
    @objc func textFieldChanged() {
        // No need to disable the button anymore
    }

    // MARK: - Save User Details
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if userId == nil {
            print("❌ Error: userId is nil")
            return
        }

        if userName.text?.isEmpty ?? true {
            print("❌ Error: Name field is empty")
        }

        if selectedHostel == nil {
            print("❌ Error: No hostel selected")
        }

        if selectedMess == nil {
            print("❌ Error: No mess selected")
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId!)

        let userDetails: [String: Any] = [
            "name": userName.text ?? "Unknown",
            "details": [
                "detail_number_1": ["hostel": selectedHostel ?? "Not Selected", "mess": selectedMess ?? "Not Selected"]
            ]
        ]

        userRef.setData(userDetails) { error in
            if let error = error {
                print("❌ Error saving details: \(error.localizedDescription)")
            } else {
                print("✅ User details saved successfully!")
                //self.navigationController?.popViewController(animated: true)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let userDetailsVC = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as? AccountViewController {
                    //userDetailsVC.userId = self.userId
                    self.navigationController?.pushViewController(userDetailsVC, animated: true)
                } else {
                    print("❌ Error: UserDetailsViewController not found in storyboard")
                }
            }
        }
    }
}
