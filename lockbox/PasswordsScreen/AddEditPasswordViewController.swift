//
//  AddEditPasswordViewController.swift
//  lockbox
//
//  Created by Pranav Raj on 2024-11-18.
//
//
//  AddEditPasswordViewController.swift
//  lockbox
//
//  Created by Pranav Raj on 2024-11-18.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddEditPasswordViewController: UIViewController {
    
    let addEditPasswordView = AddEditPasswordView()
    var isEditingPassword: Bool = false
    var passwordToEdit: (id: String, website: String, username: String, password: String)?
    var currentUser: FirebaseAuth.User?
    let database = Firestore.firestore()
    
    override func loadView() {
        view = addEditPasswordView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = isEditingPassword ? "Edit Password" : "Add Password"
        addEditPasswordView.saveButton.addTarget(self, action: #selector(onSaveButtonPressed), for: .touchUpInside)
        addEditPasswordView.copyButton.addTarget(self, action: #selector(onCopyButtonPressed), for: .touchUpInside)
        
        if isEditingPassword, let password = passwordToEdit {
            populateFields(password: password)
        }
    }
    
    func populateFields(password: (id: String, website: String, username: String, password: String)) {
        addEditPasswordView.websiteField.text = password.website
        addEditPasswordView.usernameField.text = password.username
        addEditPasswordView.passwordField.text = password.password
    }
    
    @objc func onSaveButtonPressed() {
        guard validateFields() else { return }
        
        let website = addEditPasswordView.websiteField.text!
        let username = addEditPasswordView.usernameField.text!
        let password = addEditPasswordView.passwordField.text!
        guard let email = currentUser?.email else { return }
        
        if isEditingPassword, let passwordID = passwordToEdit?.id {
            updatePassword(id: passwordID, website: website, username: username, password: password)
        } else {
            addPassword(website: website, username: username, password: password, email: email)
        }
    }
    
    func addPassword(website: String, username: String, password: String, email: String) {
        let data = [
            "website": website,
            "username": username,
            "password": password,
            "owner": email
        ]
        database.collection("passwords").addDocument(data: data) { [weak self] error in
            if let error = error {
                self?.showAlert(message: "Error adding password: \(error.localizedDescription)")
                return
            }
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func updatePassword(id: String, website: String, username: String, password: String) {
        let data = [
            "website": website,
            "username": username,
            "password": password
        ]
        database.collection("passwords").document(id).updateData(data) { [weak self] error in
            if let error = error {
                self?.showAlert(message: "Error updating password: \(error.localizedDescription)")
                return
            }
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func onCopyButtonPressed() {
        guard let password = addEditPasswordView.passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "No password to copy.")
            return
        }
        UIPasteboard.general.string = password
        showAlert(title: "Copied", message: "Password copied to clipboard.")
    }
    
    func validateFields() -> Bool {
        guard let website = addEditPasswordView.websiteField.text, !website.isEmpty,
              let username = addEditPasswordView.usernameField.text, !username.isEmpty,
              let password = addEditPasswordView.passwordField.text, !password.isEmpty else {
            showAlert(message: "All fields are required!")
            return false
        }
        return true
    }
    
    func showAlert(title: String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

