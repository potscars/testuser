//
//  CoreDataManager.swift
//  TestUser
//
//  Created by owner on 06/07/2023.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private let persistentContainer: NSPersistentContainer
    private let homeUserRequest = NSFetchRequest<HomeUserEntity>(entityName: "HomeUserEntity")
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "TestUser")
    }
    
    func load() {
        self.persistentContainer.loadPersistentStores { description, error in
            guard error == nil else {
                return
            }
        }
    }
    
    func fetchAllHomeUsers() -> [HomeUserEntity] {
        
        var users: [HomeUserEntity] = []
        
        do {
            users = try viewContext.fetch(homeUserRequest)
        } catch {
            print("Error failed to fetch...")
        }
        
        return users
    }
    
    func addHomeUser(with user: User) {
        
        guard checkIfUserExisted(for: user.login, id: Int16(user.id)) else {
            print("Existed!")
            return
        }
        
        let homeUser = HomeUserEntity(context: viewContext)
        homeUser.login = user.login
        homeUser.id = Int16(user.id)
        homeUser.avatarUrl = user.avatarURL
        homeUser.gravatarId = user.gravatarID
        homeUser.siteAdmin = user.siteAdmin
        homeUser.type = user.type
        homeUser.url = user.url
        
        save()
    }
    
    func addBatchHomeUser(with users: [User]) {
        
        _ = users.compactMap { user in
            guard checkIfUserExisted(for: user.login, id: Int16(user.id)) else {
                print("Existed!")
                return
            }
            
            let homeUser = HomeUserEntity(context: viewContext)
            homeUser.login = user.login
            homeUser.id = Int16(user.id)
            homeUser.avatarUrl = user.avatarURL
            homeUser.gravatarId = user.gravatarID
            homeUser.siteAdmin = user.siteAdmin
            homeUser.type = user.type
            homeUser.url = user.url
        }
        
        save()
    }
    
    func updateData(for user: User) {
        
        let homeUsers = self.fetchSingleUser(for: user.login)
        guard let homeUser = homeUsers.first else { return }
        
        homeUser.name = user.name
        homeUser.blog = user.blog
        homeUser.company = user.company
        homeUser.followers = Int32(user.followers ?? 0)
        homeUser.following = Int32(user.following ?? 0)
        print("Updated for user: \(user.login)")
        save()
    }
    
    func updateData(for user: User, with imageData: Data) {
        let homeUsers = self.fetchSingleUser(for: user.login)
        guard let homeUser = homeUsers.first else { return }
        homeUser.imageData = imageData
        save()
    }
    
    func updateNotes(for user: User, with notes: String) {
        print("Saving notes: \(user.login) -> \(notes)")
        let homeUsers = self.fetchSingleUser(for: user.login)
        guard let homeUser = homeUsers.first else { return }
        homeUser.notes = notes
        save()
    }
    
    func fetchSingleUser(for login: String) -> [HomeUserEntity] {
        
        var users: [HomeUserEntity] = []
        
        do {
            homeUserRequest.predicate = NSPredicate(format: "login == %@", login)
            users = try viewContext.fetch(homeUserRequest)
            return users
        } catch {
            print("Error saving context \(error)")
        }
        
        return users
    }
    
    // Used to check if the data is existed or not.
    private func checkIfUserExisted(for login: String, id: Int16) -> Bool {
        do {
            homeUserRequest.predicate = NSPredicate(format: "login == %@ AND id == %d", login, id)
            let numberOfRecords = try viewContext.count(for: homeUserRequest)
            return numberOfRecords == 0
        } catch {
            print("Error saving context \(error)")
        }
        
        return false
    }
    
    // Delete all the data.
    func deleteAllHomeUser() {
        do {
            let homeUsers = try viewContext.fetch(homeUserRequest)
            _ = homeUsers.map { viewContext.delete($0) }
            save()
        } catch {
            print("Error delete entities: \(error.localizedDescription)")
        }
    }
    
    // Save core data.
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print("Error saving... \(error.localizedDescription)")
            }
        }
    }
}
