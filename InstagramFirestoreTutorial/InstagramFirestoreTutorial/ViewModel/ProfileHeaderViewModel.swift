//
//  ProfileHeaderViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Choi SeungHyuk on 2021/04/21.
//

import Foundation

struct ProfileHeaderViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var followButtonText: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        
        return user.isFollowed ? "Following" : "Follow"
    }
    
    init(user: User) {
        self.user = user
    }
}
