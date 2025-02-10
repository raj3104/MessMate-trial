import UIKit
import FirebaseFirestore
import FirebaseAuth

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var nextMealLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mealImage: UIImageView!
    
    var messData: [String: [String]] = [:] // Mess name -> Meal items
    var userHostel: String = ""
    var userMess: String = ""
    let db = Firestore.firestore()
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    override func viewDidAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchUserDetails()
    }

    /// Fetch user details (name, hostel, mess)
    func fetchUserDetails() {
        guard let user = Auth.auth().currentUser else { return }
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                print("📌 Firestore User Data:", data) // Debugging
                
                let name = data["name"] as? String ?? "User"
                if let details = data["details"] as? [String: Any],
                   let detail1 = details["detail_number_1"] as? [String: Any] {
                    self.userHostel = detail1["hostel"] as? String ?? ""
                    self.userMess = detail1["mess"] as? String ?? ""
                } else {
                    print("❌ No 'details.detail_number_1' found in Firestore")
                }

                print("🏠 Hostel: \(self.userHostel), 🍽 Mess: \(self.userMess)") // Debugging
                
                self.greetingLabel.text = "Hello, \(name)"
                self.determineNextMeal()
                self.fetchMessDetails()
            } else {
                print("❌ Error fetching user document:", error?.localizedDescription ?? "Unknown error")
                self.greetingLabel.text = "Hello!"
            }
        }
    }


    /// Determine the next meal based on the current time
    func determineNextMeal() {
        let hour = Calendar.current.component(.hour, from: Date())
        let nextMeal: String
        if hour < 9 {
            nextMeal = "Breakfast"
        } else if hour < 14 {
            nextMeal = "Lunch"
        } else if hour < 18 {
            nextMeal = "Snacks"
        } else {
            nextMeal = "Dinner"
        }
        nextMealLabel.text = nextMeal
    }

    /// Fetch mess details based on user hostel and mess
    func fetchMessDetails() {
        guard !userMess.isEmpty, !userHostel.isEmpty else {
            print("❌ No valid hostel or mess information available")
            return
        }

        let nextMeal = nextMealLabel.text ?? "Breakfast"
        let currentDayIndex = Calendar.current.component(.weekday, from: Date()) - 1
        let currentDay = daysOfWeek[(currentDayIndex + 6) % 7] 
        
        let messRef = db.collection("MessDetails").document(userHostel)
        
        messRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                print("📌 Firestore Mess Data for \(self.userHostel):", data) // Debugging

                if let messes = data[self.userMess] as? [String: Any],
                   let dayMeals = messes[currentDay] as? [String: Any],
                   let items = dayMeals[nextMeal] as? [String] {  // 👈 Explicitly cast to [String]

                    self.messData[self.userMess] = items  // ✅ Assign properly

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


    // MARK: - TableView Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return messData.keys.count > 0 ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messData[userMess]?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        if let meals = messData[userMess], meals.count > 0 {
            cell.textLabel?.text = meals[indexPath.row]
        } else {
            cell.textLabel?.text = "No menu available"
        }

        return cell
    }
}
