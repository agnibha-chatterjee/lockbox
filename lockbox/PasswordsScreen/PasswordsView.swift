//
//  PasswordsView.swift
//  lockbox
//
//  Created by agni on 11/10/24.
//

import UIKit

class PasswordsView: UIView {
    
    var dummyLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        setupDummyLabel()
        initConstraints()
    }
    
    func setupDummyLabel() {
        dummyLabel = UILabel()
        dummyLabel.text = "Remove this dummy label when you start!"
        dummyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dummyLabel)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            
            dummyLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            dummyLabel.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
