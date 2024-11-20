//
//  ShareDetailsViewController.swift
//  lockbox
//
//  Created by Pranav Raj on 2024-11-18.
//

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
        setupConstraints()
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
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Search field constraints
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: addUserButton.leadingAnchor, constant: -8),
            searchField.heightAnchor.constraint(equalToConstant: 40),
            
            // Add user button constraints
            addUserButton.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            addUserButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addUserButton.widthAnchor.constraint(equalToConstant: 100),
            addUserButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Table view constraints
            sharedUsersTableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            sharedUsersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sharedUsersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sharedUsersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func fetchSharedUsers() {
        guard let passwordID = password?.id else { return }
        database.collection("passwords").document(passwordID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching shared users: \(error.localizedDescription)")
                return
            }
            if let data = snapshot?.data(), let sharedWith = data["sharedWith"] as? [String] {
                self.sharedUsers = sharedWith
                self.sharedUsersTableView.reloadData()
            }
        }
    }
    
    @objc func addUser() {
        guard let email = searchField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Email cannot be empty.")
            return
        }
        
        if sharedUsers.contains(email) {
            showAlert(title: "Error", message: "\(email) already has access.")
            return
        }
        
        guard let passwordID = password?.id else { return }
        
        database.collection("passwords").document(passwordID).updateData([
            "sharedWith": FieldValue.arrayUnion([email])
        ]) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to add user: \(error.localizedDescription)")
                return
            }
            self.sharedUsers.append(email)
            self.sharedUsersTableView.reloadData()
            self.showAlert(title: "Success", message: "Access granted to \(email).")
        }
    }
    
    func revokeAccess(for email: String) {
        guard let passwordID = password?.id else { return }
        
        database.collection("passwords").document(passwordID).updateData([
            "sharedWith": FieldValue.arrayRemove([email])
        ]) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to revoke access: \(error.localizedDescription)")
                return
            }
            self.sharedUsers.removeAll { $0 == email }
            self.sharedUsersTableView.reloadData()
            self.showAlert(title: "Success", message: "Access revoked for \(email).")
        }
    }
    
    @objc func revokeButtonTapped(sender: UIButton) {
        let email = sharedUsers[sender.tag]
        
        let alert = UIAlertController(
            title: "Revoke Access",
            message: "Are you sure you want to revoke access for \(email)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Revoke", style: .destructive) { [weak self] _ in
            self?.revokeAccess(for: email)
        })
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SharedUserCell", for: indexPath)
        let email = sharedUsers[indexPath.row]
        
        cell.textLabel?.text = email
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        let revokeButton = UIButton(type: .system)
        revokeButton.setTitle("Revoke", for: .normal)
        revokeButton.setTitleColor(.red, for: .normal)
        revokeButton.tag = indexPath.row
        revokeButton.addTarget(self, action: #selector(revokeButtonTapped), for: .touchUpInside)
        
        cell.accessoryView = revokeButton
        return cell
    }
}
