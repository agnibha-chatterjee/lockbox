//
//  LoginViewController.swift
//  lockbox
//
//  Created by agni on 11/10/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    var loginView = LoginView()
    let defaults = UserDefaults.standard
    
    override func loadView() {
        self.view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login"
        self.navigationItem.backButtonTitle = ""
        
        loginView.registerBtn.addTarget(self, action: #selector(onClickRegisterBtn), for: .touchUpInside)
        loginView.loginBtn.addTarget(self, action: #selector(onClickLoginBtn), for: .touchUpInside)
        
        checkIfUserIsAuthenticated()
    }
    
    @objc func onClickRegisterBtn() {
        let registraionViewController = RegistratonViewController()
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
        
//        self.login(email: email, password: password)
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
    
    func checkIfUserIsAuthenticated() {
        let savedAccessToken = defaults.string(forKey: "accessToken")
        
        if savedAccessToken == nil {
            return
        }
        
        let accessToken: String = savedAccessToken!
        
//        self.getUserDetails(token: accessToken)
    }
}
