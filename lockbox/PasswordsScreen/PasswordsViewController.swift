//
//  PasswordsViewController.swift
//  lockbox
//
//  Created by agni on 11/17/24.
//

//
//  PasswordsViewController.swift
//  lockbox
//
//  Created by agni on 11/17/24.
//
// new version 3 (list item click is workinG()
//
//  PasswordsViewController.swift
//  lockbox
//
//  Created by agni on 11/17/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PasswordsViewController: UIViewController {
    
    let passwordsView = PasswordsView()
    var currentUser: FirebaseAuth.User?
    var passwords: [(id: String, website: String, username: String, password: String)] = []
    var sharedPasswords: [(id: String, website: String, username: String, password: String)] = []
    var filteredPasswords: [(id: String, website: String, username: String, password: String)] = []
    var isSearching = false
    let database = Firestore.firestore()
    
    override func loadView() {
        view = passwordsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "All Passwords"
        self.navigationItem.hidesBackButton = true
        // Set up table view
        passwordsView.tableView.delegate = self
        passwordsView.tableView.dataSource = self
        passwordsView.tableView.register(PasswordCell.self, forCellReuseIdentifier: "PasswordCell")
        
        // Set up search bar
        passwordsView.searchBar.delegate = self
        
        // Add button action
        passwordsView.addPasswordButton.addTarget(self, action: #selector(navigateToAddPassword), for: .touchUpInside)
        
        // Logout button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPasswords() // Refresh the passwords when the screen appears
    }
    
    func fetchPasswords() {
        guard let email = currentUser?.email else { return }
        
        passwords = []
        sharedPasswords = []
        
        database.collection("passwords").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching passwords: \(error.localizedDescription)")
                return
            }
            
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                let id = document.documentID
                let website = data["website"] as? String ?? ""
                let username = data["username"] as? String ?? ""
                let password = data["password"] as? String ?? ""
                let owner = data["owner"] as? String ?? ""
                let sharedWith = data["sharedWith"] as? [String] ?? []
                
                if owner == email {
                    self.passwords.append((id: id, website: website, username: username, password: password))
                } else if sharedWith.contains(email) {
                    self.sharedPasswords.append((id: id, website: website, username: username, password: password))
                }
            }
            self.passwordsView.tableView.reloadData()
        }
    }
    
    @objc func navigateToAddPassword() {
        let addEditVC = AddEditPasswordViewController()
        addEditVC.currentUser = self.currentUser
        addEditVC.isEditingPassword = false
        self.navigationController?.pushViewController(addEditVC, animated: true)
    }
    
    @objc func logout() {
        do {
            try Auth.auth().signOut()
            self.navigationController?.popViewController(animated: true)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    @objc func confirmDeletePassword(sender: UIButton) {
        let index = sender.tag
        let password = isSearching ? filteredPasswords[index] : passwords[index]
        
        let alert = UIAlertController(
            title: "Delete Password",
            message: "Are you sure you want to delete the password for \(password.website)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deletePassword(at: index)
        })
        
        present(alert, animated: true)
    }
    
    func deletePassword(at index: Int) {
        let passwordID = isSearching ? filteredPasswords[index].id : passwords[index].id
        database.collection("passwords").document(passwordID).delete { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error deleting password: \(error.localizedDescription)")
                return
            }
            if self.isSearching {
                self.filteredPasswords.remove(at: index)
            } else {
                self.passwords.remove(at: index)
            }
            self.passwordsView.tableView.reloadData()
        }
    }
    
    @objc func navigateToSharePassword(sender: UIButton) {
        let index = sender.tag
        let password = isSearching ? filteredPasswords[index] : passwords[index]
        
        let shareDetailsVC = ShareDetailsViewController()
        shareDetailsVC.currentUser = self.currentUser
        shareDetailsVC.password = password
        self.navigationController?.pushViewController(shareDetailsVC, animated: true)
    }
}

extension PasswordsViewController: UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
            filteredPasswords = passwords.filter { $0.website.lowercased().contains(searchText.lowercased()) }
        }
        passwordsView.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Owned passwords and shared passwords
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (isSearching ? filteredPasswords.count : passwords.count) : sharedPasswords.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Your Passwords" : "Shared With You"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell", for: indexPath) as! PasswordCell
        let password = indexPath.section == 0
            ? (isSearching ? filteredPasswords[indexPath.row] : passwords[indexPath.row])
            : sharedPasswords[indexPath.row]
        
        cell.configure(with: password)
        
        if indexPath.section == 0 {
            cell.deleteButton.isHidden = false
            cell.shareButton.isHidden = false
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(confirmDeletePassword), for: .touchUpInside)
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(navigateToSharePassword), for: .touchUpInside)
        } else {
            cell.deleteButton.isHidden = true
            cell.shareButton.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { // Owned passwords
            let selectedPassword = isSearching ? filteredPasswords[indexPath.row] : passwords[indexPath.row]
            let addEditVC = AddEditPasswordViewController()
            addEditVC.currentUser = self.currentUser
            addEditVC.passwordToEdit = selectedPassword
            addEditVC.isEditingPassword = true
            self.navigationController?.pushViewController(addEditVC, animated: true)
        } else { // Shared passwords
            let selectedSharedPassword = sharedPasswords[indexPath.row]
            let sharedDetailsVC = SharedPasswordDetailsViewController()
            sharedDetailsVC.sharedPassword = selectedSharedPassword
            self.navigationController?.pushViewController(sharedDetailsVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

