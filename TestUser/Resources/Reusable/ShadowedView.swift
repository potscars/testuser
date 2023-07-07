//
//  ShadowedView.swift
//  TestUser
//
//  Created by owner on 02/07/2023.
//

import UIKit

class ShadowedView: UIView {
    
    private var value: CGFloat = 0.0
    
    init(with value: CGFloat = 0.0) {
        
        self.value = value
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = value
        layer.shadowColor = UIColor(named: "shadowColor")?.withAlphaComponent(0.5).cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 2, height: 3)
        layer.shadowRadius = 3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
