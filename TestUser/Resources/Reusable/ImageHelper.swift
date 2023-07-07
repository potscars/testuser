//
//  ImageHelper.swift
//  TestUser
//
//  Created by owner on 02/07/2023.
//

import UIKit

class ImageHelper {
    
    static func createSystemImage(_ nameString: String,
                                  pointSize: CGFloat = 17.0,
                                  weight: UIImage.SymbolWeight = .regular) -> UIImage? {
        
        let imgConfig = UIImage.SymbolConfiguration(pointSize: pointSize,
                                                    weight: weight,
                                                    scale: .medium)
        let img = UIImage(systemName: nameString, withConfiguration: imgConfig)
        return img
    }
}
