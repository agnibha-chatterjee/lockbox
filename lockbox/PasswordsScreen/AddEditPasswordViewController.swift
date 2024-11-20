//
//  AddEditPasswordViewController.swift
//  lockbox
//
//  Created by Pranav Raj on 2024-11-18.
//
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import MapKit
import CoreLocation

class AddEditPasswordViewController: UIViewController, CLLocationManagerDelegate {
    
    let addEditPasswordView = AddEditPasswordView()
    var isEditingPassword: Bool = false
    var passwordToEdit: (id: String, website: String, username: String, password: String)?
    var currentUser: FirebaseAuth.User?
    let database = Firestore.firestore()
    let locationManager = CLLocationManager()
    var mapView = MKMapView()
    var savedLocations: [(latitude: Double, longitude: Double)] = []
    
    override func loadView() {
        view = addEditPasswordView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = isEditingPassword ? "Edit Password" : "Add Password"
        addEditPasswordView.saveButton.addTarget(self, action: #selector(onSaveButtonPressed), for: .touchUpInside)
        addEditPasswordView.copyButton.addTarget(self, action: #selector(onCopyButtonPressed), for: .touchUpInside)
        
        setupMapView()
        setupLocationManager()
        
        if isEditingPassword, let password = passwordToEdit {
            populateFields(password: password)
            fetchLocations()
        }
    }
    
    func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 8
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: addEditPasswordView.copyButton.bottomAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func populateFields(password: (id: String, website: String, username: String, password: String)) {
        addEditPasswordView.websiteField.text = password.website
        addEditPasswordView.usernameField.text = password.username
        addEditPasswordView.passwordField.text = password.password
    }
    
    func fetchLocations() {
        guard let passwordID = passwordToEdit?.id else { return }
        database.collection("passwords").document(passwordID).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else { return }
            if let locations = data["locations"] as? [[String: Double]] {
                self.savedLocations = locations.map { (latitude: $0["latitude"] ?? 0.0, longitude: $0["longitude"] ?? 0.0) }
                self.updateMap()
            }
        }
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        for location in savedLocations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            mapView.addAnnotation(annotation)
        }
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
            "owner": email,
            "locations": [] // Initialize locations as an empty array
        ] as [String: Any]
        
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
        saveLocation()
        showAlert(title: "Copied", message: "Password copied to clipboard.")
    }
    
    func saveLocation() {
        guard let passwordID = passwordToEdit?.id else { return }
        locationManager.requestLocation()
        
        guard let location = locationManager.location else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let newLocation = ["latitude": latitude, "longitude": longitude]
        database.collection("passwords").document(passwordID).updateData([
            "locations": FieldValue.arrayUnion([newLocation])
        ]) { [weak self] error in
            if let error = error {
                print("Error saving location: \(error.localizedDescription)")
                return
            }
            self?.savedLocations.append((latitude: latitude, longitude: longitude))
            self?.updateMap()
        }
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location updates handled here if needed
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
