//
//  HomeViewController.swift
//  ChaPoker
//
//  Created by Elad Sabag on 29/06/2023.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth
import Firebase
import FirebaseDatabase

class HomeViewController: UIViewController {
    @IBOutlet weak var chipsLabel: UILabel!
    
    @IBOutlet weak var texasLabel: UILabel!
    @IBOutlet weak var pineappleLabel: UILabel!
    @IBOutlet weak var chocoLabel: UILabel!
    
    @IBOutlet weak var texasImg: UIImageView!
    @IBOutlet weak var pineappleImg: UIImageView!
    @IBOutlet weak var chocoImg: UIImageView!
    
    @IBOutlet weak var joinTexasBtn: UIButton!
    @IBOutlet weak var joinPineappleBtn: UIButton!
    @IBOutlet weak var joinChocoBtn: UIButton!
    
    @IBOutlet weak var texasCountLabel: UILabel!
    @IBOutlet weak var pineappleCountLabel: UILabel!
    @IBOutlet weak var chocoCountLabel: UILabel!
    
    var homeManager: HomeManager?
    var user: User?
    var selectedTable: Table?

    override func viewDidLoad() {
        super.viewDidLoad()
        homeManager = HomeManager(user: user)
        homeManager?.delegate = self
        homeManager?.fetchTables()
        homeManager?.observeTables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initViews()
        setLogoutButton()   
    }
    
    func initViews() {
        if let chips = user?.chips {
            chipsLabel.text = "Chips: \(chips)$"
        } else {
            chipsLabel.text = "Chips: N/A"
        }
        texasImg.layer.cornerRadius = 10.0
        joinTexasBtn.layer.cornerRadius = 10.0
        texasLabel.layer.cornerRadius = 10.0
        texasLabel.layer.borderWidth = 1.0
        texasLabel.layer.borderColor = UIColor.yellow.cgColor
        pineappleImg.layer.cornerRadius = 10.0
        joinPineappleBtn.layer.cornerRadius = 10.0
        pineappleLabel.layer.cornerRadius = 10.0
        pineappleLabel.layer.borderWidth = 1.0
        pineappleLabel.layer.borderColor = UIColor.yellow.cgColor
        chocoImg.layer.cornerRadius = 10.0
        joinChocoBtn.layer.cornerRadius = 10.0
        chocoLabel.layer.cornerRadius = 10.0
        chocoLabel.layer.borderWidth = 1.0
        chocoLabel.layer.borderColor = UIColor.yellow.cgColor
    }
    
    func setLogoutButton() {
        let logoutButton = FBLoginButton()
        logoutButton.delegate = self
        // Adjust the button's position
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        // Add constraints to position the button in the bottom center
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15)
        ])
    }
    
    func updateUI() {
        if let table1 = homeManager?.tables?[0], let table2 = homeManager?.tables?[1], let table3 = homeManager?.tables?[2]  {
            texasCountLabel.text = "\(table1.playersCount)/\(table1.maxPlayers)"
            pineappleCountLabel.text = "\(table2.playersCount)/\(table2.maxPlayers)"
            chocoCountLabel.text = "\(table3.playersCount)/\(table3.maxPlayers)"
        } else {
            print("Nothing to update.")
        }
    }


    @IBAction func joinTexasPressed(_ sender: Any) {
        if let table1 = homeManager?.tables?[0] {
            homeManager?.joinTable(table: table1, user: user!)
        } else {
            print("Didn't join table")
        }
    }
    
    @IBAction func joinPineapplePressed(_ sender: Any) {
        if let table2 = homeManager?.tables?[1] {
            homeManager?.joinTable(table: table2, user: user!)
        } else {
            print("Didn't join table")
        }
    }
    
    @IBAction func joinChocoPressed(_ sender: Any) {
        if let table3 = homeManager?.tables?[2] {
            homeManager?.joinTable(table: table3, user: user!)
        } else {
            print("Didn't join table")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "navigateFromHomeToGame" {
            if let destinationVC = segue.destination as? GameViewController {
                destinationVC.table = selectedTable
                destinationVC.user = user
            }
        }
    }
}

extension HomeViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {}
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        UserDefaultsManager.shared.setAuthToken(nil)
        UserDefaultsManager.shared.setUserID(nil)
        self.performSegue(withIdentifier: "navigateFromHomeToLogin", sender: self)
    }
}

extension HomeViewController: HomeManagerDelegate {
    
    func onTablesUpdated() {
        print("onTablesUpdated")
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
    
    func onUserJoinedTable(table: Table) {
        DispatchQueue.main.async {
            self.selectedTable = table
            self.performSegue(withIdentifier: "navigateFromHomeToGame", sender: self)
        }
    }
}

