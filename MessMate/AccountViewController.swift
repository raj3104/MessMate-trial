import UIKit
import FirebaseFirestore
import FirebaseAuth

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var nextMealLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mealImage: UIImageView!
    
    var messData: [String: [String:  [String: [String]]]] = [:] // Mess name -> Meals -> Day -> Meal items
    var expandedMess: Set<String> = [] // Tracks expanded cells
    let db = Firestore.firestore()
    let messNames = ["Mayuri", "Safal", "CRCL", "AB"]
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchUserDetails()
        determineNextMeal()
        fetchMessDetails()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func fetchUserDetails() {
        guard let user = Auth.auth().currentUser else { return }
        let userRef = db.collection("users").document(user.uid)
        userRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data(), let name = data["name"] as? String {
                self.greetingLabel.text = "Hello, \(name)"
            } else {
                self.greetingLabel.text = "Hello!"
            }
        }
    }
    
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
    
    func fetchMessDetails() {
        let nextMeal = nextMealLabel.text ?? "Breakfast"
        let currentDay = daysOfWeek[Calendar.current.component(.weekday, from: Date()) - 1]
        
        for mess in messNames {
            let messRef = db.collection("MessDetails").document(mess)
            messRef.getDocument { document, error in
                if let document = document, document.exists, let data = document.data() {
                    print("📌 Firestore Data for \(mess):", data) // Debugging
                    
                    if let meals = data["meals"] as? [String: [String: [String]]],
                       let dayMeals = meals[nextMeal],
                       let items = dayMeals[currentDay] {
                        
                        if self.messData[mess] == nil {
                            self.messData[mess] = [:]
                        }
                        if self.messData[mess]?[nextMeal] == nil {
                            self.messData[mess]?[nextMeal] = [:]
                        }
                        self.messData[mess]?[nextMeal]?[currentDay] = items
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    print("❌ No data found for \(mess)")
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return max(messData.keys.count, 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let messKeys = Array(messData.keys)
        guard section < messKeys.count else { return 1 }

        let messName = messKeys[section]
        let nextMeal = nextMealLabel.text ?? "Breakfast"
        let currentDay = daysOfWeek[Calendar.current.component(.weekday, from: Date()) - 1]
        
        return expandedMess.contains(messName) ? (messData[messName]?[nextMeal]?[currentDay]?.count ?? 0) + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messKeys = Array(messData.keys)
        guard indexPath.section < messKeys.count else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessCell", for: indexPath)
            cell.textLabel?.text = "No data available"
            return cell
        }

        let messName = messKeys[indexPath.section]
        let nextMeal = nextMealLabel.text ?? "Breakfast"
        let currentDay = daysOfWeek[Calendar.current.component(.weekday, from: Date()) - 1]
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessCell", for: indexPath)
            cell.textLabel?.text = "\(messName) - \(currentDay) - \(nextMeal)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
            cell.textLabel?.text = messData[messName]?[nextMeal]?[currentDay]?[indexPath.row - 1] ?? ""
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messKeys = Array(messData.keys)
        guard indexPath.section < messKeys.count else { return }
        
        let messName = messKeys[indexPath.section]
        if indexPath.row == 0 {
            if expandedMess.contains(messName) {
                expandedMess.remove(messName)
            } else {
                expandedMess.insert(messName)
            }
            tableView.reloadSections([indexPath.section], with: .automatic)
        }
    }
}
