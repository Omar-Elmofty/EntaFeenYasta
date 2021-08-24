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
    var button_completion : ((String) -> Void)?
    @IBOutlet weak var select_button: UIButton!
    
    @IBAction func selectButton(_ sender: Any) {
        if let button_completion = button_completion {
            if let friend_id = friend_id
            {
                button_completion(friend_id)
                select_button.isEnabled = false
                select_button.setTitle("Added", for: .disabled)
            }
        }
    }
}

class HangoutSelectFriendsTableViewController: UITableViewController {

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
        
        return app_delegate.current_user!.getNumOfFriends()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "select_friends_cell", for: indexPath) as! HangoutSelectFriendsCell

        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let friend_ids = app_delegate.current_user!.getFriends()
        let id = friend_ids[indexPath.row]
        
        let friend = app_delegate.current_user!.getFriend(id)
        if let friend = friend
        {
            cell.name_label!.text = friend.getName()
            cell.friend_id = id
        }
        cell.button_completion = selectButtonPressed
        return cell
    }
    func selectButtonPressed(friend_id: String)
    {
        // Add the friend id to hangout
    }

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
