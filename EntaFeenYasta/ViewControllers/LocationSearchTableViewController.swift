//
//  LocationSearchTableViewController.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-08-16.
//

import UIKit
import MapKit

class LocationSearchTableViewController: UITableViewController {

    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var location_result_view: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationSearchTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        searchCompleter.queryFragment = searchBarText
        searchCompleter.region = mapView.region
    }
}


extension LocationSearchTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationSearchCell")!
        let searchResult = searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
}

extension LocationSearchTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: selectedItem)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            if error != nil {
                print("Error encountered \(String(describing: error?.localizedDescription))")
            }
            if let response = response
            {
                self.mapView!.removeAnnotations(self.mapView!.annotations)
                self.dismiss(animated: true, completion: nil)

                if (response.mapItems.count == 1)
                {
                    self.handleMapSearchDelegate?.dropPinZoomIn(placemark: response.mapItems[0].placemark, center_view: true)
                    return
                }
                for item in response.mapItems
                {
                    self.handleMapSearchDelegate?.dropPinZoomIn(placemark: item.placemark, center_view: false)
                }
                
            }
        }
    }
}

extension LocationSearchTableViewController: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
    }

    func completer(completer: MKLocalSearchCompleter, didFailWithError error: NSError) {
        print("Error encountered \(error.localizedDescription)")
    }
}
