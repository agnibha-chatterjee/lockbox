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
        
    }
}
