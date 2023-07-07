//
//  CellConfigurator.swift
//  TestUser
//
//  Created by owner on 02/07/2023.
//

import UIKit

protocol CellConfigurator {
    static var reuseIdentifier: String { get }
    func configure(cell: UIView)
    func getSearchKey() -> String
}
