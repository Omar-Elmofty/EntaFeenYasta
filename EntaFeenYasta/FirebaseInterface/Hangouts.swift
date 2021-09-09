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
    private var hangouts_: [String: Hangout] = [:]
    private var hangout_user_pull_push_ = FirebasePullPush<HangoutUsers>()
    private var hangouts_to_push_: [Hangout] = []
    private var hangouts_push_in_progress_: [Hangout] = []
    
    init ()
    {
        hangout_user_pull_push_.collection_name = Constants.Firebase.hangouts_collection_name
        hangout_user_pull_push_.sub_collection_name = Constants.Firebase.hangout_users_collection_name
    }
    
    func updateAllHangouts()
    {
        if hangouts_to_push_.count > 0 {
            
            for hangout in hangouts_to_push_
            {
                hangout.pushToFirebase()
                hangouts_push_in_progress_.append(hangout)
            }
            hangouts_to_push_ = []
            print("Hangouts [updateAllHangouts]: To push queue not empty, exiting before pull.")
            return
        }
        
        if hangouts_push_in_progress_.count > 0 {
            var success = true
            for hangout in hangouts_push_in_progress_
            {
                success = success && hangout.pushSuccessful()
            }
            if (success)
            {
                hangouts_push_in_progress_ = []
                print("Hangouts [updateAllHangouts]: Push in progress queue is now empty, starting to pull.")
            }
            else
            {
                print("Hangouts [updateAllHangouts]: Push in progress queue not empty, exiting before pull.")
                return
            }
        }
        
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        if (app_delegate.current_user == nil)
        {
            return
        }
        let current_user_id = app_delegate.current_user!.getId()
        hangout_user_pull_push_.searchSubcollections(field: "user_id", value: current_user_id) { result_list in
            var hangout_ids : [String] = []
            for user_info in result_list
            {
                let hangout_id = user_info.hangout_id
                hangout_ids.append(hangout_id)
                let hangout = Hangout(hangout_id: hangout_id)
                hangout.setHangoutID(hangout_id)
                hangout.pullFromFirebase()
                self.hangouts_[hangout_id] = hangout
            }

            // Delete additional hangouts not on firebase
            for (hangout_id, _) in self.hangouts_
            {
                if let _ = hangout_ids.firstIndex(of: hangout_id) {
                }
                else{
                    self.hangouts_.removeValue(forKey: hangout_id)
                }
            }
        }
    }

    func addHangout(_ hangout: Hangout)
    {
        hangouts_to_push_.append(hangout)
    }
    func getNumOfHangouts() -> size_t
    {
        return hangouts_.count + hangouts_to_push_.count + hangouts_push_in_progress_.count
    }
    func getAllHangouts() -> [Hangout]
    {
        var hangouts : [Hangout] = []
        for (_, hangout) in hangouts_
        {
            hangouts.append(hangout)
        }

        hangouts.append(contentsOf: hangouts_to_push_)
        hangouts.append(contentsOf: hangouts_push_in_progress_)
        
        return hangouts
    }
}
