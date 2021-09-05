//
//  Hangouts.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-09-04.
//

import Foundation
import UIKit

class Hangouts
{
    // Dict of all hangouts [hangout_id : Hangout Object]
    private var hangouts: [String: Hangout] = [:]
    private var hangout_pull_push = FirebasePullPush<HangoutUsers>()
    
    init ()
    {
        hangout_pull_push.collection_name = Constants.Firebase.hangouts_collection_name
        hangout_pull_push.sub_collection_name = Constants.Firebase.hangout_users_collection_name
    }
    
    func pullAllHangouts()
    {
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        if (app_delegate.current_user == nil)
        {
            return
        }
        let current_user_id = app_delegate.current_user!.getId()
        hangout_pull_push.searchSubcollections(field: "user_id", value: current_user_id) { result_dict in
            
            var hangout_ids : [String] = []
            for (_, user_info) in result_dict
            {
                let hangout_id = user_info.hangout_id
                hangout_ids.append(hangout_id)
                let hangout = Hangout()
                hangout.setHangoutID(hangout_id)
                hangout.pullFromFirebase()
                self.hangouts[hangout_id] = hangout
            }
            
            // Delete additional hangouts not on firebase
            for (hangout_id, _) in self.hangouts
            {
                if let _ = hangout_ids.firstIndex(of: hangout_id) {
                }
                else{
                    self.hangouts.removeValue(forKey: hangout_id)
                }
            }
        }
    }

    func addHangout(_ hangout: Hangout)
    {
        hangouts[hangout.getID()] = hangout
    }
}
