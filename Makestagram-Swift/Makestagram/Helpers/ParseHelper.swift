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
    
    // User Relations->>
    static let ParseUserUsername = "username"
    
    // Mark: Used to get timeline requests of posts/metadata
    static func timelineRequestForCurrentUser(range: Range<Int>, completionBlock: PFArrayResultBlock) {
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
        // Allows us to define the # of items which match our query that can be skipped
        query.skip = range.startIndex
        // Limit the numvber of items we want to load
        query.limit = range.endIndex - range.startIndex
        
        //Return query results to the class/func which called this function
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
    }
    
    // MARK: Following
    /**
    Fetches all users that the provided user is following.
    
    :param: user The user whose followees you want to retrieve
    :param: completionBlock The completion block that is called when the query completes
    */
    static func getFollowingUsersForUser(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseFollowClass)
        
        query.whereKey(ParseFollowFromUser, equalTo: user)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
    Establishes a follow relationship between two users.
    
    :param: user    The user that is following
    :param: toUser  The user that is being followed
    */
    static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let followObject = PFObject(className: ParseFollowClass)
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowToUser)
        
        followObject.saveInBackgroundWithBlock(nil)
    }
    
    /**
    Deletes a follow relationship between two users.
    
    :param: user    The user that is following
    :param: toUser  The user that is being followed
    */
    static func removeFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let query = PFQuery(className: ParseFollowClass)
        query.whereKey(ParseFollowFromUser, equalTo:user)
        query.whereKey(ParseFollowToUser, equalTo: toUser)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            let results = results as? [PFObject] ?? []
            
            for follow in results {
                follow.deleteInBackgroundWithBlock(nil)
            }
        }
    }
    
    // MARK: Users
    
    /**
    Fetch all users, except the one that's currently signed in.
    Limits the amount of users returned to 20.
    
    :param: completionBlock The completion block that is called when the query completes
    
    :returns: The generated PFQuery
    */
    static func allUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
        let query = PFUser.query()!
        // exclude the current user
        query.whereKey(ParseHelper.ParseUserUsername,
            notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
    
    /**
    Fetch users whose usernames match the provided search term.
    
    :param: searchText The text that should be used to search for users
    :param: completionBlock The completion block that is called when the query completes
    
    :returns: The generated PFQuery
    */
    static func searchUsers(searchText: String, completionBlock: PFArrayResultBlock)
        -> PFQuery {
            /*
            NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
            Regex can be slow on large datasets. For large amount of data it's better to store
            lowercased username in a separate column and perform a regular string compare.
            */
            let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername,
                matchesRegex: searchText, modifiers: "i")
            
            query.whereKey(ParseHelper.ParseUserUsername,
                notEqualTo: PFUser.currentUser()!.username!)
            
            query.orderByAscending(ParseHelper.ParseUserUsername)
            query.limit = 20
            
            query.findObjectsInBackgroundWithBlock(completionBlock)
            
            return query
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

    // Extension to change the meaning of equality in our ParseHelper class
    extension PFObject : Equatable {

    }

    // Function to describe the equlaity of ParseObjects based on thier ObjectID
    public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
        return lhs.objectId == rhs.objectId
    }

