//
//  RegistrationView.swift
//  lockbox
//
//  Created by agni on 11/10/24.
//

import UIKit

class RegistrationView: UIView {
    
    var lockboxLabel: UILabel!
    var nameField: UITextField!
    var emailField: UITextField!
    var passwordField: UITextField!
    var registerBtn: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        setupLockboxLabel()
        setupNameField()
        setupEmailField()
        setupPasswordField()
        setupRegisterBtn()
        
        initConstraints()
    }
    
    func setupLockboxLabel() {
        lockboxLabel = UILabel()
        lockboxLabel.text = "LockBox"
        lockboxLabel.font = UIFont.boldSystemFont(ofSize: 32.0)
        lockboxLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lockboxLabel)
    }
    
    func setupNameField() {
        nameField = UITextField()
        nameField.keyboardType = .namePhonePad
        nameField.placeholder = "Name"
        nameField.borderStyle = .roundedRect
        nameField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(nameField)
    }
    
    func setupEmailField() {
        emailField = UITextField()
        emailField.keyboardType = .emailAddress
        emailField.placeholder = "Email"
        emailField.borderStyle = .roundedRect
        emailField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(emailField)
    }
    
    func setupPasswordField() {
        passwordField = UITextField()
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(passwordField)
    }
    
    func setupRegisterBtn() {
        registerBtn = UIButton()
        registerBtn.setTitle("Register", for: .normal)
        registerBtn.setTitleColor(.blue, for: .normal)
        registerBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(registerBtn)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            
            lockboxLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 48),
            lockboxLabel.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            
            nameField.topAnchor.constraint(equalTo: self.lockboxLabel.topAnchor, constant: 72),
            nameField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            nameField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            emailField.topAnchor.constraint(equalTo: self.nameField.topAnchor, constant: 48),
            emailField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            passwordField.topAnchor.constraint(equalTo: self.emailField.topAnchor, constant: 48),
            passwordField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            
            registerBtn.topAnchor.constraint(equalTo: self.passwordField.topAnchor, constant: 48),
            registerBtn.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
