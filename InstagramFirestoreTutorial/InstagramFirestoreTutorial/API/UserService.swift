//
//  UserService.swift
//  InstagramFirestoreTutorial
//
//  Created by Choi SeungHyuk on 2021/04/21.
//

import Firebase

struct UserService {
    static func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            print("DEBUG : \(snapshot?.data())")
        }
    }
}
