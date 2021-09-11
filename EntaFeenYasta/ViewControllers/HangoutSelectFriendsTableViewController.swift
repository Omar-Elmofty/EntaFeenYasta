//
//  HangoutSelectFriendsTableViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-23.
//

import UIKit


class HangoutSelectFriendsCell: UITableViewCell {
    @IBOutlet weak var name_label: UILabel!
    var friend_id: String?
    // Friend Id -> true if added, false if removed
    var button_completion : ((String) -> Bool)?
    @IBOutlet weak var select_button: UIButton!
    @IBAction func selectButton(_ sender: Any) {
        if let button_completion = button_completion {
            if let friend_id = friend_id
            {
                let added = button_completion(friend_id)
                if (added)
                {
                    select_button.setTitle("Remove", for: .normal)
                }
                else
                {
                    select_button.setTitle("Select", for: .normal)
                }
            }
        }
    }
}

class HangoutSelectFriendsTableViewController: UITableViewController, UISearchResultsUpdating {
    var filtered_friends: [String] = []
    let searchController = UISearchController(searchResultsController: nil)

    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        // Search Controller parameters
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if isFiltering {
            return filtered_friends.count
        }
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        return app_delegate.current_user!.getNumOfFriends()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "select_friends_cell", for: indexPath) as! HangoutSelectFriendsCell

        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let friend_ids = app_delegate.current_user!.getFriends()
        var id: String
        if isFiltering {
            id = filtered_friends[indexPath.row]
        }
        else {
            id = friend_ids[indexPath.row]
        }
        
        let friend = app_delegate.current_user!.getFriend(id)
        if let friend = friend
        {
            cell.name_label!.text = friend.getName()
            cell.friend_id = id
        }
        cell.button_completion = selectButtonPressed
        let added = app_delegate.current_hangout!.isUserInHangout(id)
        if (added)
        {
            cell.select_button.setTitle("Remove", for: .normal)
        }
        else
        {
            cell.select_button.setTitle("Select", for: .normal)
        }
        return cell
    }
    func selectButtonPressed(friend_id: String) -> Bool
    {
        // Add the friend id to hangout
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let nc = presentingViewController as! UINavigationController
        let vc = nc.viewControllers[0] as! HangoutFirstPageViewController
        
        if (app_delegate.current_hangout!.isUserInHangout(friend_id))
        {
            app_delegate.current_hangout!.removeUser(friend_id)
            // Subtract one to remove yourself
            let num_friends = app_delegate.current_hangout!.getNumUsers() - 1
            vc.updateNumFriendsLabel(num_friends)
            return false
        }
        app_delegate.current_hangout!.addUser(friend_id, Constants.UserPrivelage.observer, acceptance_status: Constants.HangoutAcceptanceStatus.waiting_acceptance)
        let num_friends = app_delegate.current_hangout!.getNumUsers() - 1
        vc.updateNumFriendsLabel(num_friends)
        return true
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    func filterContentForSearchText(_ searchText: String) {
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        let friend_ids = app_delegate.current_user!.getFriends()
        filtered_friends = friend_ids.filter { (friend_id: String) -> Bool in
            let friend = app_delegate.current_user!.getFriend(friend_id)
            let friend_name = friend?.getName()
            var name : String = ""
            if let friend_name = friend_name
            {
                name = friend_name
            }
            return name.lowercased().contains(searchText.lowercased())
        }
      tableView.reloadData()
    }
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
