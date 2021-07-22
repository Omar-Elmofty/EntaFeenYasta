//
//  PhoneViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-07-17.
//

import UIKit

class PhoneViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phone_number: UITextField!
    
    @IBOutlet weak var error_label: UILabel!
    @IBOutlet weak var next_button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        setUpElements()
    }
    
    func setUpElements() {
        // Hide the error label
        error_label.alpha = 0
        
        // Style the elements
        phone_number.delegate = self
        Utilities.styleTextField(phone_number)
        Utilities.styleHollowButton(next_button)
    }
    
    func transitionToNextVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.verify_code_view_controller)
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

    @IBAction func nextButton(_ sender: Any) {
        if let phone_number = phone_number.text {
            let trimmed_string = phone_number.trimmingCharacters(in: .whitespaces)
            if (trimmed_string != "")
            {
                error_label.text = ""
                error_label.alpha = 0.0
                
                let app_delegate =  UIApplication.shared.delegate as! AppDelegate
                if app_delegate.current_user == nil {
                    app_delegate.current_user = User()
                }
                app_delegate.current_user!.setPhoneNumber(trimmed_string)
                verifyPhoneNumber(phone_number: trimmed_string) { success in
                    if (success)
                    {
                        self.transitionToNextVC()
                    }
                    else
                    {
                        self.error_label.text = "Unable to sign up with entered phone number"
                        self.error_label.alpha = 1.0
                    }
                }
            }
            else
            {
                error_label.text = "Please enter a valid dob."
                error_label.alpha = 1.0
            }
        }
        else
        {
            error_label.text = "Please enter a valid dob."
            error_label.alpha = 1.0
        }
    }
}
