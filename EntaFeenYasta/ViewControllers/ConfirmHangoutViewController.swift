//
//  ConfirmHangoutViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-25.
//

import UIKit

class ConfirmHangoutViewController: UIViewController {

    @IBOutlet weak var to_label: UILabel!
    @IBOutlet weak var from_label: UILabel!
    @IBOutlet weak var share_location_switch: UISwitch!
    @IBOutlet weak var confirmation_text: UILabel!
    @IBOutlet weak var from_time_text_field: UITextField!
    @IBOutlet weak var to_time_text_field: UITextField!
    @IBOutlet weak var confirm_button: UIButton!
    private var start_time_picker: UIDatePicker?
    private var end_time_picker: UIDatePicker?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        Utilities.styleTextField(from_time_text_field)
        Utilities.styleTextField(to_time_text_field)
        Utilities.styleFilledButton(confirm_button)
        printConfirmationText()
        setupDateAndTimePickers()
    }
    
    func printConfirmationText()
    {
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let hangout_type = app_delegate.current_hangout!.getType()
        confirmation_text.contentMode = .scaleToFill
        confirmation_text.numberOfLines = 0
        
        if hangout_type == "private"
        {
            confirmation_text.text = "Your location will be shared with people in this hangout only, your location will be shared between the following times. You can stop sharing your location anytime."
        }
        else if hangout_type == "public"
        {
            confirmation_text.text = "Your location will be shared with people using this app, your location will be shared between the following times. You can stop sharing your location anytime."
        }
    }
    
    func setupDateAndTimePickers () {
        start_time_picker = UIDatePicker()
        end_time_picker = UIDatePicker()
        start_time_picker!.preferredDatePickerStyle = .wheels
        end_time_picker!.preferredDatePickerStyle = .wheels
        start_time_picker!.datePickerMode = .dateAndTime
        end_time_picker!.datePickerMode = .dateAndTime
        
        start_time_picker!.addTarget(self, action: #selector(ConfirmHangoutViewController.startTimeChanged), for: .valueChanged)
        end_time_picker!.addTarget(self, action: #selector(ConfirmHangoutViewController.endTimeChanged), for: .valueChanged)
        from_time_text_field.inputView = start_time_picker
        to_time_text_field.inputView = end_time_picker
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = Constants.DateAndTime.time_format
        
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        let hangout_time = app_delegate.current_hangout!.getTime()
        let hangout_date = date_formatter.date(from: hangout_time)
        
        var modifiedDate = Calendar.current.date(byAdding: .hour, value: -1, to: hangout_date!)!
        start_time_picker?.date = modifiedDate
        from_time_text_field.text = date_formatter.string(from: modifiedDate)
        
        modifiedDate = Calendar.current.date(byAdding: .hour, value: 6, to: hangout_date!)!
        end_time_picker?.date = modifiedDate
        to_time_text_field.text = date_formatter.string(from: modifiedDate)
    }
    
    @objc func startTimeChanged(input_date_picker: UIDatePicker) {
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = Constants.DateAndTime.time_format
        
        from_time_text_field.text = date_formatter.string(from: input_date_picker.date)
    }
    @objc func endTimeChanged(input_date_picker: UIDatePicker) {
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = Constants.DateAndTime.time_format
    
        to_time_text_field.text = date_formatter.string(from: input_date_picker.date)
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
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.home_view_controller)
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let current_user_id = app_delegate.current_user!.getId()
        if (share_location_switch.isOn)
        {
            let start_time = from_time_text_field.text ?? ""
            let end_time = to_time_text_field.text ?? ""
            
            let date_formatter = DateFormatter()
            date_formatter.dateFormat = Constants.DateAndTime.time_format
            date_formatter.amSymbol = "AM"
            date_formatter.pmSymbol = "PM"
            
            let hangout_time = app_delegate.current_hangout!.getTime()
            let hangout_date = app_delegate.current_hangout!.getDate()
            
            let time = date_formatter.date(from: hangout_time)
            
            let start = date_formatter.date(from: start_time)
            let end = date_formatter.date(from: end_time)
            
            let elapsed_start_secs_1 = start!.timeIntervalSince(time!)
            let elapsed_end_secs = end!.timeIntervalSince(time!)
            
            date_formatter.dateFormat = Constants.DateAndTime.date_and_time_format
            
            let hangout_date_time = date_formatter.date(from: hangout_date + " " + hangout_time)
//            let hangout_date_time_start = hangout_date_time!.addingTimeInterval(-elapsed_start_secs)

            print(hangout_date + hangout_time)
//            print(date_formatter.string(from: hangout_date_time_start))
            
            app_delegate.current_hangout!.addUserLocationSharingOptions(current_user_id, true, start_time, end_time)
        }
        else
        {
            app_delegate.current_hangout!.addUserLocationSharingOptions(current_user_id, false, "", "")
        }
        
        
        // Add hangout to push queue
        app_delegate.hangouts?.addHangout(app_delegate.current_hangout!)
        
        // Reset current hangout
        app_delegate.current_hangout = nil
        transitionToNextVC()
    }
    
    @IBAction func shareLocationSwitch(_ sender: Any) {
        if (share_location_switch.isOn)
        {
            printConfirmationText()
            from_time_text_field.isHidden = false
            to_time_text_field.isHidden = false
            from_label.isHidden = false
            to_label.isHidden = false
        }
        else
        {
            confirmation_text.text = "Your location will not be shared."
            from_time_text_field.isHidden = true
            to_time_text_field.isHidden = true
            from_label.isHidden = true
            to_label.isHidden = true
        }
    }
}
