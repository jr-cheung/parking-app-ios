//
//  LotsDetailTableViewController.swift
//  jasoncheung-project
//
//  Created by user177077 on 7/5/20.
//  Copyright © 2020 Jason Cheung. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Code for detailed view of registrations according to lot
class LotsDetailTableViewController: UITableViewController{
    // MARK: - CoreData array
    var parkersSpecificLot: [NSManagedObject] = []
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - TableView Setup
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkersSpecificLot.count
    }
    
    // Setup the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "registrationCell", for: indexPath) as! LotsDetailTableViewCell
        
        let parker = parkersSpecificLot[indexPath.row] as? Parker
        cell.licenseNum.text = parker?.licensePlate
        
        let make = parker?.make
        let model = parker?.model
        let color = parker?.color
        
        cell.makeModelColor.text = make! + " " + model! + " " + color!
        
        let time = parker?.time
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        let expirationDateString = df.string(from: (time)!)
        cell.expiration.text = "Expires " + expirationDateString
                   
        return cell
    }
    
    // Do Nothing when cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Deleting Registrations Cell Functions
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let delete = deleteAction(at: indexPath)
           return UISwipeActionsConfiguration(actions: [delete])
       }
    
        // Function to "remove" registration data from a Parker
        // Parker attributes "lot" and "time" are set to nil
       func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
           let action = UIContextualAction(style: .destructive, title: "Delete"){(action, view, completion) in
            
            let parker = self.parkersSpecificLot[indexPath.row]
            // "Remove" Registration from Parker (setting lot and time to nil)
            parker.setValue(nil, forKey: "lot")
            parker.setValue(nil, forKey: "time")
            self.parkersSpecificLot.remove(at: indexPath.row)
            
            completion(true)
            self.tableView.reloadData()
           }
           return action
       }
}

// MARK: Custom Cell for Registrations
class LotsDetailTableViewCell: UITableViewCell{
    @IBOutlet weak var licenseNum: UILabel!
    @IBOutlet weak var makeModelColor: UILabel!
    @IBOutlet weak var expiration: UILabel!
}
