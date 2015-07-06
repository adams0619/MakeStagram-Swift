//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by ongaga on 6/26/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit
import Bond

class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    @IBOutlet weak var tableView: UITableView!
    
    var photoTakingHelper: PhotoTakingHelper?
    
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
        
        let postsQuery = Post.query()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Trigger timeline request when the view appears, new posts will be loaded if a maunal pull to refresh method
        timelineComponent.loadInitialIfRequired()
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        // Requst timeline for the current user
        ParseHelper.timelineRequestForCurrentUser(range) {
            (result: [AnyObject]?, error: NSError?) -> Void in
            // Handle any errors that might occur
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            // Check the callback and detemrine if it's nil
            let posts = result as? [Post] ?? []
            // Pass the posts to the timelineComponenet
            completionBlock(posts)
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
//Mark: TableView Extension
extension TimelineViewController: UITableViewDataSource {
    // Swap rows/sections in tableView so you can view each post as a section with a proper header containing info on the orgianl poster as well as when the post was posted.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Load data from parse into the corresponding table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell")  as! PostTableViewCell
        let post = timelineComponent.content[indexPath.section]
        //Download image for a post right before it's viewedd
        post.downloadImage()
        //Download the corresponding likes for an image
        post.fetchLikes()
        //Assign the upcoming row the post variable so it can recieve the image once downloaded
        cell.post = post
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostSectionHeaderView
        
        let post = self.timelineComponent.content[section]
        headerCell.post = post
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
}
// Mark:
extension TimelineViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Used to inform the timelineComponent of the next viewable cell
        timelineComponent.targetWillDisplayEntry(indexPath.section)
    }
}



//Mark: Tab Bar Delegate
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