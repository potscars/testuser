//
//  ConfigurableCell.swift
//  TestUser
//
//  Created by owner on 01/07/2023.
//

import Foundation

protocol ConfigurableCell {
    associatedtype DataType
    func configure(data: DataType)
}
