//
//  HangoutFirstPageViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-16.
//

import UIKit
import MapKit

class HangoutFirstPageViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var location_text_label: UILabel!
    @IBOutlet weak var friends_text_label: UILabel!
    @IBOutlet weak var private_button: UIButton!
    @IBOutlet weak var public_button: UIButton!
    @IBOutlet weak var hangout_name: UITextField!
    @IBOutlet weak var hangout_date: UITextField!
    @IBOutlet weak var hangout_time: UITextField!
    @IBOutlet weak var error_label: UILabel!
    @IBOutlet weak var pick_location_button: UIButton!
    @IBOutlet weak var create_hangout_button: UIButton!
    @IBOutlet weak var pick_friends_button: UIButton!
    private var is_private : Bool?
    private var is_location_set: Bool = false
    private var friends_selected: Bool = false
    private var hangout : Hangout?
    private var date_picker: UIDatePicker?
    private var time_picker: UIDatePicker?
    private var selected_location_coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        setUpElements()
        setupDateAndTimePickers()
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        app_delegate.current_hangout = Hangout(hangout_id: NSUUID().uuidString)
        let current_user_id = app_delegate.current_user!.getId()
        app_delegate.current_hangout!.addUser(current_user_id, Constants.UserPrivelage.admin, acceptance_status: Constants.HangoutAcceptanceStatus.accepted)
    }
    func setupDateAndTimePickers () {
        date_picker = UIDatePicker()
        time_picker = UIDatePicker()
        date_picker!.preferredDatePickerStyle = .wheels
        time_picker!.preferredDatePickerStyle = .wheels
        date_picker!.datePickerMode = .date
        time_picker!.datePickerMode = .time
        
        date_picker!.addTarget(self, action: #selector(HangoutFirstPageViewController.dateChanged), for: .valueChanged)
        time_picker!.addTarget(self, action: #selector(HangoutFirstPageViewController.timeChanged), for: .valueChanged)
        hangout_date.inputView = date_picker
        hangout_time.inputView = time_picker
        dateChanged(input_date_picker: date_picker!)
        timeChanged(input_date_picker: time_picker!)
    }
    @objc func dateChanged(input_date_picker: UIDatePicker) {
        let date_formatter = DateFormatter()
        date_formatter.dateStyle = .short
        hangout_date.text = date_formatter.string(from: input_date_picker.date)
    }
    @objc func timeChanged(input_date_picker: UIDatePicker) {
        let date_formatter = DateFormatter()
        date_formatter.timeStyle = .short
        hangout_time.text = date_formatter.string(from: input_date_picker.date)
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
        Utilities.styleHollowButton(pick_friends_button)
        Utilities.styleFilledButton(create_hangout_button)
        Utilities.styleHollowButton(private_button)
        Utilities.styleHollowButton(public_button)
    }

    func transitionToLocationVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.hangout_pick_location_view_controller)
        present(vc!, animated: true, completion: nil)
    }
    func transitionToFriendsVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.hangout_select_friends_vc)
        present(vc!, animated: true, completion: nil)
    }
    func transitionToConfirmationVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.confirm_hangout_vc)
        present(vc!, animated: true, completion: nil)
    }
    func updateLocation(_ new_location: String, _ coordinate: CLLocationCoordinate2D) {
        location_text_label.text = new_location
        selected_location_coordinate = coordinate
        is_location_set = true
        Utilities.styleFilledButton(pick_location_button)
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
        transitionToLocationVC()
    }
    @IBAction func pickFriends(_ sender: Any) {
        transitionToFriendsVC()
    }
    
    @IBAction func createHangoutButton(_ sender: Any) {
        
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

        if (name == "" || date == "" || time == "" || is_private == nil || !is_location_set || !friends_selected)
        {
            error_label.text = "Please fill all fields"
            error_label.alpha = 1.0
            return
        }
        error_label.text = ""
        error_label.alpha = 0.0

        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        if app_delegate.current_hangout == nil {
            app_delegate.current_hangout = Hangout(hangout_id: NSUUID().uuidString)
        }

        app_delegate.current_hangout!.setPrivateStatus(is_private!)
        app_delegate.current_hangout!.setName(name)
        app_delegate.current_hangout!.setDate(date)
        app_delegate.current_hangout!.setTime(time)
        app_delegate.current_hangout!.setLocationAddress(location_text_label.text!)
        app_delegate.current_hangout!.setLocation(selected_location_coordinate)
        
        transitionToConfirmationVC()
    }
    
    func updateNumFriendsLabel(_ num_of_friends: size_t) {
        if (num_of_friends == 0)
        {
            friends_text_label.text = "No friends selected"
            friends_selected = false
            Utilities.styleHollowButton(pick_friends_button)
        }
        else if (num_of_friends ==  1)
        {
            friends_text_label.text = "\(num_of_friends) friend selected"
            friends_selected = true
            Utilities.styleFilledButton(pick_friends_button)
        }
        else
        {
            friends_text_label.text = "\(num_of_friends) friends selected"
            friends_selected = true
            Utilities.styleFilledButton(pick_friends_button)
        }
    }
}
