//
//  PostViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Choi SeungHyuk on 2021/05/23.
//

import Foundation

struct PostViewModel {
    private let post: Post
    
    var imageUrl: URL? {
        return URL(string: post.imageUrl)
    }
    
    var userProfileImageUrl: URL? {
        return URL(string: post.ownerImageUrl)
    }
    
    var username: String { return post.ownerUsername }
    
    var caption: String {
        return post.caption
    }
    
    var likes: Int {
        return post.like
    }
    
    var likesLabelText: String {
        if post.like != 1 {
            return "\(post.like) likes"
        } else {
            return "\(post.like) like"
        }
    }
    
    init(post: Post) {
        self.post = post
    }
}
