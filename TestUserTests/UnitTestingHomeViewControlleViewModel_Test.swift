//
//  UnitTestingHomeViewControlleViewModel_Test.swift
//  TestUserTests
//
//  Created by owner on 07/07/2023.
//

import XCTest
@testable import TestUser


class UnitTestingHomeViewControlleViewModel_Test: XCTestCase {
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func test_UnitTestingHomeViewControlleViewModel_successSearchKey() {
        //Given
        let vm = HomeViewControllerViewModel()
        vm.items = [
            TableCellConfigurator<HomeUserNormalCell, User>(item: User(login: "kimberly", id: 0, nodeID: "", avatarURL: "", gravatarID: "", url: "", type: "", siteAdmin: false, name: nil, company: nil, blog: nil, location: nil, email: nil, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: nil, following: nil, createdAt: nil, updatedAt: nil), searchKey: "kimberly"),
        ]
        
        //When
        vm.searchUsers(with: "kimberly")
        
        //Then
        XCTAssertTrue(vm.filteredItems.count > 0)
    }
    
    func test_UnitTestingHomeViewControlleViewModel_failedSeachKey() {
        //Given
        let vm = HomeViewControllerViewModel()
        vm.items = [
            TableCellConfigurator<HomeUserNormalCell, User>(item: User(login: "kimberly", id: 0, nodeID: "", avatarURL: "", gravatarID: "", url: "", type: "", siteAdmin: false, name: nil, company: nil, blog: nil, location: nil, email: nil, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: nil, following: nil, createdAt: nil, updatedAt: nil), searchKey: "kimberly"),
        ]
        
        //When
        vm.searchUsers(with: "maxim")
        
        XCTAssertFalse(vm.filteredItems.count > 0)
    }
}
