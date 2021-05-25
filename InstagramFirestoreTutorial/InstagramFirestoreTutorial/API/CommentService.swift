//
//  CommentService.swift
//  InstagramFirestoreTutorial
//
//  Created by Choi SeungHyuk on 2021/05/26.
//

import Firebase

struct CommentService {
    static func uploadComment(comment: String, postID: String, user: User, completion: @escaping(FirestoreCompletion)) {
        let data: [String: Any] = ["uid": user.uid, "comment": comment, "timestamp": Timestamp(date: Date()), "username": user.username, "profileImageUrl": user.profileImageUrl]
        
        COLLECTION_POSTS.document(postID).collection("comments")
            .addDocument(data: data, completion: completion)
    }
    
    
    static func fetchComments() {
        
    }
}
