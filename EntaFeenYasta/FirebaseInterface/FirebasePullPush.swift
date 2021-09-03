//
//  FirebasePullPush.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-09-03.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// Class for handling pulling / pushing functionality from firebase
// T: template for codeable struct that will be pulled / pushed from firebase
class FirebasePullPush<T: Codable>
{
    // Struct that can hold any info that will be
    var codeable_struct: T?
    var collection_name: String?
    var document_id: String?
    var sub_collection_name: String?
    var sub_document_id: String?

    var db = Firestore.firestore()
    
    // Constructor
    init()
    {
    }
    
    // Pull from firebase
    func pullFromFirebase(sub_collection: Bool, completion: ((T) -> Void)?)
    {
        if (codeable_struct == nil || collection_name == nil || document_id == nil)
        {
            print("FirebasePullPush [pullFromFirebase]: Error nil entries found")
            return
        }
        
        if (sub_collection && (sub_collection_name == nil || sub_document_id == nil))
        {
            print("FirebasePullPush [pullFromFirebase]: Error subcollection nil entries found")
            return
        }

        var doc_ref = db.collection(collection_name!).document(document_id!)
        if (sub_collection)
        {
            doc_ref = doc_ref.collection(sub_collection_name!).document(sub_document_id!)
        }

        
        doc_ref.getDocument { (document, error) in
             if let error = error {
                print("Error ocurred \(error.localizedDescription)")
             }
            
             let result = Result {
               try document?.data(as: T.self)
             }
             switch result {
             case .success(let cd_struct):
                 if let cd_struct = cd_struct {
                    self.codeable_struct = cd_struct
                    
                    if let completion = completion
                    {
                        completion(self.codeable_struct!)
                    }
                 } else {
                     print("FirebasePullPush [pullFromFirebase]: Document does not exist")
                 }
             case .failure(let error):
                 // A `City` value could not be initialized from the DocumentSnapshot.
                 print("FirebasePullPush [pullFromFirebase]: Error decoding hangout info: \(error.localizedDescription)")
             }
         }
    }
    
    // Push to firebase, returns the document id.
    func pushToFirebase(sub_collection: Bool) -> String
    {
        var doc_id : String = ""
        if (codeable_struct == nil || collection_name == nil)
        {
            print("FirebasePullPush [pushToFirebase]: Error nil entries found")
            return doc_id
        }
        if (sub_collection && sub_collection_name == nil)
        {
            print("FirebasePullPush [pushToFirebase]: Error subcollection nil entries found")
            return doc_id
        }
        do {
            var doc : DocumentReference
            if let document_id = document_id
            {
                doc = db.collection(collection_name!).document(document_id)
                doc_id = document_id
            }
            else
            {
                doc = db.collection(collection_name!).document()
                doc_id = doc.documentID
            }
            if (sub_collection)
            {
                if let sub_document_id = sub_document_id
                {
                    doc = doc.collection(sub_collection_name!).document(sub_document_id)
                    doc_id = sub_document_id
                }
                else
                {
                    doc = doc.collection(sub_collection_name!).document()
                    doc_id = doc.documentID
                }
            }
            try doc.setData(from: codeable_struct!) { (error) in
                    if let error = error {
                        print("FirebasePullPush [pushToFirebase]: Error encountered when setting document: \(error.localizedDescription)")
                    }
                }
        } catch let error {
            print("FirebasePullPush [pushToFirebase]: Error encountered when pushing to firebase: \(error.localizedDescription)")
        }
        return doc_id
    }
    
    
    
}
