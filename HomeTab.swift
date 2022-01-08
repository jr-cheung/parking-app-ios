//
//  HomeTab.swift
//  jasoncheung-project
//
//  Created by user177077 on 7/3/20.
//  Copyright © 2020 Jason Cheung. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Code for the Home Tab
class HomeTab: UIViewController{
    // MARK: - CoreData Array
    var parkers: [NSManagedObject] = []
    var currentParker: Parker?
    
    // MARK: - Message Labels
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var parkButton: UIButton!
    @IBOutlet weak var registerInfo: UILabel!
    
    // MARK: - Tap to Park Button press
    @IBAction func parkButtonTap(_ sender: Any) {
        performSegue(withIdentifier: "segueToRegister", sender: self)
    }
    
    // MARK: - View setup functions
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
        
        // Display Greeting Message
        let parkerName = UserDefaults.standard.string(forKey: "currentParker")
        var index = -1
        if parkerName != nil{
            // Find index if a Parker exists
            index = findParkerIndex(parkerName!)
            if index != -1{
                currentParker = parkers[index] as? Parker
                welcomeMessage.text = "Hello " + (currentParker?.name)! + "!"
                parkButton.isEnabled = true
            }
        }
        else{
            // No user logged in
            welcomeMessage.text = "Please log in to park."
        }
        
        // Display Registration info if it exists
        if currentParker?.lot != nil && currentParker?.time != nil{
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd h:mm a"
            let expirationDateString = df.string(from: (currentParker?.time)!)
            registerInfo.text = "You have a registration at Lot " + (currentParker?.lot)! + ". Expires: " + expirationDateString
            registerInfo.isHidden = false
        }
        else{
            registerInfo.isHidden = true
        }
    }
    
    // Unwind back home from Register screen
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue){
    }
    

    // MARK: - Get parker index function
    
    // Returns index of Parker if found. If not found, returns -1
    func findParkerIndex(_ parkerName: String) -> Int{
        if parkers.count == 0{
            return -1
        }
        for i in 0...parkers.count-1{
            let parker = parkers[i] as? Parker
            if parker?.name == parkerName{
                return i
            }
        }
        return -1
    }
}
