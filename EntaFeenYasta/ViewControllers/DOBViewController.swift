//
//  DOBViewController.swift
//  EntaFeenYasta
//
//  Created by Ahmed Elmeligi on 2021-07-11.
//

import UIKit

class DOBViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var dob: UITextField!
    
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
        dob.delegate = self
        Utilities.styleTextField(dob)
        Utilities.styleHollowButton(next_button)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func transitionToNextVC() {
        let vc = storyboard?.instantiateViewController(identifier: Constants.Storyboard.phone_view_controller)
        present(vc!, animated: true, completion: nil)
    }

    @IBAction func nextButton(_ sender: Any) {
        if let dob = dob.text {
            let trimmed_string = dob.trimmingCharacters(in: .whitespaces)
            if (trimmed_string != "")
            {
                let app_delegate =  UIApplication.shared.delegate as! AppDelegate
                if app_delegate.current_user == nil {
                    app_delegate.current_user = User()
                }
                app_delegate.current_user!.setDOB(trimmed_string)
                error_label.text = ""
                error_label.alpha = 0.0
                transitionToNextVC()
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
