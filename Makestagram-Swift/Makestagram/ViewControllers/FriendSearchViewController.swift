//
//  FriendSearchViewController.swift
//  Makestagram
//
//  Created by ongaga on 6/26/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import ConvenienceKit
import Parse

class FriendSearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Variable used to store an array of the users for the current search query
    var users: [PFUser]?
    
    // Variable used to create a local cache of the users which can be used for changing the tableView data as the user enters input into the search bar
    var followingUsers: [PFUser]? {
        didSet {
            //Users to refresh the table view with the search results as the  users changes their search parameters
            tableView.reloadData()
        }
    }
    
    // A parse query for list of users that match the search parameters
    var query: PFQuery? {
        didSet {
            // Cancel previous search requests whenever a new one is created
            oldValue?.cancel()
        }
    }
    
    // Use to change the state of the search bar accordinglu
    enum State {
        case DefaultMode
        case SearchMode
    }
    // Change the current state of the search bar and complete/updte queries accordingly when the state is changed
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                query = ParseHelper.allUsers(updateList)
            case .SearchMode:
                // Set the search bar text or change the text to an empty string if nothing was entered
                let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText, completionBlock: updateList)
            }
        }
    }
    
    // MARK: Update List function
    func updateList(results: [AnyObject]?, error: NSError?) {
        // Set this to n empty array if the results are nil
        self.users = results as? [PFUser] ?? []
        self.tableView.reloadData()
        
        if let error = error {
            ErrorHandling.defaultErrorHandler(error)
        }
    }

    // MARK: View Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Set the search bar to the default state when this view appears
        state = .DefaultMode
        // Query Parse for the followed users of the current user and store it in a local cache variable
        ParseHelper.getFollowingUsersForUser(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            // If no results set thus to an empty array
            let relations = results as? [PFObject] ?? []
            // Use map to tranform follow objects into readable users
            self.followingUsers = relations.map {
                $0.objectForKey(ParseHelper.ParseFollowToUser) as! PFUser
            }
            
            if let error = error {
                // Default error handling for any errors that occur
                ErrorHandling.defaultErrorHandler(error)
            }
        }
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

// MARK: TableView Data Source -- Relationship between UI tableview and the rest of the data
extension FriendSearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return 0 if there are no users
        return self.users?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! FriendSearchTableViewCell
        let user = users![indexPath.row]
        cell.user = user
        // Check to determine if the current user is following the displayed user in the given row and change the follow button image accordingly
        if let followingUsers = followingUsers {
            cell.canFollow = !contains(followingUsers, user)
        }
        
        cell.delegate = self
        return cell
    }
}


// MARK: Search Bar Delegate
extension FriendSearchViewController: UISearchBarDelegate {
    // Function used in chaning the state of the search bar as text is input
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // Search bar is no longer first responder for input text
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        ParseHelper.searchUsers(searchText, completionBlock:updateList)
    }
}
// MARK: FriendSearchTableViewCell Delegate
extension FriendSearchViewController: FriendSearchTableViewCellDelegate {
    func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser) {
        ParseHelper.addFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
        // Update local cache of the users this current user is following
        followingUsers?.append(user)
    }
    
    func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser) {
        if var followingUsers = followingUsers {
            ParseHelper.removeFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
            
            removeObject(user, fromArray: &followingUsers)
            self.followingUsers = followingUsers
        }
    }
}
