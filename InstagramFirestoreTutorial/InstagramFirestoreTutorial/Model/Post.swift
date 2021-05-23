//
//  Post.swift
//  InstagramFirestoreTutorial
//
//  Created by Choi SeungHyuk on 2021/05/23.
//

import Firebase

struct Post {
    var caption: String
    var like: Int
    let imageUrl: String
    let ownerUid: String
    let timestamp: Timestamp
    let postId: String
    
    init(postId: String, dictionary: [String: Any]) {
        self.postId = postId
        self.caption = dictionary["caption"] as? String ?? ""
        self.like = dictionary["like"] as? Int ?? 0
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? .init(date: Date())
    }
}
