//
//  HomeUserCellViewModel.swift
//  TestUser
//
//  Created by owner on 07/07/2023.
//

import Foundation
import Combine
import UIKit

class HomeUserCellViewModel: ObservableObject {
    
    private var user: User
    var cancellable: AnyCancellable?
//    @Published var image: UIImage?
    
    init(user: User) {
        self.user = user
    }
    
    func loadImage() -> AnyPublisher<UIImage?, Never> {
        return Just(self.user.avatarURL)
            .flatMap({ [weak self] poster -> AnyPublisher<UIImage?, Never> in
                
                guard let self = self  else { return Just(nil).eraseToAnyPublisher() }
                guard let url = URL(string: self.user.avatarURL) else {
                    return Just(nil).eraseToAnyPublisher()
                }
                
                return ImageLoader.shared.loadImage(from: url)
            })
            .eraseToAnyPublisher()
    }
    
    func storeImageData(with image: UIImage?) {
        
        guard let imageData = image?.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        CoreDataManager.shared.updateData(for: self.user, with: imageData)
    }
    
    public func getUser() -> User {
        self.user
    }
    
    func disposeBag() {
        cancellable?.cancel()
    }
}
