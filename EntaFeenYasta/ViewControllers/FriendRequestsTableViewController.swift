//
//  FriendRequestsTableViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-09.
//

import UIKit


class FriendRequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name_label: UILabel!
    var friend_id: String?
    @IBOutlet weak var accept_button: UIButton!
    @IBAction func acceptButton(_ sender: Any) {
        if let friend_id = friend_id
        {
            let app_delegate =  UIApplication.shared.delegate as! AppDelegate
            app_delegate.current_user!.acceptFriendRequest(friend_id)
            accept_button.isEnabled = false
            accept_button.setTitle("Request Accepted", for: .disabled)
        }
    }
}

class FriendRequestsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        return app_delegate.current_user!.getNumOfFriendRequests()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestTableViewCell

        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let friend_ids = app_delegate.current_user!.getFriendRequests()
        let id = friend_ids[indexPath.row]
        
        let friend = app_delegate.current_user!.getFriendwithRequest(id)
        if let friend = friend
        {
            cell.name_label!.text = friend.getName()
            cell.friend_id = id
        }
        return cell
    }
}
