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
    
    // Following Relation
    static let ParseFollowClass = "Follow"
    static let ParseFollowFromUser = "fromUser"
    static let ParseFollowToUser = "toUser"
    
    // Like Relation
    static let ParseLikeClass = "Like"
    static let ParseLikeToPost = "toPost"
    static let ParseLikeFromUser = "fromUser"
    
    // Post Relation
    static let ParsePostUser = "user"
    static let ParsePostCreatedAt = "createdAt"
    
    // Flagged Content Relation
    static let ParseFlaggedContentClass = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost = "toPost"
    
    // User Relations
    static let ParseUserUsername = "username"
    
    // Mark: Used to get timeline requests of posts/metadata
    static func timelineRequestForCurrentUser(completionBlock: PFArrayResultBlock) {
        //Get list of people that the user currently follows
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseLikeFromUser, equalTo:PFUser.currentUser()!)
        //Getting pictures from the other followed users
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        //Getting the list of posts that the current user has made
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        //Combined the query from the two blocks of code above
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        //Used to also download associated user info from Posts (i.e. usernames)
        query.includeKey(ParsePostUser)
        //Order post in the by the most recent first (chronological order
        query.orderByDescending(ParsePostCreatedAt)
        
        //Return query results to the class/func which called this function
        query.findObjectsInBackgroundWithBlock(completionBlock)

        
    }
    
    // Mark: Like a post and save it to Parse
    static func likePost(user: PFUser, post: Post) {
        //Generate a like Object from the user and the current post
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        //Save like Object to Parse
        likeObject.saveInBackgroundWithBlock(nil)
    }
    // Mark: Unlike a given post it to Parse
    static func unlikePost(user: PFUser, post: Post) {
        // Use query to find the like from a user that corresponds to a given post
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        // Complete task in background rather then the main thread
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            // Handle any errors that might occur
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            
            // Iterate through Parse to find all likeObjects that contain our given parameters
            if let results = results as? [PFObject] {
                for likes in results {
                    likes.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    // Mark: Look for all the likes on a post
    static func likesForPost(post: Post, completionBlock: PFArrayResultBlock) {
        // Create query to search for all the likes for a given post
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        // Look for all the users in who liked the given post. Complete action in the background
        query.includeKey(ParseLikeFromUser)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    
}
