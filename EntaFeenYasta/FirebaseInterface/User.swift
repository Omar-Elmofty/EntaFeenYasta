//
//  User.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// Struct holding various user info, loadable from Json
struct UserInfo : Codable
{
    var id : String
    var name : String
    var location : [Double]
    var image_name : String
    var friends_ids : Set<String>
    var active_hangouts : Set<String>
}

// Class representing user.
class User : MapMarker
{
    // User info
    private var user_info_ : UserInfo
    private let db = Firestore.firestore()
    private var friends_ : [String : User] = [:]
    private var pull_successful_: Bool = false
    private var push_successful_: Bool = false
    
    override init()
    {
        // Initalize an empty struct
        user_info_ = UserInfo(id: "", name: "", location: [], image_name: "", friends_ids: [], active_hangouts: [])
        super.init()
    }

    init(user_info : UserInfo)
    {
        try! Utilities.checkLocation(user_info.location)
        user_info_ = user_info
        super.init()
        setMarkerData(marker_name: user_info_.name, marker_type: "user", image_name: user_info_.image_name, location: (lattitude: user_info_.location[0], longtitude: user_info_.location[1]))
        try! pushToFirebase()
        try! self.populateFriends()
    }
    
    init(user_id: String)
    {
        user_info_ = UserInfo(id: user_id, name: "", location: [], image_name: "", friends_ids: [], active_hangouts: [])
        super.init()
        pullFromFirebase { (user) in
            return true
        }
    }
    
    /**
     * @brief Push to firebase.
     */
    func pushToFirebase() throws
    {
        push_successful_ = false
        do {
            var doc : DocumentReference
            if user_info_.id != ""
            {
                doc = db.collection("user_db").document(user_info_.id)
            }
            else
            {
                doc = db.collection("user_db").document()
                user_info_.id = doc.documentID
            }
            try doc.setData(from: user_info_) { (error) in
                    if let error = error {
                        print("Error encountered when setting document: \(error.localizedDescription)")
                    }
                    else
                    {
                        self.push_successful_ = true
                    }
                }
        } catch let error {
            throw AppError.runtimeError("Error encountered during creating user : \(error.localizedDescription)")
        }
    }
    
    func pullFromFirebase(completion: @escaping (User) -> Bool)
    {
        pull_successful_ = false
        db.collection("user_db").document(user_info_.id).getDocument { (document, error) in
             if let error = error {
                print("Error ocurred \(error.localizedDescription)")
             }
             let result = Result {
               try document?.data(as: UserInfo.self)
             }
             switch result {
             case .success(let user_info):
                 if let user_info = user_info {
                     self.user_info_ = user_info
                     self.setMarkerData(marker_name: user_info.name, marker_type: "user", image_name: user_info.image_name, location: (lattitude: user_info.location[0], longtitude: user_info.location[1]))
                     try! self.populateFriends()
                    
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
                 print("Error decoding user info: \(error.localizedDescription)")
             }
         }
    }
    
    func populateFriends() throws
    {
        for friend_id in user_info_.friends_ids
        {
            if friends_[friend_id] != nil
            {
                // Update friends
                friends_[friend_id]?.pullFromFirebase(completion: { user in
                    return true
                })
                continue
            }
            friends_[friend_id] = User(user_id: friend_id)
        }
    }
    func setUserName(_ user_name: String) {
        user_info_.name = user_name
    }

    func addHangout(_ hangout_name : String)
    {
        user_info_.active_hangouts.insert(hangout_name)
    }

    func removeHangout(_ hangout_name : String)
    {
        if let index = user_info_.active_hangouts.firstIndex(of: hangout_name) {
            user_info_.active_hangouts.remove(at: index)
        }
    }

    func getName() -> String {
        return user_info_.name
    }

    func getActiveHangouts() -> Set<String> {
        return user_info_.active_hangouts
    }

    func getFriends() -> Set<String> {
        return user_info_.friends_ids
    }
    func getLocation() -> [Double]
    {
        return user_info_.location
    }
}
