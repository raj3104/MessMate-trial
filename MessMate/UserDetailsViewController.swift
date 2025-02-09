import UIKit
import FirebaseFirestore
import FirebaseAuth

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 doneButton: \(String(describing: doneButton))")
        doneButton.isEnabled = false
        doneButton.alpha = 0.5
        girlsHostelButton.addTarget(self, action: #selector(hostelSelected(_:)), for: .touchUpInside)
        boysHostelButton.addTarget(self, action: #selector(hostelSelected(_:)), for: .touchUpInside)
        crclButton.addTarget(self, action: #selector(messSelected(_:)), for: .touchUpInside)
        safalButton.addTarget(self, action: #selector(messSelected(_:)), for: .touchUpInside)
        mayuriButton.addTarget(self, action: #selector(messSelected(_:)), for: .touchUpInside)
        
        userName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        // Disable done button initially
//        doneButton.isEnabled = false
//        doneButton.alpha = 0.5
        
        // Add targets for buttons
      
    }

    // MARK: - Hostel Selection
    @objc func hostelSelected(_ sender: UIButton) {
        selectedHostel = sender.currentTitle

        // Visually indicate selection
        girlsHostelButton.alpha = sender == girlsHostelButton ? 1.0 : 0.4
        boysHostelButton.alpha = sender == boysHostelButton ? 1.0 : 0.4

        validateForm() // ✅ Ensure doneButton updates
    }

    @objc func messSelected(_ sender: UIButton) {
        selectedMess = sender.currentTitle

        // Ensure button highlights are properly updated
        crclButton.isSelected = (sender == crclButton)
        safalButton.isSelected = (sender == safalButton)
        mayuriButton.isSelected = (sender == mayuriButton)

        // Visually indicate selection
        crclButton.alpha = sender == crclButton ? 1.0 : 0.5
        safalButton.alpha = sender == safalButton ? 1.0 : 0.5
        mayuriButton.alpha = sender == mayuriButton ? 1.0 : 0.5

        validateForm() // ✅ Ensure doneButton updates
    }

    
    // MARK: - Enable/Disable Done Button
    @objc func textFieldChanged() {
        validateForm()
    }
    
    func validateForm() {
        print("Checking form validation...")
        print("UserName: \(userName.text ?? "")")
        print("Hostel Selected: \(selectedHostel ?? "None")")
        print("Mess Selected: \(selectedMess ?? "None")")

        let isFormValid = !(userName.text?.isEmpty ?? true) && selectedHostel != nil && selectedMess != nil
        print("Form Valid: \(isFormValid)")

        doneButton.isEnabled = isFormValid
        doneButton.alpha = isFormValid ? 1.0 : 0.5
    }

    // MARK: - Save User Details
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        guard let name = userName.text, let hostel = selectedHostel, let mess = selectedMess else {
            print("All fields are required")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        let userDetails: [String: Any] = [
            "name": name,
            "details": [
                "detail_number_1": ["hostel": hostel, "mess": mess]
            ]
        ]

        userRef.setData(userDetails) { error in
            if let error = error {
                print("Error saving details: \(error.localizedDescription)")
            } else {
                print("User details saved successfully!")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func hostelButtonSelected(_ sender: UIButton) {
        }
    
    @IBAction func messButtonSelected(_ sender: UIButton) {
       }
}
