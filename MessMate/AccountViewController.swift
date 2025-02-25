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
    
    @IBOutlet weak var blurView: UIView!
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
        tableView.separatorStyle = .none
        tableView.isUserInteractionEnabled = false


        addBlurEffect()
        self.mealImage.alpha = 0
        self.mealImage.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
          
          // Animate appearance smoothly
          UIView.animate(withDuration: 1.2, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut) {
              self.mealImage.alpha = 1
              self.mealImage.transform = CGAffineTransform.identity
          }

        tableView.delegate = self
        tableView.dataSource = self

        let defaultMeal = determineNextMeal()
        mealButton.setTitle(defaultMeal, for: .normal)
        mealImage.image = UIImage(imageLiteralResourceName: defaultMeal)
        resetButton(weekButton)
        

        fetchUserDetails()
        // ✅ Get user details
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
                            self.messSelector.setTitle("RasSense", forSegmentAt: 2)
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
        } else if userMess == "CRCL" {
            messSelector.selectedSegmentIndex = 2
        } else if userMess == "JMB" {  // ✅ Handle JMB Selection
            messSelector.selectedSegmentIndex = 3
        }
    }



    func animateGreet(username: String) {
        // Extract first name (everything before the first whitespace)
        let firstName = username.components(separatedBy: " ").first ?? username
        
        let fullGreeting = "Hello, " + firstName.prefix(1).uppercased() + firstName.dropFirst()
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
    func fetchMessDetails(for selectedDay: String? = nil) {
        guard !userMess.isEmpty, !userHostel.isEmpty else {
            print("❌ No valid hostel or mess information available")
            return
        }

        let selectedMeal = mealButton.title(for: .normal) ?? "Breakfast"
        let currentDay = selectedDay ?? daysOfWeek[(Calendar.current.component(.weekday, from: Date()) - 1 + 6) % 7]

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
    
    @IBOutlet weak var weekButton: UIButton!
    
    
    @IBAction func weekButtonHandler(_ sender: Any) {
        let alert = UIAlertController(title: "Select a Day", message: nil, preferredStyle: .actionSheet)

        for day in daysOfWeek {
               alert.addAction(UIAlertAction(title: day, style: .default, handler: { action in
                   var selectedDay = day
                   self.weekButton.setTitle(String(selectedDay.prefix(3)), for: .normal)
                   
                   let shortDay = String(day.prefix(3)) // Extract first 3 letters
                   self.fetchMessDetails(for: selectedDay)
               }))
           }

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

           // **Fix for iPad**
           if let popoverController = alert.popoverPresentationController {
               popoverController.sourceView = sender as? UIView
               popoverController.sourceRect = (sender as AnyObject).bounds
               popoverController.permittedArrowDirections = .any
           }

           present(alert, animated: true)
    }
    
    
    func sfCode(for day:String=""){
        var currentMeal=determineNextMeal()
        if(day != ""){
            if(day=="Breakfast"){
                mealImage.image=UIImage(systemName: "sunrise.fill")
            }
            else if(day=="Lunch"){
                mealImage.image=UIImage(systemName: "sun.max")
            }
            else if(day=="Snacks"){
                mealImage.image=UIImage(systemName: "sunset.fill")
            }
            else{
                mealImage.image=UIImage(systemName: "moon.fill")
            }
            
        }
        else{
            if(currentMeal=="Breakfast"){
                mealImage.image=UIImage(systemName: "sunrise.fill")
            }
            else if(currentMeal=="Lunch"){
                mealImage.image=UIImage(systemName: "sun.max")
            }
            else if(currentMeal=="Snacks"){
                mealImage.image=UIImage(systemName: "sunset.fill")
            }
            else{
                mealImage.image=UIImage(systemName: "moon.fill")
            }
            
        }
       
        
        
    }
    
    
    
    @IBAction func resetButton(_ sender: UIButton) {
        let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
           let today = daysOfWeek[(todayIndex + 6) % 7] // Ensure Sunday = 6, Monday = 0
           let defaultMeal = determineNextMeal() // Get the next meal

        weekButton.setTitle(String(today.prefix(3)), for: .normal) // Reset week button
           mealButton.setTitle(defaultMeal, for: .normal) // Reset meal button
        sfCode()
        animateMealImage()
           fetchMessDetails(for: today) // Load data for today
    }
    
    @IBAction func hostelSelector(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { // Boys Hostel Selected
            userHostel = "Boys Hostel"
            hostelSelectorInfo.selectedSegmentTintColor = UIColor.systemBlue

            // ✅ Update Mess Selector for Boys Hostel
            messSelector.setTitle("RasSense", forSegmentAt: 2)
            messSelector.setTitle("JMB", forSegmentAt: 3)  // ✅ JMB Added
            messSelector.setTitle("Safal", forSegmentAt: 1)
            messSelector.setEnabled(true, forSegmentAt: 1)
            messSelector.setEnabled(true, forSegmentAt: 3)

            // Default Mess for Boys
            userMess = "Mayuri"
            messSelector.selectedSegmentIndex = 0

        } else { // Girls Hostel Selected
            userHostel = "Girls Hostel"
            hostelSelectorInfo.selectedSegmentTintColor = UIColor.systemPink

            // ✅ Rename CRCL → AB Catering & Hide JMB & Safal
            messSelector.setTitle("AB Catering", forSegmentAt: 2)
            messSelector.setEnabled(false, forSegmentAt: 1)
            messSelector.setTitle("", forSegmentAt: 1)
            messSelector.setEnabled(false, forSegmentAt: 3)
            messSelector.setTitle("", forSegmentAt: 3)  // Hide JMB

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

        // First, delete all subcollections (if any)
        deleteAllSubcollections(for: userRef) { success in
            if success {
                // Now delete the main user document
                userRef.delete { error in
                    if let error = error {
                        print("❌ Error deleting Firestore user document: \(error.localizedDescription)")
                        return
                    }
                    print("✅ Firestore user document deleted.")

                    // Finally, delete the Firebase Auth account
                    user.delete { error in
                        if let error = error {
                            print("❌ Error deleting Firebase Auth account: \(error.localizedDescription)")
                        } else {
                            print("✅ User account deleted successfully.")
                            self.navigateToLogin()
                        }
                    }
                }
            } else {
                print("❌ Error deleting user subcollections.")
            }
        }
    }
    
    
    func deleteAllSubcollections(for documentRef: DocumentReference, completion: @escaping (Bool) -> Void) {
        documentRef.collection("user_data").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching subcollection: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            let batch = self.db.batch()
            
            snapshot?.documents.forEach { doc in
                batch.deleteDocument(doc.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("❌ Error deleting subcollection: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Subcollection deleted successfully.")
                    completion(true)
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
            userMess = "RasSense"
        case 3:
            userMess = "JMB"  // ✅ Added JMB as Segment 3
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
                self.sfCode(for: option)
                self.fetchMessDetails()
                self.animateMealImage() // Call animation after meal change
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

    
    func animateMealImage() {
        // Apply a flip transition animation
        UIView.transition(with: mealImage, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.mealImage.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.4) {
                self.mealImage.alpha = 1
            }
        }

        // Add a bounce effect
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: []) {
            self.mealImage.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.mealImage.transform = CGAffineTransform.identity
            }
        }
    }

    
    func addBlurEffect() {
            let blurEffect = UIBlurEffect(style: .systemMaterial) // System background color effect
            let blurView = UIVisualEffectView(effect: blurEffect)
            
            blurView.frame = view.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false

            view.addSubview(blurView)
            
            self.blurView = blurView
            
            // Animate blur fading out in 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() ) { // Delay start for visibility
                UIView.animate(withDuration: 0.75) {
                    blurView.effect = nil // Remove blur smoothly
                }
               
            }
        }


}
