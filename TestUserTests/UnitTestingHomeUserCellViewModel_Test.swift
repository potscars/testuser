//
//  UnitTestingHomeUserCellViewModel_Test.swift
//  TestUserTests
//
//  Created by owner on 08/07/2023.
//

import XCTest
@testable import TestUser

class UnitTestingHomeUserCellViewModel_Test: XCTestCase {
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func test_UnitTestingHomeUserCellViewModel_loadImageSuccess() {
        let vm = HomeUserCellViewModel(user: User(login: "kimberly", id: 0, nodeID: "", avatarURL: "https://avatars.githubusercontent.com/u/1?v=4", gravatarID: "", url: "", type: "", siteAdmin: false, name: nil, company: nil, blog: nil, location: nil, email: nil, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: nil, following: nil, createdAt: nil, updatedAt: nil))
        
        vm.loadImage().sink { image in
            XCTAssertNotNil(image)
        }.cancel()
    }
    
    func test_UnitTestingHomeUserCellViewModel_loadImageFailed() {
        let vm = HomeUserCellViewModel(user: User(login: "kimberly", id: 0, nodeID: "", avatarURL: "https://avatars.githubusercontent.comxxxxx", gravatarID: "", url: "", type: "", siteAdmin: false, name: nil, company: nil, blog: nil, location: nil, email: nil, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: nil, following: nil, createdAt: nil, updatedAt: nil))
        
        vm.loadImage().sink { image in
            XCTAssertNil(image)
        }.cancel()
    }
    
    func test_UnitTestingHomeUserCellViewModel_storeImageSuccess() {
        let vm = HomeUserCellViewModel(user: User(login: "mojombo", id: 0, nodeID: "", avatarURL: "https://avatars.githubusercontent.com/u/1?v=4", gravatarID: "", url: "", type: "", siteAdmin: false, name: nil, company: nil, blog: nil, location: nil, email: nil, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: nil, following: nil, createdAt: nil, updatedAt: nil))
        
        CoreDataManager.shared.addHomeUser(with: vm.getUser())
        
        vm.loadImage().sink { image in
            vm.storeImageData(with: image)
        }.cancel()
        
        let fetchedUsers = CoreDataManager.shared.fetchSingleUser(for: "mojombo")
        
        guard fetchedUsers.count > 0, let fetchedUser = fetchedUsers.first else {
            return
        }
        
        XCTAssertNotNil(fetchedUser.imageData)
    }
    
    func test_UnitTestingHomeUserCellViewModel_storeImageFailed() {
        let vm = HomeUserCellViewModel(user: User(login: "kurin", id: 0, nodeID: "", avatarURL: "https://avatars.githubusercontent.comxxx", gravatarID: "", url: "", type: "", siteAdmin: false, name: nil, company: nil, blog: nil, location: nil, email: nil, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: nil, following: nil, createdAt: nil, updatedAt: nil))
        
        CoreDataManager.shared.addHomeUser(with: vm.getUser())
        
        vm.loadImage().sink { image in
            vm.storeImageData(with: image)
        }.cancel()
        
        let fetchedUsers = CoreDataManager.shared.fetchSingleUser(for: "kurin")
        
        guard fetchedUsers.count > 0, let fetchedUser = fetchedUsers.first else {
            return
        }
        
        XCTAssertNil(fetchedUser.imageData)
    }
}
