//
//  Post.swift
//  DrawForFriends
//
//  Created by Baris Araci on 5/1/17.
//  Copyright © 2017 Baris Araci. All rights reserved.
//

import Foundation

class Post: NSObject {
    
    let postId : String
    let userId : String
    let imageId : String
    let username : String
    var date : Int64
    
    init (postId: String, userId: String, imageId: String, username: String, date: Int64) {
        self.postId = postId
        self.userId = userId
        self.imageId = imageId
        self.username = username
        self.date = date
    }
    
}
