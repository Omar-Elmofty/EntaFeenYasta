//
//  SignUpViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-07-13.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var signup_button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Utilities.styleFilledButton(signup_button)
    }
}
