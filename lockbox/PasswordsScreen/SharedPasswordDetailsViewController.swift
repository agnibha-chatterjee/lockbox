//
//  SharedPasswordDetailsViewController.swift
//  lockbox
//
//  Created by Pranav Raj on 2024-11-19.
//



import UIKit
import CoreLocation
import FirebaseFirestore

class SharedPasswordDetailsViewController: UIViewController, CLLocationManagerDelegate {
    
    var sharedPassword: (id: String, website: String, username: String, password: String)?
    let locationManager = CLLocationManager()
    let database = Firestore.firestore()
    
    // UI Elements
    let websiteLabel = UILabel()
    let usernameLabel = UILabel()
    let passwordLabel = UILabel()
    let copyButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Password Details"
        
        setupLabels()
        setupCopyButton()
        setupConstraints()
        displayPasswordDetails()
        
        setupLocationManager()
    }
    
    func setupLabels() {
        // Configure website label
        websiteLabel.font = UIFont.boldSystemFont(ofSize: 20)
        websiteLabel.numberOfLines = 0
        websiteLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(websiteLabel)
        
        // Configure username label
        usernameLabel.font = UIFont.systemFont(ofSize: 18)
        usernameLabel.numberOfLines = 0
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        
        // Configure password label
        passwordLabel.font = UIFont.systemFont(ofSize: 18)
        passwordLabel.numberOfLines = 0
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordLabel)
    }
    
    func setupCopyButton() {
        // Configure copy button
        copyButton.setTitle("Copy Password", for: .normal)
        copyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        copyButton.backgroundColor = .gray
        copyButton.tintColor = .white
        copyButton.layer.cornerRadius = 8
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.addTarget(self, action: #selector(onCopyButtonPressed), for: .touchUpInside)
        view.addSubview(copyButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            websiteLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            websiteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            websiteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            usernameLabel.topAnchor.constraint(equalTo: websiteLabel.bottomAnchor, constant: 20),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            passwordLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            passwordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            copyButton.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 40),
            copyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 150),
            copyButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    func displayPasswordDetails() {
        guard let sharedPassword = sharedPassword else { return }
        websiteLabel.text = "Website: \(sharedPassword.website)"
        usernameLabel.text = "Username: \(sharedPassword.username)"
        passwordLabel.text = "Password: \(sharedPassword.password)"
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    @objc func onCopyButtonPressed() {
        guard let password = sharedPassword?.password else {
            showAlert(title: "Error", message: "No password to copy.")
            return
        }
        UIPasteboard.general.string = password
        saveLocation()
        showAlert(title: "Copied", message: "Password copied to clipboard.")
    }
    
    func saveLocation() {
        guard let passwordID = sharedPassword?.id else { return }
        locationManager.requestLocation()
        
        guard let location = locationManager.location else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let newLocation = ["latitude": latitude, "longitude": longitude]
        database.collection("passwords").document(passwordID).updateData([
            "locations": FieldValue.arrayUnion([newLocation])
        ]) { error in
            if let error = error {
                print("Error saving location: \(error.localizedDescription)")
            } else {
                print("Location saved successfully.")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Handle location updates if needed
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
