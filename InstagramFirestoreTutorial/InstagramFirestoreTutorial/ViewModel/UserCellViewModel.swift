//
//  UserCellViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Choi SeungHyuk on 2021/05/01.
//

import Foundation

class UserCellViewModel {
    private let user: User
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var username: String {
        return user.username
    }
    
    var fullname: String {
        return user.fullname
    }
    
    init(user: User) {
        self.user = user
    }
}
