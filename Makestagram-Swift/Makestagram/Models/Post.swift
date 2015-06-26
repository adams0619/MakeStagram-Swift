//
//  Post.swift
//  Makestagram
//
//  Created by ongaga on 6/26/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse

class Post : PFObject, PFSubclassing {
    
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    //Variable to save the image that will be uploaded to Parse
    var image: UIImage?
    //Property containing info on the background task for uploading photos
    var photoUploadTask: UIBackgroundTaskIdentifier?
   
    func uploadPost() {
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let imageFile = PFFile(data: imageData)
        //Create background task for image uploading, End the task if no photo is uploading
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler{ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        //Get callback when the photo upload is complete. End the background Task
        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        //Added user info to Image POST
        user = PFUser.currentUser()
        self.imageFile = imageFile
        saveInBackgroundWithBlock(nil)
    }
    
    
    //PFSubclassing protocol
    static func parseClassName() -> String {
        return "Post"
    }
    
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            //Let parse know about the subclass
            self.registerSubclass()
        }
    }
}