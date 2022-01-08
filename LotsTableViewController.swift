//
//  LotsTableViewController.swift
//  jasoncheung-project
//
//  Created by user177077 on 7/5/20.
//  Copyright © 2020 Jason Cheung. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Code for the Admin Tab
class LotsTableViewController: UITableViewController{
    // MARK: - Data from CoreData
    var parkers: [NSManagedObject] = []
    var parkersSpecificLot: [NSManagedObject] = []
    var lots = ["A", "B", "C"]
    var selectedRowIndex: Int?
    
    // MARK: - View setup
    override func viewDidLoad() {
        super.viewDidLoad()
    }
       
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Get CoreData
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Parker")
        do{
            parkers = try managedContext.fetch(fetchRequest)
        } catch let e as NSError{
            print("Fetch Parkers Failed", e)
        }
        tableView.reloadData()
    }
    
    // MARK: - TableView Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lots.count
    }
    
    // Get number of lots for the rows
    func getLotCount(lot: String) -> Int{
        var count = 0
        if (!parkers.isEmpty){
            for i in 0...parkers.count-1{
                let p = parkers[i] as? Parker
                let lotName = p?.lot
                if (lotName == lot){
                    count = count + 1
                }
            }
        }
        return count
    }
    
    // Setup the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lotCell", for: indexPath) as! LotsTableViewCell
        let lot = lots[indexPath.row]
        cell.lotName?.text = lot
        cell.numRegistrations?.text = String(getLotCount(lot: lot))
        
        return cell
    }
    
    // Prepare for the segue to registration detailed view table
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send the Parkers corresponding to the Lot to LotsDetailTableViewController
        let destDetail = segue.destination as! LotsDetailTableViewController
        destDetail.parkersSpecificLot = parkersSpecificLot
    }
    
    // Handle Row Selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get all Parkers of the selected Lot
        parkersSpecificLot = []
        let lotName = lots[selectedRowIndex!]
        
        if (parkers.count != 0){
            for i in 0...parkers.count-1{
                let parker = parkers[i] as? Parker
                if parker?.lot == lotName{
                    parkersSpecificLot.append(parkers[i])
                }
            }
        }
        // Segue only if the lot contains registration
        if (parkersSpecificLot.count != 0){
            performSegue(withIdentifier: "segueToDetailedTable", sender: self)
        }
    }
}

// MARK: - Custom TableView Cell
class LotsTableViewCell: UITableViewCell{
    @IBOutlet weak var lotName: UILabel!
    @IBOutlet weak var numRegistrations: UILabel!
}
