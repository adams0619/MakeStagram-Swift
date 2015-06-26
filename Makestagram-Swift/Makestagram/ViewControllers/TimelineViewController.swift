//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by ongaga on 6/26/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    var photoTakingHelper: PhotoTakingHelper?



    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBarController?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
//Mark Tab Bar Delegate
extension TimelineViewController: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            takePhoto()
            return false
        } else {
            return true
        }
    }
    
    func takePhoto() {
        //Used to intantiate the photo taking class and provide a callback for when the photo tab item is selected.
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!, callback: { (image: UIImage?) in
            //TODO -- nothing yet
            println("Recived callback contaning image")
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            let imageFile = PFFile(data: imageData)
            imageFile.save()
            //Code used for actual postting
            let post = PFObject(className: "Post")
            post["imageFile"] = imageFile
            post.save()
            println("Image Posted to Parse")
            
        })

    }
}