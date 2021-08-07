//
//  FriendsViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-06.
//

import UIKit



class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var name_label: UILabel!
    var friend_id: String?
    var button_completion : ((String) -> Void)?
    
    @IBAction func detailsButton(_ sender: Any) {
        if let button_completion = button_completion {
            if let friend_id = friend_id
            {
                button_completion(friend_id)
            }
        }
    }
    
}


class FriendsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        let item = self.navigationItem.rightBarButtonItem!
//        let button = item.customView as! UIButton
//        button.setTitle("Add Friends", for: .normal)
//        self.navigationItem.rightBarButtonItem!.action = #selector(self.myRightSideBarButtonItemTapped(_:))
        let rightBarButton = UIBarButtonItem(title: "Add Friends", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.myRightSideBarButtonItemTapped(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

    @objc func myRightSideBarButtonItemTapped(_ sender:UIBarButtonItem!)
    {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.add_friends_view_controller)
        present(vc!, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        return app_delegate.current_user!.getNumOfFriends()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell_Friend", for: indexPath) as! FriendTableViewCell

//        cell.contact_name?.text = contact.firstName + " " + contact.lastName

        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let friend_ids = app_delegate.current_user!.getFriends()
        let id = friend_ids[indexPath.row]
        
        let friend = app_delegate.current_user!.getFriend(id)
        if let friend = friend
        {
            cell.name_label!.text = friend.getName()
            cell.friend_id = id
        }
        cell.button_completion = self.presentDetailedFriendVC
        return cell
    }
    
    func presentDetailedFriendVC(friend_id: String)
    {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.friend_details_view_controller) as! FriendDetailsViewController
        vc.friend_id = friend_id

        present(vc, animated: true, completion: nil)
    }        
}
