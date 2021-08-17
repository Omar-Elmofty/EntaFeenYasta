//
//  HangoutFirstPageViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-16.
//

import UIKit

class HangoutFirstPageViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var private_button: UIButton!
    @IBOutlet weak var public_button: UIButton!
    @IBOutlet weak var hangout_name: UITextField!
    @IBOutlet weak var hangout_date: UITextField!
    @IBOutlet weak var hangout_time: UITextField!
    @IBOutlet weak var error_label: UILabel!
    @IBOutlet weak var pick_location_button: UIButton!
    
    private var is_private : Bool?
    private var hangout : Hangout?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        setUpElements()
    }
    func setUpElements() {
        // Hide the error label
        error_label.alpha = 0
        
        // Style the elements
        hangout_name.delegate = self
        hangout_date.delegate = self
        hangout_time.delegate = self
        
        Utilities.styleTextField(hangout_name)
        Utilities.styleTextField(hangout_date)
        Utilities.styleTextField(hangout_time)
        Utilities.styleHollowButton(pick_location_button)
        Utilities.styleHollowButton(private_button)
        Utilities.styleHollowButton(public_button)
    }

    func transitionToNextVC() {
        let vc = storyboard?.instantiateViewController(identifier: Constants.Storyboard.hangout_pick_location_view_controller)
        present(vc!, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func privateButton(_ sender: Any) {
        is_private = true
        Utilities.styleFilledButton(private_button)
        Utilities.styleHollowButton(public_button)
    }
    @IBAction func publicButton(_ sender: Any) {
        is_private = false
        Utilities.styleFilledButton(public_button)
        Utilities.styleHollowButton(private_button)
    }
    @IBAction func pickLocation(_ sender: Any) {
        var name : String = ""
        var date : String = ""
        var time : String = ""

        if let hangout_name = hangout_name.text
        {
            name = hangout_name.trimmingCharacters(in: .whitespaces)
        }
        if let hangout_date = hangout_date.text
        {
            date = hangout_date.trimmingCharacters(in: .whitespaces)
        }
        if let hangout_time = hangout_time.text
        {
            time = hangout_time.trimmingCharacters(in: .whitespaces)
        }

        if (name == "" || date == "" || time == "" || is_private == nil)
        {
            error_label.text = "Please fill all fields"
            error_label.alpha = 1.0
            return
        }
        error_label.text = ""
        error_label.alpha = 0.0

        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        if app_delegate.current_hangout == nil {
            app_delegate.current_hangout = Hangout()
        }

        app_delegate.current_hangout!.setPrivateStatus(is_private!)
        app_delegate.current_hangout!.setName(name)
        app_delegate.current_hangout!.setDate(date)
        app_delegate.current_hangout!.setTime(time)
        transitionToNextVC()
    }
    

}
