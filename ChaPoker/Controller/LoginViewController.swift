//
//  ViewController.swift
//  ChaPoker
//
//  Created by Elad Sabag on 29/06/2023.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var loginManager: LoginManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        loginManager = LoginManager()
        loginManager?.delegate = self
    }
    
    func animateWelcomeLabel() {
        welcomeLabel.text = ""
        var charIndex = 0.0
        let titleText = "Welcome to ChaPoker"
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                    self.welcomeLabel.text?.append(letter)
                }
                  charIndex += 1
              }
    }
    
    func setLogginButton() {
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
        //loginButton.permissions = ["public_profile", "email"]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateWelcomeLabel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Retrieve the current user's auth token
            if Auth.auth().currentUser != nil {
                guard let currentUser = Auth.auth().currentUser else { return }
                guard let userID = Auth.auth().currentUser?.uid else { return }
                currentUser.getIDToken(completion: { (token, error) in
                    guard let token = token else {
                        if let error = error {
                            print("Error retrieving auth token: \(error.localizedDescription)")
                        }
                        return
                    }
                    UserDefaultsManager.shared.setUserID(userID)
                    UserDefaultsManager.shared.setAuthToken(token)
                    // Use the auth token
                    print("Auth Token: \(token)")
                    self.loginManager?.getUser(userId: userID)
                })

            } else {
                // No logged-in user
                print("No logged-in user")
                self.setLogginButton()
            }
        }
    }

    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: 30, y: self.view.frame.size.height-100, width: self.view.frame.size.width - 60, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)

        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }

    func initUserFromGraph() {
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        currentUser.getIDToken(completion: { (token, error) in
            guard let token = token else {
                if let error = error {
                    print("Error retrieving auth token: \(error.localizedDescription)")
                }
                return
            }
            UserDefaultsManager.shared.setUserID(userID)
            UserDefaultsManager.shared.setAuthToken(token)
            
            // Fetch user's name and profile picture URL
            let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "name,picture.type(large)"])
            graphRequest.start { (_, result, error) in
                if let error = error {
                    print("Failed to fetch Facebook user information: ", error.localizedDescription)
                    return
                }
                
                if let userData = result as? [String: Any] {
                    if let name = userData["name"] as? String {
                        print("User name: ", name)
                        if let pictureData = userData["picture"] as? [String: Any],
                            let pictureUrlData = pictureData["data"] as? [String: Any],
                            let pictureUrlString = pictureUrlData["url"] as? String,
                            let pictureUrl = URL(string: pictureUrlString) {
                            print("Profile picture URL: ", pictureUrl.absoluteString)
                            self.loginManager?.user = User(
                                userId: userID,
                                name: name,
                                profilePictureUrl: pictureUrl,
                                chips: 100
                            )
                            self.loginManager?.addUser()
                        }
                    }
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "navigateFromLoginToHome" {
            if let destinationVC = segue.destination as? HomeViewController {
                destinationVC.user = loginManager?.user
            }
        }
    }
    
    func retrieveTokenAndUID() {
        if let currentUser = Auth.auth().currentUser {
            currentUser.getIDToken(completion: { (token, error) in
                if let token = token {
                    // Use the auth token
                    print("Auth Token: \(token)")
                    UserDefaultsManager.shared.setAuthToken(token)
                    
                    // Get the user ID
                    let userID = currentUser.uid
                    print("User ID: \(userID)")
                    // Save the user ID if needed
                    UserDefaultsManager.shared.setUserID(userID)
                } else if let error = error {
                    // Handle error
                    print("Error retrieving auth token: \(error.localizedDescription)")
                }
            })
        }
    }
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
          }
        if let accessTokenString = AccessToken.current?.tokenString {
            let credential = FacebookAuthProvider
              .credential(withAccessToken: accessTokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                             print("Facebook authentication with Firebase error: ", error)
                             return
                         }
                print("Login success!")
                self.initUserFromGraph()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {}
}

extension LoginViewController: LoginManagerDelegate {
    
    func onAddUser(isSuccess: Bool) {
        DispatchQueue.main.async {
            if isSuccess {
                print("Success to add user")
                self.performSegue(withIdentifier: "navigateFromLoginToHome", sender: self)
            } else {
                print("Failed to add user")
                self.showToast(message: "An error occurred please try again...")
                UserDefaultsManager.shared.setAuthToken("")
                UserDefaultsManager.shared.setUserID("")
            }
        }
    }
    
    func onFetchUser(isSuccess: Bool) {
        DispatchQueue.main.async {
            if (isSuccess) {
                print("Success to fetch user")
                self.performSegue(withIdentifier: "navigateFromLoginToHome", sender: self)
            } else {
                print("Failed to fetch user")
                self.setLogginButton()
            }
        }
    }
}

