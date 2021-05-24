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
    
    var caption: String {
        return post.caption
    }
    
    var likes: Int {
        return post.like
    }
    
    init(post: Post) {
        self.post = post
    }
}
