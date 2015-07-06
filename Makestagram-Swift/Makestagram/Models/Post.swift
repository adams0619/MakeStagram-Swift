//
//  Post.swift
//  Makestagram
//
//  Created by ongaga on 6/26/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond
import ConvenienceKit

class Post : PFObject, PFSubclassing {
    
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    // Create cache to store images rather then loading them from the disk when displayed on-screen
    static var imageCache: NSCacheSwift<String, UIImage>!
    
    //Variable to save the image that will be uploaded to Parse
    var image: Dynamic<UIImage?> = Dynamic(nil)
    //Varaialbe to save the likes
    var likes =  Dynamic<[PFUser]?>(nil)
    
    //Property containing info on the background task for uploading photos
    var photoUploadTask: UIBackgroundTaskIdentifier?
   
    // Check to see which likes are available for the loading posts
    func fetchLikes() {
        // Check to see if the Array of likes objects is nil
        if(likes.value != nil) {
            return
        }
        // Call Parse Helper class to fetch the likes for the current post
        ParseHelper.likesForPost(self, completionBlock: { (var likes: [AnyObject]?, error: NSError?) -> Void in
            // Handle any errors that might occur
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            // Filter the list of likes to remove users who no longer exist
            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            //Return new array containing the filtered results
            self.likes.value = likes?.map { like in
                let like = like as! PFObject
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    //User method to determine if a post is liked by a user and whether the like button should be displayed or not
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return contains(likes, user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if image is liked, unlike it now
            // 1
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this image is not liked yet, like it now
            // 2
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    // Mark: Upload post to Parse
    func uploadPost() {
        let imageData = UIImageJPEGRepresentation(image.value, 0.8)
        let imageFile = PFFile(data: imageData)
        //Create background task for image uploading, End the task if no photo is uploading
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler{ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        //Get callback when the photo upload is complete. End the background Task
        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            // Handle any errors that might occur
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        //Added user info to Image POST
        user = PFUser.currentUser()
        self.imageFile = imageFile
        saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
    }
    
    // Mark: Download images method
    func downloadImage() {
        // Check to see if you can assign the image from the cache if it's already been downloaded
        image.value = Post.imageCache[self.imageFile!.name]
        
        //Download image if it has not yet been downloaded
        if (image.value == nil) {
            //Download in background thread instead of the main (UI) thread
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                // Handle any errors that might occur
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
                if let data = data {
                    //Download image and update post.image accordingly
                    let image = UIImage(data: data, scale: 1.0)!
                    self.image.value = image
                    // Save the downloaded image to the cache
                    Post.imageCache[self.imageFile!.name] = image
                }
            }
        }
    }
    
    //PFSubclassing protocol
    static func parseClassName() -> String {
        return "Post"
    }
    // Initializer Method
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            //Let parse know about the subclass
            self.registerSubclass()
            
            Post.imageCache = NSCacheSwift<String, UIImage>()
        }
    }
}