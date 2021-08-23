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

class FetchedContact {
    enum Status
    {
        case Myself
        case Friend
        case PendingFriend
        case OnApp
        case NotOnApp
    }
    var firstName: String
    var lastName: String
    var telephone: String
    var status : Status = .NotOnApp
    var uid: String?
    
    init(firstN: String, lastN: String, tele: String)
    {
        firstName = firstN
        lastName = lastN
        telephone = tele
    }
    
    func getStatus()
    {
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        
        let phone_last_10_digits = String(telephone.suffix(10))
        let db = Firestore.firestore()
        let user_db = db.collection("user_db")
        user_db.whereField("phone_number_ten_digit", isEqualTo: phone_last_10_digits) .getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.uid = document.documentID
                    if app_delegate.current_user!.isMyID(document.documentID)
                    {
                        self.status = .Myself
                    }
                    else if app_delegate.current_user!.isAFriend(document.documentID)
                    {
                        self.status = .Friend
                    }
                    else if app_delegate.current_user!.isAPendingFriend(document.documentID)
                    {
                        self.status = .PendingFriend
                    }
                    else
                    {
                        self.status = .OnApp
                    }
                }
            }
        }
    }
}

class ContactTableViewCell: UITableViewCell {
    

    @IBOutlet weak var contact_name: UILabel!
    @IBOutlet weak var invite_button: UIButton!
    
    var invite_button_completion : ((String, String) -> Void)?
    
    var phone_number : String?
    var uid: String?
    
    @IBAction func inviteButton(_ sender: Any) {
        if let contact_name = contact_name.text {
            if let phone_number = phone_number {
                if let invite_button_completion = invite_button_completion {
                    invite_button_completion(contact_name, phone_number)
                }
            }
        }
    }
    func sendRequest(_ contact_name: String, _ phone_number: String) -> Void
    {
        let app_delegate =  UIApplication.shared.delegate as! AppDelegate
        self.invite_button.isEnabled = false
        self.invite_button.setTitle("Request Sent", for: .disabled)
        app_delegate.current_user!.addPendingFriend(self.uid!)
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
    var friends_table_view: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContacts()

        // Search Controller parameters
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
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
                        let fetched_contact = FetchedContact(firstN: contact.givenName, lastN: contact.familyName, tele: contact.phoneNumbers.first?.value.stringValue ?? "")
                        fetched_contact.getStatus()
                        self.contacts.append(fetched_contact)
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
        cell.uid = contact.uid
        
        cell.invite_button.isEnabled = true
        cell.invite_button.setTitle("Invite", for: .normal)
        if (contact.status == .Myself)
        {
            cell.invite_button.isEnabled = false
            cell.invite_button.setTitle("That's Me", for: .disabled)
        }
        else if contact.status == .Friend
        {
            cell.invite_button.isEnabled = false
            cell.invite_button.setTitle("Friend", for: .disabled)
        }
        else if (contact.status == .PendingFriend)
        {
            cell.invite_button.isEnabled = false
            cell.invite_button.setTitle("Request Sent", for: .disabled)
        }
        else if (contact.status == .OnApp)
        {
            cell.invite_button.isEnabled = true
            cell.invite_button.setTitle("Send Request", for: .normal)
            cell.invite_button_completion = cell.sendRequest
        }
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
