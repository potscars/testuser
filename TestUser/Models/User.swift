//
//  User.swift
//  TestUser
//
//  Created by owner on 02/07/2023.
//

import Foundation

// MARK: - User
struct User: Codable {
    let login: String
    let id: Int
    let nodeID: String
    let avatarURL: String
    let gravatarID: String
    let url: String
    //    let url, htmlURL, followersURL: String
    //    let followingURL, gistsURL, starredURL: String
    //    let subscriptionsURL, organizationsURL, reposURL: String
    //    let eventsURL: String
    //    let receivedEventsURL: String
    let type: String
    let siteAdmin: Bool
    let name, company: String?
    let blog: String?
    let location: String?
    let email, hireable, bio: String?
    let twitterUsername: String?
    let publicRepos, publicGists, followers, following: Int?
    let createdAt, updatedAt: String?
    var notes: String?
    var imageData: Data?
    
    enum CodingKeys: String, CodingKey {
        case login, id, notes
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url
        //        case htmlURL = "html_url"
        //        case followersURL = "followers_url"
        //        case followingURL = "following_url"
        //        case gistsURL = "gists_url"
        //        case starredURL = "starred_url"
        //        case subscriptionsURL = "subscriptions_url"
        //        case organizationsURL = "organizations_url"
        //        case reposURL = "repos_url"
        //        case eventsURL = "events_url"
        //        case receivedEventsURL = "received_events_url"
        case type
        case siteAdmin = "site_admin"
        case name, company, blog, location, email, hireable, bio
        case twitterUsername = "twitter_username"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case followers, following
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    static let empty = User(login: "", id: 0, nodeID: "", avatarURL: "", gravatarID: "", url: "", type: "", siteAdmin: false, name: nil, company: nil, blog: nil, location: nil, email: nil, hireable: nil, bio: nil, twitterUsername: nil, publicRepos: nil, publicGists: nil, followers: nil, following: nil, createdAt: nil, updatedAt: nil, notes: nil)
}
