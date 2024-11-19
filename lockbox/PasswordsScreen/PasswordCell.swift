//
//  PasswordCell.swift
//  lockbox
//
//  Created by Pranav Raj on 2024-11-18.
//

import UIKit

class PasswordCell: UITableViewCell {
    
    let websiteLabel = UILabel()
    let deleteButton = UIButton(type: .system)
    let shareButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Configure website label
        websiteLabel.font = UIFont.systemFont(ofSize: 16)
        websiteLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(websiteLabel)
        
        // Configure delete button
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deleteButton)
        
        // Configure share button
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(.blue, for: .normal)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(shareButton)
        
        // Setup constraints
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with password: (id: String, website: String, username: String, password: String)) {
        websiteLabel.text = password.website
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Website label constraints
            websiteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            websiteLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Share button constraints
            shareButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -16),
            shareButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Delete button constraints
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
