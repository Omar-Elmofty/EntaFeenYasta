//
//  HangoutsTableViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-09-04.
//

import UIKit


class HangoutTableViewCell: UITableViewCell {
    @IBOutlet weak var hangout_name_label: UILabel!
    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var location_label: UILabel!
    
}

class HangoutsTableViewController: UITableViewController {
    private var hangouts_: [Hangout] = []
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
        hangouts_ = app_delegate.hangouts!.getAllHangouts()
        return hangouts_.count
    }

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.TableViewCells.hangout_cell_reuse_identifier, for: indexPath) as! HangoutTableViewCell

        let hangout = hangouts_[indexPath.row]
        
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        let user_id = app_delegate.current_user!.getId()

        let user_info = hangout.getUser(user_id)
        
        cell.location_label.isHidden = true
        if Hangout.userLocationLive(user_info!)
        {
            cell.location_label.isHidden = false
        }

        if (user_info!.acceptance_status == Constants.HangoutAcceptanceStatus.accepted)
        {
            cell.description_label.text = "Accepted"
        }
        else if (user_info!.acceptance_status == Constants.HangoutAcceptanceStatus.waiting_acceptance)
        {
            cell.description_label.text = "Pending Acceptance"
            cell.location_label.isHidden = false
        }
        else if (user_info!.acceptance_status == Constants.HangoutAcceptanceStatus.declined)
        {
            cell.description_label.text = "Declined"
            cell.location_label.isHidden = false
        }

        cell.hangout_name_label.text = hangout.getName()

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let hangout = hangouts_[indexPath.row]
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        app_delegate.current_hangout = hangout
        transitionToNextVC()
    }
    
    func transitionToNextVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.hangout_edit_vc)
        present(vc!, animated: true, completion: nil)
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
