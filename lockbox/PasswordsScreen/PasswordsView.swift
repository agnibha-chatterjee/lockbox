//
//  PasswordsView.swift
//  lockbox
//
//  Created by agni on 11/10/24.
//

import UIKit

class PasswordsView: UIView {
    
    var searchBar: UISearchBar!
    var tableView: UITableView!
    var addPasswordButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        setupSearchBar()
        setupTableView()
        setupAddPasswordButton()
        initConstraints()
    }
    
    func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = "Search passwords"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(searchBar)
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)
    }
    
    func setupAddPasswordButton() {
        addPasswordButton = UIButton(type: .system)
        addPasswordButton.setTitle("+ Add Password", for: .normal)
        addPasswordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addPasswordButton.backgroundColor = .blue
        addPasswordButton.tintColor = .white
        addPasswordButton.layer.cornerRadius = 25
        addPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(addPasswordButton)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            addPasswordButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addPasswordButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addPasswordButton.widthAnchor.constraint(equalToConstant: 50),
            addPasswordButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
