//
//  AddFriendsViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-07-12.
//

import UIKit
import Contacts
import MessageUI
import Firebase
import FirebaseFirestoreSwift

struct FetchedContact {
    var firstName: String
    var lastName: String
    var telephone: String
}

class ContactTableViewCell: UITableViewCell {
    
    private let db = Firestore.firestore()
    @IBOutlet weak var contact_name: UILabel!
    
    @IBOutlet weak var invite_button: UIButton!
    
    var invite_button_completion : ((String, String) -> Void)?
    
    var phone_number : String?
    
    @IBAction func inviteButton(_ sender: Any) {
        if let contact_name = contact_name.text {
            if let phone_number = phone_number {
                if let invite_button_completion = invite_button_completion {
                    invite_button_completion(contact_name, phone_number)
                }
            }
        }
    }
    
    func checkPhoneNumber()
    {

        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let phone_last_10_digits = String(phone_number!.suffix(10))
        let user_db = db.collection("user_db")
        
        user_db.whereField("phone_number_ten_digit", isEqualTo: phone_last_10_digits) .getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var found_document = false
                for document in querySnapshot!.documents {
                    found_document = true
                    print("last 10 digits \(phone_last_10_digits)")
                    print("document Id found \(document.documentID)")
                    if app_delegate.current_user!.isAFriend(document.documentID)
                    {
                        self.invite_button.isEnabled = false
                        self.invite_button.setTitle("Friend", for: .disabled)
                    }
                    else
                    {
                        self.invite_button.isEnabled = true
                        self.invite_button.setTitle("Send Request", for: .normal)
                        self.invite_button_completion = {(contact_name, phone_num) -> Void in
                            self.invite_button.isEnabled = false
                            self.invite_button.setTitle("Request Sent", for: .disabled)
                            app_delegate.current_user!.addPendingFriend(document.documentID)
                        }
                    }
                }
                if (!found_document)
                {
                    self.invite_button.isEnabled = true
                    self.invite_button.setTitle("Invite", for: .normal)
                    self.invite_button.setTitle("Invite", for: .disabled)
                }
            }
        }
    }
}


class AddFriendsViewController: UITableViewController, MFMessageComposeViewControllerDelegate, UISearchResultsUpdating {
    var contacts = [FetchedContact]()
    var filtered_contacts : [FetchedContact] = []
    let searchController = UISearchController(searchResultsController: nil)
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContacts()

        // Search Controller parameters
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func fetchContacts() {
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                // 2.
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    // 3.
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        self.contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: contact.phoneNumbers.first?.value.stringValue ?? ""))
                    })
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering {
            return filtered_contacts.count
        }
        return contacts.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactTableViewCell
        let contact : FetchedContact
        if isFiltering {
            contact = filtered_contacts[indexPath.row]
        }
        else {
            contact = contacts[indexPath.row]
        }
        cell.invite_button_completion = self.presentMessegeVC
        cell.contact_name?.text = contact.firstName + " " + contact.lastName
        cell.phone_number = contact.telephone
        cell.checkPhoneNumber()
        
        return cell
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
    
    func presentMessegeVC(contact_name: String, phone_number: String) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self

        // Configure the fields of the interface.
        composeVC.recipients = [phone_number]
        composeVC.body = "I love Sawa!"

        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    func filterContentForSearchText(_ searchText: String) {
      filtered_contacts = contacts.filter { (contact: FetchedContact) -> Bool in
        return contact.firstName.lowercased().contains(searchText.lowercased()) || contact.lastName.lowercased().contains(searchText.lowercased())
      }
      tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
