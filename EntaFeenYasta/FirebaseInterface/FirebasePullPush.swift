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
    var collection_name: String?
    var sub_collection_name: String?

    var db = Firestore.firestore()
    
    // Constructor
    init()
    {
    }
    
    // Pull from firebase
    func pullFromFirebase(document_id: String, sub_document_id: String?, completion: ((T) -> Void)?)
    {
        if (collection_name == nil)
        {
            print("FirebasePullPush [pullFromFirebase]: Error nil entries found")
            return
        }

        var doc_ref = db.collection(collection_name!).document(document_id)
        if (sub_collection_name != nil && sub_document_id != nil)
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
                   if let completion = completion
                   {
                       completion(cd_struct)
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
    func pushToFirebase(_ codeable_struct: T, document_id: String?, sub_document_id: String?) -> String
    {
        var doc_id : String = ""
        if (collection_name == nil)
        {
            print("FirebasePullPush [pushToFirebase]: Error nil entries found")
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
            if (sub_collection_name != nil)
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
            try doc.setData(from: codeable_struct) { (error) in
                    if let error = error {
                        print("FirebasePullPush [pushToFirebase]: Error encountered when setting document: \(error.localizedDescription)")
                    }
                }
        } catch let error {
            print("FirebasePullPush [pushToFirebase]: Error encountered when pushing to firebase: \(error.localizedDescription)")
        }
        return doc_id
    }
    
    
    // Returns all documents in a dictionary
    func pullAllDocuments(document_id: String?, completion: @escaping ([String: T])->Void)
    {
        if (collection_name == nil)
        {
            print("FirebasePullPush [pullAllDocuments]: Error nil entries found")
            return
        }
        var collection_ref = db.collection(collection_name!)
        if (sub_collection_name != nil && document_id != nil)
        {
            collection_ref = collection_ref.document(document_id!).collection(sub_collection_name!)
        }
        collection_ref.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("FirebasePullPush [pullAllDocuments]: Error getting documents: \(err)")
            } else {
                var out_dict: [String: T] = [:]
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let result = Result {
                      try document.data(as: T.self)
                    }
                    switch result {
                    case .success(let cd_struct):
                        if let cd_struct = cd_struct {
                            out_dict[document.documentID] = cd_struct
                            
                        } else {
                            print("FirebasePullPush [pullAllDocuments]: Document does not exist")
                        }
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        print("FirebasePullPush [pullAllDocuments]: Error decoding hangout info: \(error.localizedDescription)")
                    }
                }
                completion(out_dict)
            }
        }
    }
    
    func searchSubcollections(field: String, value: String, completion: @escaping ([String: T])->Void)
    {
        if (sub_collection_name == nil)
        {
            print("FirebasePullPush [searchSubcollections]: Error subcollection name is nil")
            return
        }
        db.collectionGroup(sub_collection_name!).whereField(field, isEqualTo: value).getDocuments {
            (querySnapshot, err) in
            if let err = err {
                print("FirebasePullPush [searchSubcollections]: Error getting documents: \(err)")
            } else {
                var out_dict: [String: T] = [:]
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let result = Result {
                      try document.data(as: T.self)
                    }
                    switch result {
                    case .success(let cd_struct):
                        if let cd_struct = cd_struct {
                            out_dict[document.documentID] = cd_struct
                            
                        } else {
                            print("FirebasePullPush [searchSubcollections]: Document does not exist")
                        }
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        print("FirebasePullPush [searchSubcollections]: Error decoding hangout info: \(error.localizedDescription)")
                    }
                }
                completion(out_dict)
            }
        }
    }
    
    func deleteDocument(document_id: String, sub_document_id: String?)
    {
        if (collection_name == nil)
        {
            print("FirebasePullPush [deleteDocument]: Error nil entries found")
            return
        }

        var doc_ref = db.collection(collection_name!).document(document_id)
        if (sub_collection_name != nil && sub_document_id != nil)
        {
            doc_ref = doc_ref.collection(sub_collection_name!).document(sub_document_id!)
        }
        doc_ref.delete()
    }
}
