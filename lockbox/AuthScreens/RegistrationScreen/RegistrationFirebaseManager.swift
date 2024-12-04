//
//  RegistrationFirebaseManager.swift
//  lockbox
//
//  Created by agni on 11/10/24.
//

import Foundation
import UIKit
import FirebaseAuth
import CryptoKit

extension RegistrationViewController {
    func registerNewAccount(name: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
            if error == nil {
                self.currentUser = result?.user
                _ = self.currentUser!.uid
                self.setUserNameInFirebaseAuth(name: name)
            }
            else {
                self.showErrorAlert(message: (error?.localizedDescription.description)!)
            }
        })
    }
    
    func setUserNameInFirebaseAuth(name: String) {
//        showActivityIndicator()
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges(completion: {(error) in
            if error == nil {
                self.createFirestoreUserDocument()
            }
            else {
                self.showErrorAlert(message: (error?.localizedDescription.description)!)
            }
        })
    }
    
    func createFirestoreUserDocument() {
        var userCollectionCount = -1
        if let userEmail = currentUser?.email {
            let data = ["name": currentUser?.displayName ?? "", "email": userEmail]
            let userCollection = database.collection("users")
            
            userCollection.document(userEmail).setData(data) { error in
                if error != nil {
                } else {
                    userCollection.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error fetching userCollection documents: \(error.localizedDescription)")
                        } else {
                            userCollectionCount = querySnapshot?.documents.count ?? 0
                            if userCollectionCount > 1 {
                                _ = querySnapshot?.documents.compactMap { document in
                                    document.data()["email"] as? String
                                } ?? []
                            }
                        }
                    }
                }
            }

            self.delegate?.hasNavigated = true
            
            if !self.hasNavigated {
                self.hasNavigated = true
                self.resetFields()
                let passwordsViewController = PasswordsViewController()
                passwordsViewController.currentUser = self.currentUser
                passwordsViewController.registrationDelegate = self
                self.navigationController?.pushViewController(passwordsViewController, animated: true)
            }
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
}
