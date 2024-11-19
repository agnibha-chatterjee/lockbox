//
//  ShareDetailsViewController.swift
//  lockbox
//
//  Created by Pranav Raj on 2024-11-18.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ShareDetailsViewController: UIViewController {
    
    var currentUser: FirebaseAuth.User?
    var password: (id: String, website: String, username: String, password: String)?
    var sharedUsers: [String] = [] // Users who already have access
    
    let database = Firestore.firestore()
    
    // UI Elements
    let searchField = UITextField()
    let addUserButton = UIButton(type: .system)
    let sharedUsersTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Manage Sharing"
        view.backgroundColor = .white
        
        setupSearchField()
        setupAddUserButton()
        setupSharedUsersTableView()
        fetchSharedUsers()
    }
    
    func setupSearchField() {
        searchField.placeholder = "Enter user's email"
        searchField.borderStyle = .roundedRect
        searchField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchField)
    }
    
    func setupAddUserButton() {
        addUserButton.setTitle("Add User", for: .normal)
        addUserButton.backgroundColor = .blue
        addUserButton.tintColor = .white
        addUserButton.layer.cornerRadius = 8
        addUserButton.translatesAutoresizingMaskIntoConstraints = false
        addUserButton.addTarget(self, action: #selector(addUser), for: .touchUpInside)
        view.addSubview(addUserButton)
    }
    
    func setupSharedUsersTableView() {
        sharedUsersTableView.delegate = self
        sharedUsersTableView.dataSource = self
        sharedUsersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SharedUserCell")
        sharedUsersTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sharedUsersTableView)
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: addUserButton.leadingAnchor, constant: -8),
            
            addUserButton.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            addUserButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addUserButton.widthAnchor.constraint(equalToConstant: 100),
            
            sharedUsersTableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            sharedUsersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sharedUsersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sharedUsersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func fetchSharedUsers() {
        guard let passwordID = password?.id else { return }
        database.collection("passwords").document(passwordID).collection("shared_logins").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching shared users: \(error.localizedDescription)")
                return
            }
            
            self.sharedUsers = snapshot?.documents.compactMap { $0.data()["email"] as? String } ?? []
            self.sharedUsersTableView.reloadData()
        }
    }
    
    @objc func addUser() {
        guard let email = searchField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Email cannot be empty.")
            return
        }
        
        // Check if the user is already shared
        if sharedUsers.contains(email) {
            showAlert(title: "Error", message: "\(email) already has access.")
            return
        }
        
        // Check if the user exists in Firestore
        database.collection("users").whereField("email", isEqualTo: email).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                // User exists, share the password
                self.shareLogin(with: email)
            } else {
                self.showAlert(title: "Error", message: "No user found with the email \(email).")
            }
        }
    }
    
    func shareLogin(with email: String) {
        guard let passwordID = password?.id else { return }
        
        let data = ["email": email]
        database.collection("passwords").document(passwordID).collection("shared_logins").document(email).setData(data) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to share login: \(error.localizedDescription)")
                return
            }
            
            self.sharedUsers.append(email)
            self.sharedUsersTableView.reloadData()
            self.showAlert(title: "Success", message: "Login shared successfully with \(email).")
        }
    }
    
    func revokeAccess(for email: String) {
        guard let passwordID = password?.id else { return }
        
        database.collection("passwords").document(passwordID).collection("shared_logins").document(email).delete { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error revoking access: \(error.localizedDescription)")
                return
            }
            
            self.sharedUsers.removeAll { $0 == email }
            self.sharedUsersTableView.reloadData()
            self.showAlert(title: "Success", message: "Access revoked for \(email).")
        }
    }
    
    @objc func revokeButtonTapped(sender: UIButton) {
        let email = sharedUsers[sender.tag]
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Revoke Access",
            message: "Are you sure you want to revoke access for \(email)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel)) // Cancel button
        alert.addAction(UIAlertAction(title: "Revoke", style: .destructive, handler: { [weak self] _ in
            self?.revokeAccess(for: email)
        }))
        
        present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ShareDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SharedUserCell")
        let email = sharedUsers[indexPath.row]
        
        cell.textLabel?.text = email
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        let revokeButton = UIButton(type: .system)
        revokeButton.setTitle("Revoke", for: .normal)
        revokeButton.setTitleColor(.red, for: .normal)
        revokeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        revokeButton.tag = indexPath.row
        revokeButton.translatesAutoresizingMaskIntoConstraints = false
        revokeButton.addTarget(self, action: #selector(revokeButtonTapped), for: .touchUpInside)
        
        cell.contentView.addSubview(revokeButton)
        
        NSLayoutConstraint.activate([
            cell.textLabel!.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cell.textLabel!.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            revokeButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            revokeButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
}
