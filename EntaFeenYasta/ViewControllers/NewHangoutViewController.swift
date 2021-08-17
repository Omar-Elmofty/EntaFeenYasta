//
//  NewHangoutViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-15.
//

import UIKit
import MapKit

class NewHangoutViewController: UIViewController, MKLocalSearchCompleterDelegate, UISearchBarDelegate, UISearchResultsUpdating, UITextFieldDelegate {
    func updateSearchResults(for searchController: UISearchController) {
    }
    



    
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var search_bar: UISearchBar!
    // Create a search completer object
    var searchCompleter = MKLocalSearchCompleter()
    let searchController = UISearchController(searchResultsController: nil)

    // These are the results that are returned from the searchCompleter & what we are displaying
    // on the searchResultsTable
    var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table_view?.delegate = self
        table_view?.dataSource = self
        searchCompleter.delegate = self
        search_bar?.delegate = self
        // Search Controller parameters
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Location"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // This method declares that whenever the text in the searchbar is change to also update
    // the query that the searchCompleter will search based off of
    func textField(_ textField: UITextField, textDidChange text: String) {
        
        print("HEEEEEEEE")
    }
    // This method declares gets called whenever the searchCompleter has new search results
    // If you wanted to do any filter of the locations that are displayed on the the table view
    // this would be the place to do it.
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Setting our searchResults variable to the results that the searchCompleter returned
        searchResults = completer.results

        // Reload the tableview with our new searchResults
        table_view.reloadData()
    }

    // This method is called when there was an error with the searchCompleter
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Error
    }

}
// Setting up extensions for the table view
extension NewHangoutViewController: UITableViewDataSource {
    // This method declares the number of sections that we want in our table.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // This method declares how many rows are the in the table
    // We want this to be the number of current search results that the
    // searchCompleter has generated for us
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    // This method declares the cells that are table is going to show at a particular index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Get the specific searchResult at the particular index
       let searchResult = searchResults[indexPath.row]

       //Create  a new UITableViewCell object
       let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

       //Set the content of the cell to our searchResult data
       cell.textLabel?.text = searchResult.title
       cell.detailTextLabel?.text = searchResult.subtitle

       return cell
    }
}
extension NewHangoutViewController: UITableViewDelegate {
    // This method declares the behavior of what is to happen when the row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true)

       let result = searchResults[indexPath.row]
       let searchRequest = MKLocalSearch.Request(completion: result)

       let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                    return
                }

           guard let name = response?.mapItems[0].name else {
                 return
           }

           let lat = coordinate.latitude
           let lon = coordinate.longitude

           print(lat)
           print(lon)
           print(name)

         }
    }
}
