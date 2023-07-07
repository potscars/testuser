//
//  HomeViewControllerViewModel.swift
//  TestUser
//
//  Created by owner on 01/07/2023.
//

import Foundation
import Combine
import UIKit
import SwiftUI

typealias NormalCellConfigurator = TableCellConfigurator<HomeUserNormalCell, User>
typealias InvertedCellConfigurator = TableCellConfigurator<HomeUserInvertedCell, User>
typealias NotesCellConfigurator = TableCellConfigurator<HomeUserNoteCell, User>

class HomeViewControllerViewModel: ObservableObject {
    
    @Published var items: [CellConfigurator] = []
    @Published var selectedUser: String?
    @Published var isBatchUpdate: Bool = false
    @Published var isConnected: Bool = true
    
    var isFiltering: Bool = false
    @Published var filteredItems: [CellConfigurator] = []
    
    var users: [User] = []
    private let service: BaseService
    private var disposeBag = Set<AnyCancellable>()
    private var isFetchedFromCoreData = false
    
    var isLoadingMoreData = false
    var indexPathsToAdd: [IndexPath] = []
    
    init(service: BaseService = HomeService()) {
        self.service = service
    }
    
    func fetchUsers() {
        
        let urlString = "https://api.github.com/users?since=0"
        
        service
            .request(with: urlString, expecting: [User].self)
            .sink { res in
                
                switch res {
                case .failure(let error):
                    print("oops got an error \(error.localizedDescription)")
                default: break
                }
                
            } receiveValue: { [weak self] users in
                guard let self = self else { return }
                
                self.users = users
                CoreDataManager.shared.addBatchHomeUser(with: self.users)
                
                if self.items.count <= 0 {
                    self.items = self.configureItems(with: users)
                }
                
                self.isLoadingMoreData = false
            }
            .store(in: &disposeBag)
    }
    
    func fetchDataFromCoreData() {
        let fetchedUsers = CoreDataManager.shared.fetchAllHomeUsers()
        
        guard fetchedUsers.count > 0 else {
            return
        }
        
        self.isFetchedFromCoreData = true
        
        self.users = fetchedUsers.map {
            User(login: $0.login ?? "", id: Int($0.id), nodeID: "", avatarURL: $0.avatarUrl ?? "", gravatarID: $0.gravatarId ?? "", url: $0.url ?? "", type: $0.type ?? "", siteAdmin: $0.siteAdmin , name: $0.name, company: $0.company, blog: $0.blog, location: $0.location, email: $0.email, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: Int($0.followers), following: Int($0.following), createdAt: $0.createdAt, updatedAt: nil, notes: $0.notes, imageData: $0.imageData)
        }.sorted { $0.id < $1.id }
        
        self.items = self.configureItems(with: users)
        
        return
    }
    
    private func fetchMoreUsers(with id: Int) {
        let urlString = "https://api.github.com/users?since=\(id)"
        
        service
            .request(with: urlString, expecting: [User].self)
            .sink { [weak self] res in
                
                defer { self?.isLoadingMoreData = false }
                
                switch res {
                case .failure(let error):
                    print("oops got an error \(error.localizedDescription)")
                default: break
                }
                
            } receiveValue: { [weak self] newUsers in
                
                guard let self = self else {
                    return
                }
                
                let originalTotalCount = self.users.count
                let moreCount = newUsers.count
                let totalCount = originalTotalCount + moreCount
                
                self.indexPathsToAdd = Array(originalTotalCount..<totalCount).compactMap({
                    return IndexPath(item: $0, section: 0)
                })
                
                self.isBatchUpdate = true
                CoreDataManager.shared.addBatchHomeUser(with: newUsers)
                self.users.append(contentsOf: newUsers)
                self.items = self.configureItems(with: self.users)
                self.isLoadingMoreData = false
                
                print("Successfully load more: ", self.indexPathsToAdd.count, originalTotalCount, moreCount)
            }
            .store(in: &disposeBag)
    }
    
    // Sort the items into prefered configurator
    private func configureItems(with users: [User]) -> [CellConfigurator] {
        var tempItems: [CellConfigurator] = []
        
        for(i, user) in users.enumerated() {
            if (i+1)%4 == 0 {
                tempItems.append(InvertedCellConfigurator(item: user, searchKey: user.login))
            } else if user.notes != nil {
                tempItems.append(NotesCellConfigurator(item: user, searchKey: user.login))
            } else {
                tempItems.append(NormalCellConfigurator(item: user, searchKey: user.login))
            }
        }
        
        return tempItems
    }
    
    func willLoadMoreData() {
        guard let user = self.users.last, !isLoadingMoreData else  {
            print("Failed to load more \(String(describing: users.last?.id)), \(isLoadingMoreData)")
            return
        }
        
        self.isLoadingMoreData = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.fetchMoreUsers(with: user.id)
        }
    }
    
    func searchUsers(with searchText: String) {
        self.filteredItems = items
        
        if !searchText.isEmpty {
            isFiltering = true
            self.filteredItems = self.items.filter({ $0.getSearchKey().lowercased().contains(searchText.lowercased()) })
        } else {
            isFiltering = false
            self.filteredItems = []
        }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleUserSaved(_:)),
                                               name: .savedNotes,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleConnectivity(_:)),
                                               name: .connectivityStatus,
                                               object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.savedNotes,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.connectivityStatus,
                                                  object: nil)
    }
    
    @objc
    private func handleUserSaved(_ notification: Notification) {
        guard let selectedUser = self.selectedUser else { return }
        
        let fetchedUsers = CoreDataManager.shared.fetchSingleUser(for: selectedUser)
        
        guard fetchedUsers.count > 0, let fetchedUser = fetchedUsers.first else {
            return
        }
        
        if let row = self.items.firstIndex(where: {$0.getSearchKey() == selectedUser }) {
            if let _ = fetchedUser.notes {
                self.items[row] = NotesCellConfigurator(item: User(login: fetchedUser.login ?? "", id: Int(fetchedUser.id), nodeID: "", avatarURL: fetchedUser.avatarUrl ?? "", gravatarID: fetchedUser.gravatarId ?? "", url: fetchedUser.url ?? "", type: fetchedUser.type ?? "", siteAdmin: fetchedUser.siteAdmin , name: fetchedUser.name, company: fetchedUser.company, blog: fetchedUser.blog, location: fetchedUser.location, email: fetchedUser.email, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: Int(fetchedUser.followers), following: Int(fetchedUser.following), createdAt: fetchedUser.createdAt, updatedAt: nil, notes: fetchedUser.notes, imageData: fetchedUser.imageData),
                                                        searchKey: fetchedUser.login ?? "")
            }
        }
    }
    
    @objc
    private func handleConnectivity(_ notification: Notification) {
        self.isConnected = NetworkMonitor.shared.isConnected
        print("Internet Connected: \(self.isConnected)")
    }
}
