//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by ongaga on 6/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likesIconImageView: UIImageView!
    
    @IBOutlet weak var likesLabel: UILabel!

    @IBOutlet weak var likeButton: UIButton!

    @IBOutlet weak var moreButton: UIButton!
    
    var likeBond: Bond<[PFUser]?>!
    
    
    //Methods to control the actions of the more and like button
    @IBAction func moreButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        println("Like button tapped!")
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var post: Post? {
        didSet {
            // Code for optimizing memory by discarding posts that are no longer displayed
            if let oldValue = oldValue where oldValue != post {
                likeBond.unbindAll()
                postImageView.designatedBond.unbindAll()
                
                if (oldValue.image.bonds.count == 0) {
                    oldValue.image.value = nil
                }
            }
            
            
            //Use optional binding to check if value is nil
            if let post = post {
                //Create binding between downloaded images and our image view
                post.image ->> postImageView
                
                // Create binding between likes property from this postTableView and our likes
                post.likes ->> likeBond
            }
        }
    }
        
    func stringFromUserList(userList: [PFUser]) -> String {
        // Use map to replace PFObjects with actual usernames
        let usernameList = userList.map { user in user.username! }
        // Create single string containing all user that is comma-seperated
        let commaSeperatedList = ", ".join(usernameList)
        
        return commaSeperatedList
    }
    
    // Initializer for the like Bond
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Create new bond similar to the likeBond
        likeBond = Bond<[PFUser]?>() { [unowned self] likeList in
            // Run this blokc of code whenever the number if likes changes
            if let likeList = likeList {
                // Update the list of users who have liked the post
                self.likesLabel.text = self.stringFromUserList(likeList)
                // Change the state of the likeButton
                self.likeButton.selected = contains(likeList, PFUser.currentUser()!)
                // Hide small like button when current post has no likes
                self.likesIconImageView.hidden = (likeList.count == 0)
            } else {
                // If no users like a post then reset everything to default
                self.likesLabel.text = ""
                self.likeButton.selected = false
                self.likesIconImageView.hidden = true
            }
        }
    }
        
}
