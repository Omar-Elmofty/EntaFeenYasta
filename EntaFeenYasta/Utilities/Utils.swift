//
//  Utils.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-23.
//

import Foundation
import UIKit

class Utilities {
    static func checkLocation(_ location : [Double]) throws
    {
        if location.count != 2 {
            throw AppError.runtimeError("Location size must be equal to 2, input count is \(location.count)")
        }

        // Check latitude
        if (location[0] < -90.0) || (location[0] > 90.0) {
            throw AppError.runtimeError("Latitude \(location[0]) is out of bounds")
        }

        // Check longtitude
        if (location[1] < -180.0) || (location[1] > 180.0) {
            throw AppError.runtimeError("Longtitude \(location[1]) is out of bounds")
        }
    }

    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 222/255, green: 177/255, blue: 54/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Chalkduster", size: 20)
    }

    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.backgroundColor = nil
        button.layer.borderWidth = 2
        button.layer.borderColor = CGColor.init(red: 222/255, green: 177/255, blue: 54/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Chalkduster", size: 20)
    }

    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
//        textfield.layer.addSublayer(bottomLine)
        textfield.font = UIFont(name: "Chalkduster", size: 30)
        textfield.backgroundColor = UIColor.init(red: 115/255, green: 96/255, blue: 54/255, alpha: 1)
        textfield.layer.cornerRadius = 25.0
    }
    
}

