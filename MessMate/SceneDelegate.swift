import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
               let window = UIWindow(windowScene: windowScene)
        let user = Auth.auth().currentUser
               
               if Auth.auth().currentUser == nil {
                   let vc = ViewController()
                   let navVc = UINavigationController(rootViewController: vc)
                   window.rootViewController=navVc
               }
               else{
                   checkUserDetailsAndProceed(user: user!, window: window)
               }
    }

    private func checkUserDetailsAndProceed(user: User, window: UIWindow) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                print("✅ User details found. Proceeding to AccountViewController.")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let accountVC = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as? AccountViewController {
                    window.rootViewController = UINavigationController(rootViewController: accountVC)
                }
                
            } else {
                print("❌ No user details found. Deleting account...")
                self.deleteUserAccount(user, window: window)
            }
            self.window = window
            window.makeKeyAndVisible()
        }
    }


    private func deleteUserAccount(_ user: User, window: UIWindow) {
        user.delete { error in
            if let error = error {
                print("⚠️ Error deleting user: \(error.localizedDescription)")
            } else {
                print("✅ User account deleted successfully. Redirecting to login.")
                DispatchQueue.main.async {
                    let vc = ViewController()
                    let navVc = UINavigationController(rootViewController: vc)
                    window.rootViewController = navVc
                }
            }
        }
    }
}
