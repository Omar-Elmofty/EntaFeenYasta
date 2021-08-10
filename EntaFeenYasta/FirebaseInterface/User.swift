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
    var dob : String
    var phone_number : String
    var phone_number_ten_digit : String
    var location : [Double] = [0,0]
    var image_name : String
    var friends_ids : Set<String>
    var pending_friends_ids : Set<String>
    var active_hangouts : Set<String>
}

// Class representing user.
class User : MapMarker
{
    // User info
    private var user_info_ : UserInfo
    private let db = Firestore.firestore()
    private var friends_ : [String : User] = [:]
    private var pending_friends_ : [String : User] = [:]
    private var friend_requests_ : Set<String> = []
    private var friend_request_profiles_: [String : User] = [:]
    private var pull_successful_: Bool = false
    private var push_successful_: Bool = false
    
    override init()
    {
        // Initalize an empty struct
        user_info_ = UserInfo(id: "", name: "", dob: "", phone_number: "", phone_number_ten_digit: "", location: [], image_name: "", friends_ids: [], pending_friends_ids: [], active_hangouts: [])
        super.init()
    }
    
    init(user_id: String)
    {
        user_info_ = UserInfo(id: user_id, name: "", dob: "",
                              phone_number: "", phone_number_ten_digit: "", location: [], image_name: "", friends_ids: [], pending_friends_ids: [], active_hangouts: [])
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
            try doc.setData(from: user_info_, merge: true) { (error) in
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
        cleanupPendingFriends()
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
        for friend_id in user_info_.pending_friends_ids
        {
            if pending_friends_[friend_id] != nil
            {
                // Update friends
                pending_friends_[friend_id]?.pullFromFirebase(completion: { user in
                    return true
                })
                continue
            }	
            pending_friends_[friend_id] = User(user_id: friend_id)
        }
        for friend_id in friend_requests_
        {
            if user_info_.friends_ids.contains(friend_id)
            {
                if let index = friend_requests_.firstIndex(of: friend_id) {
                    friend_requests_.remove(at: index)
                }
                friend_request_profiles_.removeValue(forKey: friend_id)
                continue
            }
            if friend_request_profiles_[friend_id] != nil
            {
                // Update friends
                friend_request_profiles_[friend_id]?.pullFromFirebase(completion: { user in
                    return true
                })
                continue
            }
            friend_request_profiles_[friend_id] = User(user_id: friend_id)
        }
        populateFriendRequests()
    }
    func setUserName(_ user_name: String) {
        user_info_.name = user_name
    }
    
    func setDOB(_ dob: String) {
        user_info_.dob = dob
    }
    
    func setPhoneNumber(_ phone_number: String) {
        user_info_.phone_number = phone_number
        user_info_.phone_number_ten_digit = String(phone_number.suffix(10))
    }
    func setID(_ id: String) {
        user_info_.id = id
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

    func getFriends() -> [String] {
        return Array(user_info_.friends_ids)
    }
    func getLocation() -> [Double]
    {
        return user_info_.location
    }
    func isAFriend(_ friend_id: String) -> Bool
    {
        return user_info_.friends_ids.contains(friend_id)
    }
    func isAPendingFriend(_ friend_id: String) -> Bool
    {
        return pending_friends_[friend_id] != nil
    }
    func addPendingFriend(_ friend_id: String)
    {
        user_info_.pending_friends_ids.insert(friend_id)
        try! populateFriends()
    }
    func getNumOfFriends() -> size_t
    {
        return user_info_.friends_ids.count
    }
    func getFriend(_ friend_id: String) -> User?
    {
        return friends_[friend_id]
    }
    func setLocation(_ latitude: Double, _ longtitude: Double)
    {
        user_info_.location[0] = latitude
        user_info_.location[1] = longtitude
    }
    func isMyID(_ id: String) -> Bool
    {
        return id == user_info_.id
    }
    func getPhoneNumber() -> String
    {
        return user_info_.phone_number
    }
    func removeFriend(_ friend_id: String)
    {
        if let index = user_info_.friends_ids.firstIndex(of: friend_id) {
            user_info_.friends_ids.remove(at: index)
        }
        friends_.removeValue(forKey: friend_id)
    }
    func populateFriendRequests()
    {
        let user_db = db.collection("user_db")
        user_db.whereField("pending_friends_ids", arrayContains: user_info_.id) .getDocuments {
            (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if !self.user_info_.friends_ids.contains(document.documentID)
                        {
                            self.friend_requests_.insert(document.documentID)
                        }
                    }
                }
        }
    }
    
    func getNumOfFriendRequests() -> size_t
    {
        return friend_requests_.count
    }
    func getFriendRequests() -> [String]
    {
        return Array(friend_requests_)
    }
    func getFriendwithRequest(_ friend_id: String) -> User?
    {
        return friend_request_profiles_[friend_id]
    }
    func acceptFriendRequest(_ friend_id: String)
    {
        if let index = friend_requests_.firstIndex(of: friend_id) {
            friend_requests_.remove(at: index)
        }
        friend_request_profiles_.removeValue(forKey: friend_id)
        user_info_.friends_ids.insert(friend_id)
    }
    func cleanupPendingFriends()
    {
        var ids_to_remove: Set<String> = []
        for (id, friend) in pending_friends_
        {
            if friend.isAFriend(user_info_.id)
            {
                ids_to_remove.insert(id)
            }
        }
        for id in ids_to_remove
        {
            if let index = user_info_.pending_friends_ids.firstIndex(of: id) {
                user_info_.pending_friends_ids.remove(at: index)
            }
            pending_friends_.removeValue(forKey: id)
        }
    }
}
