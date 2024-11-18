//
//  PasswordsViewController.swift
//  lockbox
//
//  Created by agni on 11/17/24.
//

import UIKit
import FirebaseAuth

class PasswordsViewController: UIViewController {
    
    let passwordsView = PasswordsView()
    var currentUser: FirebaseAuth.User?
    
    override func loadView() {
        view = passwordsView
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "All Passwords"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
    }

    @objc func logout() {
        do {
            try Auth.auth().signOut()
            self.navigationController?.popViewController(animated: true)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
