//
//  TableCellConfigurator.swift
//  TestUser
//
//  Created by owner on 02/07/2023.
//
// Generic class.

import UIKit

class TableCellConfigurator<CellType: ConfigurableCell, DataType>: CellConfigurator where CellType.DataType == DataType, CellType: UITableViewCell {
    
    static var reuseIdentifier: String {
        String(describing: CellType.self)
    }
    
    private let item: DataType
    private let searchKey: String
    
    init(item: DataType, searchKey: String) {
        self.item = item
        self.searchKey = searchKey
    }
    
    func configure(cell: UIView) {
        (cell as! CellType).configure(data: item)
    }
    
    func getSearchKey() -> String {
        self.searchKey
    }
}
