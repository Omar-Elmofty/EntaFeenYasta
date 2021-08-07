//
//  FriendDetailsViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-07.
//

import UIKit

class FriendDetailsViewController: UIViewController {
    
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var phone_number_label: UILabel!
    @IBOutlet weak var unfriend_button: UIButton!
    var friend_id: String?
    var friend: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        friend = app_delegate.current_user!.getFriend(friend_id ?? "")
        name_label.text = friend?.getName()
        phone_number_label.text = friend?.getPhoneNumber()
    }
    

    @IBAction func unfriendButton(_ sender: Any) {
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        app_delegate.current_user!.removeFriend(friend_id ?? "")
        unfriend_button.isEnabled = false
        unfriend_button.setTitle("You're No Longer Friends", for: .disabled)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
