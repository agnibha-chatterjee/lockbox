//
//  AddEditPasswordView.swift
//  lockbox
//
//  Created by Pranav Raj on 2024-11-18.
//

import UIKit

class AddEditPasswordView: UIView {
    
    var websiteField: UITextField!
    var usernameField: UITextField!
    var passwordField: UITextField!
    var saveButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        setupWebsiteField()
        setupUsernameField()
        setupPasswordField()
        setupSaveButton()
        
        initConstraints()
    }
    
    func setupWebsiteField() {
        websiteField = UITextField()
        websiteField.placeholder = "Website"
        websiteField.borderStyle = .roundedRect
        websiteField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(websiteField)
    }
    
    func setupUsernameField() {
        usernameField = UITextField()
        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(usernameField)
    }
    
    func setupPasswordField() {
        passwordField = UITextField()
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(passwordField)
    }
    
    func setupSaveButton() {
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = .blue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(saveButton)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            websiteField.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            websiteField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            websiteField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            usernameField.topAnchor.constraint(equalTo: websiteField.bottomAnchor, constant: 20),
            usernameField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            usernameField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            passwordField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            saveButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 40),
            saveButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
