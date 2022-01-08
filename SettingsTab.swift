//
//  SettingsTab.swift
//  jasoncheung-project
//
//  Created by user177077 on 7/3/20.
//  Copyright © 2020 Jason Cheung. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Code for the Settings Tab
class SettingsTab: UIViewController, UITextFieldDelegate{
    // MARK: - CoreData Array
    var parkers: [NSManagedObject] = []
    var currentParker: Parker?
    
    // MARK: - TextFields for user attributes
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var licensePlateField: UITextField!
    @IBOutlet weak var makeField: UITextField!
    @IBOutlet weak var modelField: UITextField!
    @IBOutlet weak var colorField: UITextField!
    
    // MARK: - Hide Keyboard function upon pressing "return"
    func textFieldShouldReturn(_ textField: UITextField) ->Bool{
        self.view.endEditing(true)
        return false
    }
    
    // MARK: - View setup functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get CoreData
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Parker")
        do{
            parkers = try managedContext.fetch(fetchRequest)
        } catch let e as NSError{
            print("Fetch Parkers Failed", e)
        }
        
        
        // Populate user data into textfields if user logged in
        let name = UserDefaults.standard.string(forKey: "currentParker")
        let index = findParkerIndex(name)
        if index != -1{
                let parker = parkers[index] as? Parker
                nameField.text = currentParker?.name
                licensePlateField.text = currentParker?.licensePlate
                makeField.text = currentParker?.make
                modelField.text = currentParker?.model
                colorField.text = currentParker?.color
                currentParker = parker  // set the current Parker
        }
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get updated CoreData array: parkers
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Parker")
        do{
            parkers = try managedContext.fetch(fetchRequest)
        } catch let e as NSError{
            print("Fetch Parkers Failed", e)
        }

        // Populate user data into textfields if user logged in
        let name = UserDefaults.standard.string(forKey: "currentParker")
        let index = findParkerIndex(name)
        if index != -1{
                let parker = parkers[index] as? Parker
                nameField.text = currentParker?.name
                licensePlateField.text = currentParker?.licensePlate
                makeField.text = currentParker?.make
                modelField.text = currentParker?.model
                colorField.text = currentParker?.color
                currentParker = parker // set the current Parker
        }
    }
    
    // MARK: - Login Function
    // Logs in the user if the user exists. If user doesn't exist, show error popup.
    @IBAction func loadParker(_ sender: Any) {
        let index = findParkerIndex(nameField.text!)
        if index != -1{
            // Parker with given name already exists so populate data and set currentParker to the Parker
            let parker = parkers[index] as? Parker
            licensePlateField.text = parker?.licensePlate
            makeField.text = parker?.make
            modelField.text = parker?.model
            colorField.text = parker?.color
            
            currentParker = parker
            UserDefaults.standard.set(currentParker?.name, forKey: "currentParker") // For use by HomeTab.swift
          
            
            // Popup Confirmation Successful Load
            let alert = UIAlertController(title: "Load Successful", message: "Parker successfully loaded.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler:{ (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            // Popup Confirmation Fail Load
            let alert = UIAlertController(title: "Load Failed", message: "Parker does not exist. Please create new parker.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler:{ (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Function for Create/Update Parker button
    // Creates a parker if a parker with given Name does not exist. Updates a parker if a parker with given Name exists.
    @IBAction func createUpdateParker(_ sender: Any) {
        // Get core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Parker", in: managedContext)
        
        // Check for missing fields. If so, display error popup.
        if (nameField.text == "" || licensePlateField.text == "" || makeField.text == "" || modelField.text == "" || colorField.text == ""){
            let alert = UIAlertController(title: "Error", message: "Please make sure all the fields are filled in.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler:{ (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        // If there is no current parker, create a new parker.
        else if currentParker == nil{

            let parker = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            parker.setValue(nameField.text, forKey: "name")
            parker.setValue(licensePlateField.text, forKey: "licensePlate")
            parker.setValue(makeField.text, forKey: "make")
            parker.setValue(modelField.text, forKey: "model")
            parker.setValue(colorField.text, forKey: "color")
            currentParker = parker as? Parker
            UserDefaults.standard.set(currentParker?.name, forKey: "currentParker") // Used by HomeTab.swift
          
            // Save new Parker to CoreData
            do{
                try managedContext.save()
                parkers.append(parker)
            }catch let e as NSError{
                print("Save Failed", e)
            }
            
            // Show alert confirming parker creation
            let alert = UIAlertController(title: "Create Success", message: "Parker successfully created.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler:{ (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
            
        // Find parker in parkers array. If it exists based on name, update info. If name doesn't exist, create new parker
        else{
            let index = findParkerIndex(nameField.text!)
            if index != -1{
                
                // Parker with given name already exists, so just update info
                let parker = parkers[index]
                parker.setValue(licensePlateField.text, forKey: "licensePlate")
                parker.setValue(makeField.text, forKey: "make")
                parker.setValue(modelField.text, forKey: "model")
                parker.setValue(colorField.text, forKey: "color")
                currentParker = parker as? Parker
                UserDefaults.standard.set(currentParker?.name, forKey: "currentParker")
               
                // Display update confirmation popup
                let alert = UIAlertController(title: "Update Success", message: "Parker successfully updated.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler:{ (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
                
            // Parker does not exist, so create new Parker
            else{
                let parker = NSManagedObject(entity: entity!, insertInto: managedContext)
                
                parker.setValue(nameField.text, forKey: "name")
                parker.setValue(licensePlateField.text, forKey: "licensePlate")
                parker.setValue(makeField.text, forKey: "make")
                parker.setValue(modelField.text, forKey: "model")
                parker.setValue(colorField.text, forKey: "color")
                currentParker = parker as? Parker
                UserDefaults.standard.set(currentParker?.name, forKey: "currentParker") // Used by HomeTab.swift
                
                // Add new Parker to CoreData
                do{
                    try managedContext.save()
                    parkers.append(parker)
                }catch let e as NSError{
                    print("Save Failed", e)
                }
                
                // Display alert confirming parker creation
                let alert = UIAlertController(title: "Create Success", message: "Parker successfully created.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler:{ (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Function to get a Parker from CoreData array
    // If Parker found, returns index of the Parker in array. If not found, returns -1.
    func findParkerIndex(_ parkerName: String?) -> Int{
        if parkers.count == 0 || parkerName == nil{
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
