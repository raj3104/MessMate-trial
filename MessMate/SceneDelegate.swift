import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        if let user = Auth.auth().currentUser {
            checkUserDetailsAndProceed(user: user, window: window)
        } else {
            navigateToLogin(window: window)
        }
    }

    private func checkUserDetailsAndProceed(user: User, window: UIWindow) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                print("✅ User details found. Proceeding to AccountViewController.")
                self.navigateToAccount(window: window)
            } else {
                print("❌ No user details found. Deleting account...")
                self.deleteUserAccount(user, window: window)
            }
        }
    }

    private func deleteUserAccount(_ user: User, window: UIWindow) {
        user.delete { error in
            if let error = error {
                print("⚠️ Error deleting user: \(error.localizedDescription)")
                self.navigateToLogin(window: window) // If deletion fails, go to login
            } else {
                print("✅ User account deleted successfully. Redirecting to login.")
                DispatchQueue.main.async {
                    self.navigateToLogin(window: window)
                }
            }
        }
    }

    private func navigateToLogin(window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            window.rootViewController = UINavigationController(rootViewController: loginVC)
            self.window = window
            window.makeKeyAndVisible()
        } else {
            print("❌ Error: Could not instantiate ViewController from storyboard.")
        }
    }

    private func navigateToAccount(window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let accountVC = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as? AccountViewController {
            window.rootViewController = UINavigationController(rootViewController: accountVC)
            self.window = window
            window.makeKeyAndVisible()
        } else {
            print("❌ Error: Could not instantiate AccountViewController from storyboard.")
        }
    }
}
