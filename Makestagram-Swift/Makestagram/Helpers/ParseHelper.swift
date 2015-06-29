//
//  ParseHelper.swift
//  Makestagram
//
//  Created by ongaga on 6/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    static func timelineRequestForCurrentUser(completionBlock: PFArrayResultBlock) {
        //Get list of people that the user currently follows
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        //Getting pictures from the other followed users
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        //Getting the list of posts that the current user has made
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
        //Combined the query from the two blocks of code above
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        //Used to also download associated user info from Posts (i.e. usernames)
        query.includeKey("user")
        //Order post in the by the most recent first (chronological order
        query.orderByDescending("createdAt")
        
        //Return query results to the class/func which called this function
        query.findObjectsInBackgroundWithBlock(completionBlock)

        
    }
    
    
    
}
