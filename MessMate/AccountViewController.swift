import UIKit
import FirebaseFirestore
import FirebaseAuth

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var userName=[String]()
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealButton: UIButton!
    @IBOutlet weak var nextMealLabel: UILabel!
    
    var messData: [String: [String]] = [:]
    var userHostel: String = ""
    var userMess: String = ""
    let db = Firestore.firestore()
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let options = ["Breakfast", "Lunch", "Snacks", "Dinner"]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesBackButton = true
        
    }

    @IBOutlet weak var hostelSelectorInfo: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        let defaultMeal = determineNextMeal()
        mealButton.setTitle(defaultMeal, for: .normal)
        mealImage.image = UIImage(imageLiteralResourceName: defaultMeal)

        fetchUserDetails() // ✅ Get user details
    }

    func fetchUserDetails() {
        guard let user = Auth.auth().currentUser else { return }
        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                let name = data["name"] as? String ?? "User"

                if let details = data["details"] as? [String: Any],
                   let detail1 = details["detail_number_1"] as? [String: Any] {
                    self.userHostel = detail1["hostel"] as? String ?? ""
                    self.userMess = detail1["mess"] as? String ?? "Mayuri"

                    DispatchQueue.main.async {
                        if self.userHostel == "Girls Hostel" {
                            self.hostelSelectorInfo.selectedSegmentIndex = 1
                            self.hostelSelectorInfo.selectedSegmentTintColor = UIColor.systemPink

                            // ✅ Rename CRCL → AB Catering & Hide Safal
                            self.messSelector.setTitle("AB Catering", forSegmentAt: 2)
                            self.messSelector.setEnabled(false, forSegmentAt: 1)

                            // ✅ If stored mess is AB Catering, select it by default
                            if self.userMess == "AB Catering" {
                                self.messSelector.selectedSegmentIndex = 2
                            } else {
                                self.messSelector.selectedSegmentIndex = 0 // Default to Mayuri
                            }

                        } else {
                            self.hostelSelectorInfo.selectedSegmentIndex = 0
                            self.hostelSelectorInfo.selectedSegmentTintColor = UIColor.systemBlue
                            self.messSelector.setTitle("CRCL", forSegmentAt: 2)
                            self.messSelector.setEnabled(true, forSegmentAt: 1)
                           
                        }

                        self.updateMessSelector() // ✅ Ensure selector is refreshed
                    }
                }

                self.animateGreet(username: name)
                self.fetchMessDetails()
            }
        }
    }

    @IBOutlet weak var messSelector: UISegmentedControl!
    func updateMessSelector() {
        if userMess == "Mayuri" {
            messSelector.selectedSegmentIndex = 0
        } else if userMess == "Safal" {
            messSelector.selectedSegmentIndex = 1
        } else if userMess == "CRCL" || userMess == "AB Catering" { // ✅ Handle both cases
            messSelector.selectedSegmentIndex = 2
            messSelector.setTitle("AB Catering", forSegmentAt: 2) // Ensure name is updated
        }
    }


    func animateGreet(username: String) {
        let words = username.components(separatedBy: " ").map { word in
            return word.prefix(1).uppercased() + word.dropFirst()
        }
        
        let fullGreeting = "Hello, " + words.joined(separator: " ")
        greetingLabel.text = "" // Clear label before animation
        
        
        for (index, letter) in fullGreeting.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.1 * Double(index))) {
                self.greetingLabel.text?.append("\(letter)")
                
                
            }
        }
    }

    func determineNextMeal() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 9 {
            return "Breakfast"
        } else if hour < 14 {
            return "Lunch"
        } else if hour < 18 {
            return "Snacks"
        } else {
            return "Dinner"
        }
    }
    func fetchMessDetails() {
        guard !userMess.isEmpty, !userHostel.isEmpty else {
            print("❌ No valid hostel or mess information available")
            return
        }

        let selectedMeal = mealButton.title(for: .normal) ?? "Breakfast"
        let currentDayIndex = Calendar.current.component(.weekday, from: Date()) - 1
        let currentDay = daysOfWeek[(currentDayIndex + 6) % 7]

        // ✅ Fetch data from the correct hostel (Boys or Girls)
        let messRef = db.collection("MessDetails").document(userHostel)

        messRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                print("📌 Firestore Mess Data for \(self.userHostel):", data)

                if let messes = data[self.userMess] as? [String: Any],
                   let dayMeals = messes[currentDay] as? [String: Any],
                   let items = dayMeals[selectedMeal] as? [String] {
                    self.messData[self.userMess] = items
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("❌ No meal data found for \(self.userMess) on \(currentDay)")
                }

            } else {
                print("❌ Error fetching mess data:", error?.localizedDescription ?? "Unknown error")
            }
        }
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return messData.isEmpty ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messData[userMess]?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        if let meals = messData[userMess], !meals.isEmpty {
            cell.textLabel?.text = meals[indexPath.row]
        } else {
            cell.textLabel?.text = "No menu available"
        }
        
        return cell
    }
    @IBAction func deleteButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteAccount()
        }))
        
        present(alert, animated: true)
    }
    
    
    
    
    @IBAction func hostelSelector(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { // Boys Hostel Selected
            userHostel = "Boys Hostel"
            hostelSelectorInfo.selectedSegmentTintColor = UIColor.systemBlue

            // Reset Mess Selector to show CRCL and Safal
            messSelector.setTitle("CRCL", forSegmentAt: 2)
            messSelector.setEnabled(true, forSegmentAt: 1)

            // Default Mess for Boys
            userMess = "Mayuri"
            messSelector.selectedSegmentIndex = 0

        } else { // Girls Hostel Selected
            userHostel = "Girls Hostel"
            hostelSelectorInfo.selectedSegmentTintColor = UIColor.systemPink

            // Rename CRCL → AB Catering & Hide Safal
            messSelector.setTitle("AB Catering", forSegmentAt: 2)
            messSelector.setEnabled(false, forSegmentAt: 1) // Disable Safal

            // Default Mess for Girls
            userMess = "AB Catering"
            messSelector.selectedSegmentIndex = 2
        }

        // ✅ Fetch new data from Firestore for the selected hostel
        fetchMessDetails()
    }

    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let userRef = db.collection("users").document(user.uid)

        userRef.delete { error in
            if let error = error {
                print("❌ Error deleting Firestore data: \(error.localizedDescription)")
                return
            }
            print("✅ Firestore user data deleted successfully.")

            user.delete { error in
                if let error = error {
                    print("❌ Error deleting Firebase Auth account: \(error.localizedDescription)")
                } else {
                    print("✅ User deleted successfully.")
                    self.navigateToLogin()
                }
            }
        }
    }
    @IBAction func messSelector(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            userMess = "Mayuri"
        case 1:
            userMess = "Safal"
        case 2:
            userMess = "CRCL"
        default:
            return
        }
        fetchMessDetails() // Refresh mess menu after selection
    }

    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigateToLogin()
        } catch let signOutError as NSError {
            print("❌ Error signing out: %@", signOutError)
        }
    }

    func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    @IBAction func mealButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select a Meal", message: nil, preferredStyle: .actionSheet)

        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { action in
                self.mealButton.setTitle(option, for: .normal)
                self.mealImage.image = UIImage(imageLiteralResourceName: option)
                self.fetchMessDetails()
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // **Fix for iPad**
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .any
        }

        present(alert, animated: true)
    }

}
