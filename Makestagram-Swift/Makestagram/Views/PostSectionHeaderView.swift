//
//  PostSectionHeaderView.swift
//  Makestagram
//
//  Created by Adams Ombonga on 7/6/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class PostSectionHeaderView: UITableViewCell {
    
    @IBOutlet weak var postTimeLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    // Set the header for the username to correspond to the username of the user who posted the current Post
    var post: Post? {
        didSet {
            if let post = post {
                // Show the username
                usernameLabel.text = post.user?.username
                // Show the time which has passed since this post was created otherwise show an empty string
                postTimeLabel.text = post.createdAt?.shortTimeAgoSinceDate(NSDate()) ?? ""
            }
        }
    }
    
    
}
