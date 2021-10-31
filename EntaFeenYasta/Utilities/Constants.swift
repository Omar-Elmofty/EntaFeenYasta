//
//  Constants.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-07-12.
//

import Foundation

struct Constants {
    struct Storyboard {
        static let sign_up_view_controller = "SignUpVC"
        static let name_view_controller = "NameVC"
        static let dob_view_controller = "DOBVC"
        static let home_view_controller = "HomeVC"
        static let add_friends_view_controller = "AddFriendsVC"
        static let phone_view_controller = "PhoneVC"
        static let verify_code_view_controller = "VerifyVC"
        static let friends_view_controller = "FriendsVC"
        static let friend_details_view_controller = "FriendDetailsVC"
        static let friend_requests_view_controller = "FriendRequestVC"
        static let new_hangout_view_controller = "NewHangoutVC"
        static let hangout_first_page_view_controller = "HangoutFirstPageVC"
        static let hangout_pick_location_view_controller = "PickLocationVC"
        static let location_search_view_controller = "LocationSearchVC"
        static let hangout_select_friends_vc = "HangoutSelectFriendsVC"
        static let confirm_hangout_vc = "ConfirmHangoutVC"
        static let hangouts_vc = "HangoutsListVC"
        static let hangout_edit_vc = "Hangout_Edit_VC"

        struct TableViewCells {
            static let hangout_cell_reuse_identifier = "HangoutCell"
        }
    }
    struct Firebase {
        static let hangouts_collection_name = "hangouts"
        static let users_collection_name = "users"
        static let hangout_users_collection_name = "hangout_users"
    }
    struct UserPrivelage
    {
        static let admin = "admin"
        static let observer = "observer"
    }
    struct HangoutAcceptanceStatus
    {
        static let waiting_acceptance = "waiting_acceptance"
        static let accepted = "accepted"
        static let declined = "declined"
    }

    struct DateAndTime
    {
        static let date_and_time_format = "yyyy-MM-dd hh:mm a"
        static let date_format = "yyyy-MM-dd"
        static let time_format = "hh:mm a"
    }
}
