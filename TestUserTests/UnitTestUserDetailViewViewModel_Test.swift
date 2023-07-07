//
//  UnitTestUserDetailViewViewModel_Test.swift
//  TestUserTests
//
//  Created by owner on 08/07/2023.
//

import XCTest
@testable import TestUser

class UnitTestUserDetailViewViewModel_Test: XCTestCase {
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func test_UnitTestUserDetailViewViewModel_loadImageSuccess() {
        let user = User(login: "kimberly", id: 0, nodeID: "", avatarURL: "https://avatars.githubusercontent.com/u/1?v=4", gravatarID: "", url: "", type: "", siteAdmin: false, name: nil, company: nil, blog: nil, location: nil, email: nil, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: nil, following: nil, createdAt: nil, updatedAt: nil)
        let vm = UserDetailViewViewModel()
        
        vm.loadImage(for: user).sink { image in
            XCTAssertNotNil(image)
        }.cancel()
    }
    
    func test_UnitTestUserDetailViewViewModel_loadImageFailed() {
        let user =  User(login: "kimberly", id: 0, nodeID: "", avatarURL: "https://avatars.githubusercontent.comxxxxx", gravatarID: "", url: "", type: "", siteAdmin: false, name: nil, company: nil, blog: nil, location: nil, email: nil, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: nil, following: nil, createdAt: nil, updatedAt: nil)
        
        let vm = UserDetailViewViewModel()
        
        vm.loadImage(for: user).sink { image in
            XCTAssertNil(image)
        }.cancel()
    }
    
    func test_UnitTestUserDetailViewViewModel_saveNotesSuccess() {
        
        let vm = UserDetailViewViewModel()
        vm.user = User(login: "kimberly", id: 0, nodeID: "", avatarURL: "https://avatars.githubusercontent.comxxxxx", gravatarID: "", url: "", type: "", siteAdmin: false, name: nil, company: nil, blog: nil, location: nil, email: nil, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: nil, following: nil, createdAt: nil, updatedAt: nil)
        vm.notes = "This is test notes"
        
        CoreDataManager.shared.addHomeUser(with: vm.user)
        
        vm.saveNotes()
        
        let fetchedUsers = CoreDataManager.shared.fetchSingleUser(for: vm.user.login)
        
        guard fetchedUsers.count > 0, let fetchedUser = fetchedUsers.first else {
            return
        }
        
        XCTAssertNotNil(fetchedUser.notes)
    }
}
