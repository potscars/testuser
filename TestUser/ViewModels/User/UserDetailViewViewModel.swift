//
//  UserDetailViewViewModel.swift
//  TestUser
//
//  Created by owner on 04/07/2023.
//

import Foundation
import Combine
import UIKit

class UserDetailViewViewModel: ObservableObject {
    
    //Variable to be shown on the ui.
    @Published var imageUrl: String = ""
    @Published var followers: Int = 0
    @Published var following: Int = 0
    @Published var name: String = ""
    @Published var company: String = ""
    @Published var blog: String = ""
    @Published var image: UIImage?
    @Published var notes: String = ""
    
    private var disposeBag = Set<AnyCancellable>()
    var user: User!
    
    func fetchDataFromCoreData(for login: String) -> Bool {
        let fetchedUsers = CoreDataManager.shared.fetchSingleUser(for: login)
        
        guard fetchedUsers.count > 0, let fetchedUser = fetchedUsers.first else {
            return false
        }
        
        guard fetchedUser.name != nil else { return false }
        
        self.user = User(login: fetchedUser.login ?? "", id: Int(fetchedUser.id), nodeID: "", avatarURL: fetchedUser.avatarUrl ?? "", gravatarID: fetchedUser.gravatarId ?? "", url: fetchedUser.url ?? "", type: fetchedUser.type ?? "", siteAdmin: fetchedUser.siteAdmin , name: fetchedUser.name, company: fetchedUser.company, blog: fetchedUser.blog, location: fetchedUser.location, email: fetchedUser.email, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: Int(fetchedUser.followers), following: Int(fetchedUser.following), createdAt: fetchedUser.createdAt, updatedAt: nil, notes: fetchedUser.notes, imageData: fetchedUser.imageData)
        
        self.imageUrl = fetchedUser.avatarUrl ?? ""
        self.name = fetchedUser.name ?? ""
        self.followers = Int(fetchedUser.followers)
        self.following = Int(fetchedUser.following)
        self.company = fetchedUser.company ?? ""
        self.blog = fetchedUser.blog ?? ""
        self.notes = fetchedUser.notes ?? ""
        
        if let imageData = fetchedUser.imageData {
            self.image = UIImage(data: imageData)
        }
        
        return true
    }
    
    func fetchUserDetail(with username: String) {
        
        guard !self.fetchDataFromCoreData(for: username) else {
            return
        }
        
        let urlString = "https://api.github.com/users/\(username)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            return
        }
        print(urlString)
        URLSession.shared
            .dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .map(\.data)
            .decode(type: User.self, decoder: JSONDecoder())
            .sink { res in
                
            } receiveValue: { [weak self] user in
                guard let self = self else { return }
                
                self.user = user
                
                self.imageUrl = user.avatarURL
                self.name = user.name ?? ""
                self.followers = user.followers ?? 0
                self.following = user.following ?? 0
                self.company = user.company ?? ""
                self.blog = user.blog ?? ""
                print(user)
                
                CoreDataManager.shared.updateData(for: user)
                
                self.loadImage(for: user).sink { image in
                    self.image = image
                }
                .store(in: &self.disposeBag)
            }
            .store(in: &disposeBag)
    }
    
    func loadImage(for user: User) -> AnyPublisher<UIImage?, Never> {
        return Just(user.avatarURL)
            .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
                let url = URL(string: user.avatarURL)!
                return ImageLoader.shared.loadImage(from: url)
            })
            .eraseToAnyPublisher()
    }
    
    func saveNotes() {
        // Save data to core data
        CoreDataManager.shared.updateNotes(for: self.user, with: self.notes)
        
        // assign and send back to parent.
        self.user.notes = self.notes
        NotificationCenter.default.post(name: .savedNotes, object: self.user)
    }
}
