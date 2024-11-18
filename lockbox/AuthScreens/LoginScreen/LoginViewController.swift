//
//  LoginViewController.swift
//  lockbox
//
//  Created by agni on 11/10/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    var loginView = LoginView()

    var currentUser: FirebaseAuth.User?
    var authOnChangeListener: AuthStateDidChangeListenerHandle?
    var hasNavigated = false
    
    override func loadView() {
        self.view = loginView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login"
        self.navigationItem.backButtonTitle = ""
        
//                do {
//                    try Auth.auth().signOut()
//                } catch {
//                    print("Error while signing out")
//                }
        
        loginView.registerBtn.addTarget(self, action: #selector(onClickRegisterBtn), for: .touchUpInside)
        loginView.loginBtn.addTarget(self, action: #selector(onClickLoginBtn), for: .touchUpInside)
        
        authOnChangeListener = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.currentUser = user
                
                if !self.hasNavigated {
                    self.hasNavigated = true
                    self.navigateToPasswordsScreen()
                }
            }
        }
        
    }
    
    @objc func onClickRegisterBtn() {
        let registraionViewController = RegistrationViewController()
        registraionViewController.delegate = self
        self.navigationController?.pushViewController(registraionViewController, animated: true)
    }
    
    func resetFields() {
        self.loginView.emailField.text = ""
        self.loginView.passwordField.text = ""
    }
    
    @objc func onClickLoginBtn() {
        if !validateAllFields() {
            return
        }
        
        let email = self.loginView.emailField.text!
        let password = self.loginView.passwordField.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showAlert(message: "Incorrect email/password")
                return
            }
            strongSelf.currentUser = authResult?.user
            
            if !strongSelf.hasNavigated {
                strongSelf.hasNavigated = true
                strongSelf.navigateToPasswordsScreen()
            }
        }
    }
    
    func navigateToPasswordsScreen() {
        resetFields()
        let passwordsViewController = PasswordsViewController()
        passwordsViewController.currentUser = self.currentUser
        self.navigationController?.pushViewController(passwordsViewController, animated: true)
    }
    
    func validateEmptyFields() -> Bool {
        if self.loginView.emailField.text?.isEmpty == true {
            showAlert(message: "Email cannot be empty")
            return false
        } else if self.loginView.passwordField.text?.isEmpty == true {
            showAlert(message: "Password cannot be empty")
            return false
        }
        return true
    }
    
    func validateEmail() -> Bool {
        let email = self.loginView.emailField.text!
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValidEmail = emailPred.evaluate(with: email)
        
        if !isValidEmail {
            showAlert(message: "Email format is invalid")
        }
        
        return isValidEmail
    }
    
    func validateAllFields() -> Bool {
        if !validateEmptyFields() {
            return false
        }
        if !validateEmail() {
            return false
        }
        return true
    }
    
    func showAlert(title: String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(alert, animated: true)
    }
}
