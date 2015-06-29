//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by ongaga on 6/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Bond


class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var post: Post? {
        didSet {
            //Use optional binding to check if value is nil
            if let post = post {
                //Create bidning between downloaded images and our image view
                post.image ->> postImageView
            }
        }
    }
}
