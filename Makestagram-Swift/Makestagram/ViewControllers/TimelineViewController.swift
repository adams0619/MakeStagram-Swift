//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by ongaga on 6/26/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import Bond

class TimelineViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var photoTakingHelper: PhotoTakingHelper?
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tabBarController?.delegate = self
        
        let postsQuery = Post.query()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Used to start the query process from the ParseHelper Class
        ParseHelper.timelineRequestForCurrentUser {(result: [AnyObject]?, error: NSError?) -> Void in
            //Return empty array if the returned Posts are invalid
            self.posts = result as? [Post] ?? []
            //Load data into the table View
            self.tableView.reloadData()
        }
        
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
extension TimelineViewController: UITableViewDataSource {
    //Create a table with enough rows to show all the posts dat asection from Parse
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    //Load data from parse into the corresponding table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell")  as! PostTableViewCell
        let post = posts[indexPath.row]
        //Download image for a post right before it's viewedd
        post.downloadImage()
        //Download the corresponding likes for an image
        post.fetchLikes()
        //Assign the upcoming row the post variable so it can recieve the image once downloaded
        cell.post = post
        
        return cell
    }
    
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
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            //Simplified Code used for postting to Parse
            let post = Post()
            post.image.value = image
            post.uploadPost()
        }
    }
}