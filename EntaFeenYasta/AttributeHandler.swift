//
//  AttributeHandler.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-16.
//

import Foundation

// Class for handling reading and writing json into dictionary
class AttributeHandler {
    
    // Dict containing all user info
    private var dict_ : [String : Any]    = [:]
    
    // Function that converts dict_ into json
    // @param json_dir Directory to which json will be written
    // @return True if writing json is successful, false otherwise.
    func toJson(json_dir : String) -> Bool
    {
        do
        {
            let json_data = try JSONSerialization.data(withJSONObject : dict_, options : .prettyPrinted)
            try json_data.write(to: URL(fileURLWithPath: json_dir))
            return true
        }
        catch
        {
            print("Exception Caught during Json Serialization: \(error)")
        }
        return false
    }

    // Function that reads json and writes into dict_
    // @param json_dir Directory from which json will be loaded
    // @return True if reading json is successful, false otherwise.
    func fromJson(json_dir : String) -> Bool
    {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: json_dir), options: .mappedIfSafe)
            dict_ = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as?     [String: Any] ?? [:]
            return true
        } catch {
            print("Exception Caught during Json Serialization: \(error)")
        }
        return false
    }
    
    // Function for getting a specific key from json
    // @param key The key of the value to retrieve.
    // @param value[out] The retrieved value will be stored here.
    // @return True if parameter retrieval is successful, false otherwise.
    func get<T>(_ key : String, _ value : inout T) -> Bool
    {
        if let retrieved_value = dict_[key] as? T
        {
            value = retrieved_value
            return true
        }
        else
        {
            print("Parameter \(key) does not exist in map or is of the wrong type.")
        }
        return false
    }

    // Set a value in the dictionary.
    // @param key The key of the value to be set.
    // @param value The value to set.
    func set<T>(_ key : String, _ value : T)
    {
        dict_[key] = value
    }
}
