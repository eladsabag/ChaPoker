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

class HomeViewController: UIViewController {
    @IBOutlet weak var chipsLabel: UILabel!
    
    @IBOutlet weak var firstModeView: UIView!
    @IBOutlet weak var firstModeImg: UIImageView!
    
    @IBOutlet weak var secondModeView: UIView!
    @IBOutlet weak var secondModeImg: UIImageView!
    
    @IBOutlet weak var chapLabel: UILabel!
    @IBOutlet weak var omahaLabel: UILabel!
    
    @IBOutlet weak var texasButton: UIButton!
    @IBOutlet weak var omahaButton: UIButton!
    
    var homeManager: HomeManager?
    var user: User?
    var selectedTable: Table?

    override func viewDidLoad() {
        super.viewDidLoad()
        homeManager = HomeManager(user: user)
        homeManager?.delegate = self
        homeManager?.fetchTables()
        homeManager?.observeTables()
        initViews()
        setLogoutButton()
    }
    
    func initViews() {
        if let chips = user?.chips {
            chipsLabel.text = "Chips: \(chips)$"
        } else {
            chipsLabel.text = "Chips: N/A"
        }
        firstModeView.layer.cornerRadius = 10.0
        firstModeImg.layer.cornerRadius = 10.0
        secondModeView.layer.cornerRadius = 10.0
        secondModeImg.layer.cornerRadius = 10.0
        chapLabel.layer.cornerRadius = 10.0
        chapLabel.layer.borderWidth = 1.0
        chapLabel.layer.borderColor = UIColor.yellow.cgColor
        omahaLabel.layer.cornerRadius = 10.0
        omahaLabel.layer.borderWidth = 1.0
        omahaLabel.layer.borderColor = UIColor.yellow.cgColor
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
    
    func updateTableButtons() {
        if let table1 = homeManager?.tables?[0], let table2 = homeManager?.tables?[1] {
            let texasTable = table1.gameType == "Texas" ? table1 : table2
            let omahaTable = table1.gameType == "Omaha" ? table1 : table2
            texasButton.setTitle("Join Table(\(texasTable.playersCount ?? 0)/\(texasTable.maxPlayers))", for: .normal)
            omahaButton.setTitle("Join Table(\(omahaTable.playersCount ?? 0)/\(omahaTable.maxPlayers))", for: .normal)
        } else {
            texasButton.setTitle("N/A", for: .normal)
            omahaButton.setTitle("N/A", for: .normal)
        }
    }
    
    @IBAction func texasHoldemPressed(_ sender: Any) {
        if let table1 = homeManager?.tables?[0], let table2 = homeManager?.tables?[1] {
            let texasTable = table1.gameType == "Texas" ? table1 : table2
            homeManager?.joinTable(table: texasTable, user: user!)
        }
    }
    
    @IBAction func omahaPressed(_ sender: Any) {
        if let table1 = homeManager?.tables?[0], let table2 = homeManager?.tables?[1] {
            let omahaTable = table1.gameType == "Omaha" ? table1 : table2
            homeManager?.joinTable(table: omahaTable, user: user!)
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
        self.performSegue(withIdentifier: "navigateFromHomeToLogin", sender: self)
    }
}

extension HomeViewController: HomeManagerDelegate {
    
    func onTablesUpdated() {
        DispatchQueue.main.async {
            self.updateTableButtons()
        }
    }
    
    func onUserJoinedTable(table: Table) {
        DispatchQueue.main.async {
            self.selectedTable = table
            self.performSegue(withIdentifier: "navigateFromHomeToGame", sender: self)
        }
    }
}

