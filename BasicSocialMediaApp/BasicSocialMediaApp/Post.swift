//
//  Post.swift
//  BasicSocialMediaApp
//
//  Created by Eren Berkay Dinç on 27.05.2022.
//

import Foundation

class Post{
    
    
    
    var email:String
    var title:String
    var imageURL:String
    var date:Date
    
    init(email:String,title:String,imageURL:String,date:Date) {
        self.email = email
        self.title = title
        self.imageURL = imageURL
        self.date = date
      
    }
    
}
