//
//  RegisterView.swift
//  jasoncheung-project
//
//  Created by user177077 on 7/4/20.
//  Copyright © 2020 Jason Cheung. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Code for the parking registration screen
class RegisterView: UIViewController{
    // MARK: - CoreData array
    var parkers: [NSManagedObject] = []
    var currentParker: Parker?
    
    // MARK: - Lot and Time TextFields
    @IBOutlet weak var lotField: UITextField!
    @IBOutlet weak var minutesField: UITextField!
    @IBOutlet weak var hoursField: UITextField!
    
    // MARK: - Data to be used by picker scroll wheel
    let lotData = ["A", "B", "C"]
    let hourData = [0, 1, 2, 3, 4]
    let minutesData = [0, 15, 30, 45]
    
    var lotPicker = UIPickerView()
    var hourPicker = UIPickerView()
    var minutePicker = UIPickerView()
    
    // MARK: - View setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lotField.inputView = lotPicker
        minutesField.inputView = minutePicker
        hoursField.inputView = hourPicker
        
        lotPicker.delegate = self
        lotPicker.dataSource = self
        hourPicker.delegate = self
        hourPicker.dataSource = self
        minutePicker.delegate = self
        minutePicker.dataSource = self
        
        lotPicker.tag = 1
        hourPicker.tag = 2
        minutePicker.tag = 3
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
    }
    
    // MARK: - Function to get Parker index from array
    // Returns the index of Parker if found, -1 if not found
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
    

    // MARK: - Prepare for segue back to HomeTab function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check for missing Fields
        let lotFieldIsEmpty = (lotField.text ?? "").isEmpty
        let hoursFieldIsEmpty = (hoursField.text ?? "").isEmpty
        let minutesFieldIsEmpty = (minutesField.text ?? "").isEmpty
        if (lotFieldIsEmpty || hoursFieldIsEmpty || minutesFieldIsEmpty){
            // Missing Fields Popup Error Message
            let alert = UIAlertController(title: "Missing Value(s)", message: "Please fill in all fields.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
            
        // No missing fields, so save registration info
        else{
            // Get CoreData
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
    
            let index = findParkerIndex(UserDefaults.standard.string(forKey: "currentParker")!)
            let parker = parkers[index]
            
            // Set Lot
            parker.setValue(lotField.text, forKey: "lot")
            
            // Set Expiration Time
            let currentTime = Date()
            var dateComponent = DateComponents()
            dateComponent.hour = Int(hoursField.text!)
            dateComponent.minute = Int(minutesField.text!)
            let expirationTime = Calendar.current.date(byAdding: dateComponent, to: currentTime)
            parker.setValue(expirationTime, forKey: "time")
            currentParker = parker as? Parker
            
            // Send updated currentParker to HomeTab's currentParker variable
            let destHome = segue.destination as! HomeTab
            destHome.currentParker = currentParker
        }
    }
}

// MARK: Extension for the scrolling picker view
extension RegisterView: UIPickerViewDelegate, UIPickerViewDataSource{
    // MARK: Functions to set up the scrolling picker view
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag{
        case 1:
            return lotData.count
        case 2:
            return hourData.count
        case 3:
            return minutesData.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag{
        case 1:
            return lotData[row]
        case 2:
            return String(hourData[row])
        case 3:
            return String(minutesData[row])
        default:
            return "Null"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag{
        case 1:
            lotField.text = lotData[row]
            lotField.resignFirstResponder()
        case 2:
            hoursField.text = String(hourData[row])
            hoursField.resignFirstResponder()
        case 3:
            minutesField.text = String(minutesData[row])
            minutesField.resignFirstResponder()
        default:
            return
        }
    }
}
