//
//  NameViewController.swift
//  EntaFeenYasta
//
//  Created by Ahmed Elmeligi on 2021-07-11.
//

import UIKit

class NameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var user_name: UITextField!
    @IBOutlet weak var error_label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setUpElements()
    }
    
    func setUpElements() {
        // Hide the error label
        error_label.alpha = 0
        
        // Style the elements
        user_name.delegate = self
        Utilities.styleTextField(user_name)
    }

    func transitionToDOBVC() {
        let dob_vc = storyboard?.instantiateViewController(identifier: Constants.Storyboard.dob_view_controller)
        present(dob_vc!, animated: true, completion: nil)
    }

    @IBAction func nextButton(_ sender: Any) {
        if let user_name = user_name.text {
            let trimmed_string = user_name.trimmingCharacters(in: .whitespaces)
            if (trimmed_string != "")
            {
                let app_delegate =  UIApplication.shared.delegate as! AppDelegate
                if app_delegate.current_user == nil {
                    app_delegate.current_user = User()
                }
                app_delegate.current_user!.setUserName(trimmed_string)
                error_label.text = ""
                error_label.alpha = 0.0
                transitionToDOBVC()
            }
            else
            {
                error_label.text = "Please enter a valid name."
                error_label.alpha = 1.0
            }
        }
        else
        {
            error_label.text = "Please enter a valid name."
            error_label.alpha = 1.0
        }
    }
}
