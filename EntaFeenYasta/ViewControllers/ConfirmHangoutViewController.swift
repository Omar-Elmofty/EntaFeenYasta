//
//  ConfirmHangoutViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-25.
//

import UIKit

class ConfirmHangoutViewController: UIViewController {

    @IBOutlet weak var confirmation_text: UILabel!
    @IBOutlet weak var from_time_text_field: UITextField!
    @IBOutlet weak var to_time_text_field: UITextField!
    @IBOutlet weak var confirm_button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        Utilities.styleTextField(from_time_text_field)
        Utilities.styleTextField(to_time_text_field)
        Utilities.styleFilledButton(confirm_button)
        
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let hangout_type = app_delegate.current_hangout!.getType()
        
        if hangout_type == "private"
        {
            confirmation_text.text = "Your location will be shared with people in this hangout only, your location will be shared between the following times. You can turn off your location time at any point in time."
        }
        else if hangout_type == "public"
        {
            confirmation_text.text = "Your location will be shared with people using this app, your location will be shared between the following times. You can turn off your location time at any point in time."
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func confirmButton(_ sender: Any) {
    }
    
}
