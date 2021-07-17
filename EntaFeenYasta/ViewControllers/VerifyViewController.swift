//
//  VerifyViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-07-17.
//

import UIKit

class VerifyViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var verification_code: UITextField!
    
    @IBOutlet weak var error_label: UILabel!
    
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
        verification_code.delegate = self
        Utilities.styleTextField(verification_code)
    }
    
    func transitionToNextVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.add_friends_view_controller)
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
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
        if let verification_code = verification_code.text {
            let trimmed_string = verification_code.trimmingCharacters(in: .whitespaces)
            if (trimmed_string != "")
            {
                error_label.text = ""
                error_label.alpha = 0.0
                authenticateUser(verification_code: trimmed_string) { success in
                    if (success)
                    {
                        self.transitionToNextVC()
                    }
                    else
                    {
                        self.error_label.text = "Unable to sign up, please enter correct verification code"
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
