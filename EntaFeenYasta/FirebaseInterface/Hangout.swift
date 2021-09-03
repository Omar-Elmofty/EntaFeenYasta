//
//  Hangout.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
	
/**
 *@brief Class for holding various hangout information, this information will be pushed/pulled to firebase.
 */
struct HangoutInfo : Codable
{
    // Document id, if empty string then a randomly generated id is created
    var id : String
    var name : String
    var type : String
    var location : [Double]
    var image_name : String
    var date : String
    var time : String
    // Map of the users in this hangout session [user_id, user_priviliges]
    var users : [String: [String: String]]
    var users_eta : [String : TimeInterval]
    var location_address: String
    
//    enum CodingKeys: String, CodingKey {
//      // Add alternative key name here
//      case id  // = "document_id" example document_id is an alternative key name to id
//      case name
//      case type
//      case location
//      case image_name
//      case users
//      case users_eta
//    }
}

/**
 *@brief Class for managing a hangout.
 */
class Hangout : MapMarker
{
    // User info
    private var hangout_info_ : HangoutInfo
    private let db = Firestore.firestore()

    private var pull_successful_: Bool = false
    private var push_successful_: Bool = false

    /**
     * @brief Contructor.
     * @param hangout_info Struct holding various hangout info used for initializing hangout.
     */
    init(hangout_info : HangoutInfo) throws
    {
        try! Utilities.checkLocation(hangout_info.location)
        hangout_info_ = hangout_info
        super.init()
        setMarkerData(marker_name: hangout_info_.name, marker_type: "hangout", image_name: hangout_info_.image_name, location: (lattitude: hangout_info_.location[0], longtitude: hangout_info_.location[1]))
        try! pushToFirebase()
    }
    
    /**
     * @brief Contructor.
     */
    override init()
    {
        // Initalize an empty struct
        hangout_info_ = HangoutInfo(id: "", name: "", type: "", location: [], image_name: "", date: "", time: "", users: [:], users_eta: [:], location_address: "")
        super.init()
    }
    /**
     * @brief Push to firebase.
     */
    func pushToFirebase() throws
    {
        push_successful_ = false
        do {
            var doc : DocumentReference
            if hangout_info_.id != ""
            {
                doc = db.collection("hangouts").document(hangout_info_.id)
            }
            else
            {
                doc = db.collection("hangouts").document()
                hangout_info_.id = doc.documentID
            }
            try doc.setData(from: hangout_info_) { (error) in
                    if let error = error {
                        print("Error encountered when setting document: \(error.localizedDescription)")
                    }
                    else
                    {
                        self.push_successful_ = true
                    }
                }
        } catch let error {
            throw AppError.runtimeError("Error encountered during creating hangout : \(error.localizedDescription)")
        }
    }
    
    func pullFromFirebase(completion: @escaping (Hangout) -> Bool)
    {
        pull_successful_ = false
        db.collection("hangouts").document(hangout_info_.id).getDocument { (document, error) in
             if let error = error {
                print("Error ocurred \(error.localizedDescription)")
             }
             let result = Result {
               try document?.data(as: HangoutInfo.self)
             }
             switch result {
             case .success(let hangout_info):
                 if let hangout_info = hangout_info {
                     self.hangout_info_ = hangout_info
                     self.setMarkerData(marker_name: hangout_info.name, marker_type: "hangout", image_name: hangout_info.image_name, location: (lattitude: hangout_info.location[0], longtitude: hangout_info.location[1]))
                      if (!completion(self))
                      {
                        print("Running completion failed.")
                        
                        self.pull_successful_ = true
                      }
                 } else {
                     // A nil value was successfully initialized from the DocumentSnapshot,
                     // or the DocumentSnapshot was nil.
                     print("Document does not exist")
                 }
             case .failure(let error):
                 // A `City` value could not be initialized from the DocumentSnapshot.
                 print("Error decoding hangout info: \(error.localizedDescription)")
             }
         }
    }

    /**
     * @brief Get all user names.
     * @return User names.
     */
    func getUsers() -> [String: [String: String]] {
        return hangout_info_.users
    }

    /**
     * @brief Get hangout session name.
     * @return User names.
     */
    func getName() -> String {
        return hangout_info_.name
    }

    /**
     * @brief Add a user to the hangout session.
     * @param user_id  the user id.
     * @param user_privilege The user privilige.
     */
    func addUser(_ user_id : String, _ user_privilege : String) {
        hangout_info_.users[user_id] = ["privilege": user_privilege]
    }
    
    /**
     * @brief Remove user from the hangout session.
     * @param The user id.
     */
    func removeUser(_ user_id : String) {
        hangout_info_.users.removeValue(forKey: user_id)
    }
    
    /**
     * @brief Add the user Eta for this session.
     * @param user_id The user id.
     * @param eta The eta.
     */
    func addUserETA(user_id : String, eta : TimeInterval)
    {
        hangout_info_.users_eta[user_id] = eta
    }

    /**
     * @brief  Get the user eta.
     * @param user_id Get the user id.
     * @return The eta for this user.
     */
    func getUserETA(_ user_id : String) -> TimeInterval
    {
        if let eta = hangout_info_.users_eta[user_id] {
            return eta
        }
        return 0.0
    }

    /**
     * @brief  Get the hangout location.
     * @return Location of the hangout session [latitude, longtitude]
     */
    func getLocation() -> [Double]
    {
        return hangout_info_.location
    }
    
    func setPrivateStatus(_ is_private: Bool)
    {
        if (is_private)
        {
            hangout_info_.type = "private"
        }
        else
        {
            hangout_info_.type = "public"
        }
    }
    func setName(_ name: String)
    {
        hangout_info_.name = name
    }
    func setDate(_ date: String)
    {
        hangout_info_.date = date
    }
    func setTime(_ time: String)
    {
        hangout_info_.time = time
    }
    func isUserInHangout(_ user_id: String) -> Bool {
        return hangout_info_.users[user_id] != nil
    }
    func getNumUsers() -> size_t {
        return hangout_info_.users.count
    }
    func setLocationAddress(_ location_address: String) {
        hangout_info_.location_address = location_address
    }
    func getType() -> String {
        return hangout_info_.type
    }
    func getTime() -> String {
        return hangout_info_.time
    }
    func addUserLocationSharingOptions(_ user_id: String, _ share_location: Bool, _ start_time: String, _ end_time: String)
    {
        // First retrieve the user
        var dict_ref : [String: String] = [:]
        if (hangout_info_.users[user_id] != nil)
        {
            dict_ref = hangout_info_.users[user_id]!
        }
        if share_location
        {
            dict_ref["share_location"] = "yes"
            dict_ref["start_time"] = start_time
            dict_ref["end_time"] = end_time
        }
        else
        {
            dict_ref["share_location"] = "no"
        }
        hangout_info_.users[user_id] = dict_ref
    }
}
