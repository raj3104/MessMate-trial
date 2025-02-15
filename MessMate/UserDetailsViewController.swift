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
    @IBOutlet weak var loaderUserDetails: UIActivityIndicatorView!

    // Variables to track selections
    var selectedHostel: String?
    var selectedMess: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Disable the Done button initially
        doneButton.isEnabled = false
        doneButton.alpha = 0.5
        
        // Hide the loader initially
        loaderUserDetails.isHidden = true

        // Setup gesture to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesBackButton = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        doneButton.isEnabled = true  // Enable button when leaving
        doneButton.alpha = 1.0
    }

    // MARK: - Keyboard Handling
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Hostel Selection
    // MARK: - Hostel Selection
    @IBAction func hostelButtonSelected(_ sender: UIButton) {
        selectedHostel = sender.currentTitle

        if selectedHostel == "Girls Hostel" {
            crclButton.setTitle("AB Catering", for: .normal) // Rename CRCL
            crclButton.isEnabled = true
            crclButton.alpha = 1.0

            safalButton.isEnabled = false
            safalButton.isHidden=true
            safalButton.alpha = 0.3

            mayuriButton.isEnabled = true  // ✅ Ensure Mayuri is enabled
            mayuriButton.alpha = 1.0       // ✅ Make sure it's fully visible
        } else { // Boys Hostel selected
            crclButton.setTitle("CRCL", for: .normal) // Reset name
            crclButton.isEnabled = true
            crclButton.alpha = 1.0

            safalButton.isEnabled = true
            safalButton.isHidden=false
            safalButton.alpha = 1.0

            mayuriButton.isEnabled = true  // ✅ Ensure Mayuri is enabled
            mayuriButton.alpha = 1.0       // ✅ Make sure it's fully visible
        }

        // Visually indicate hostel selection
        girlsHostelButton.alpha = sender == girlsHostelButton ? 1.0 : 0.4
        boysHostelButton.alpha = sender == boysHostelButton ? 1.0 : 0.4

        validateForm()
    }


    // MARK: - Mess Selection
    @IBAction func messButtonSelected(_ sender: UIButton) {
        // Prevent selection of disabled buttons
        if !sender.isEnabled { return }
        
        selectedMess = sender.currentTitle

        // Reset all buttons to default transparency
        crclButton.alpha = 0.5
        safalButton.alpha = 0.5
        mayuriButton.alpha = 0.5

        // Highlight the selected mess button
        sender.alpha = 1.0

        validateForm()
    }

    // MARK: - Text Field Change
    @IBAction func textFieldChanged(_ sender: UITextField) {
        validateForm()
    }

    // MARK: - Validate Form & Enable Done Button
    func validateForm() {
        if let name = userName.text, !name.isEmpty, selectedHostel != nil, selectedMess != nil {
            doneButton.isEnabled = true
            doneButton.alpha = 1.0
        } else {
            doneButton.isEnabled = false
            doneButton.alpha = 0.5
        }
    }

    // MARK: - Save User Details
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        guard let userId = userId else {
            print("❌ Error: userId is nil")
            return
        }

        guard let name = userName.text, !name.isEmpty else {
            print("❌ Error: Name field is empty")
            return
        }

        guard let hostel = selectedHostel else {
            print("❌ Error: No hostel selected")
            return
        }

        guard let mess = selectedMess else {
            print("❌ Error: No mess selected")
            return
        }

        // Disable the button and show loader
        doneButton.isEnabled = false
        doneButton.alpha = 0.5
        loaderUserDetails.isHidden = false
        loaderUserDetails.startAnimating()

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        let userDetails: [String: Any] = [
            "name": name,
            "details": [
                "detail_number_1": ["hostel": hostel, "mess": mess]
            ]
        ]

        userRef.setData(userDetails) { error in
            DispatchQueue.main.async {
                self.loaderUserDetails.stopAnimating()
                self.loaderUserDetails.isHidden = true
                self.doneButton.isEnabled = true
                self.doneButton.alpha = 1.0
            }

            if let error = error {
                print("❌ Error saving details: \(error.localizedDescription)")
            } else {
                print("✅ User details saved successfully!")

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let accountVC = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as? AccountViewController {
                    self.navigationController?.pushViewController(accountVC, animated: true)
                } else {
                    print("❌ Error: AccountViewController not found in storyboard")
                }
            }
        }
    }
}
