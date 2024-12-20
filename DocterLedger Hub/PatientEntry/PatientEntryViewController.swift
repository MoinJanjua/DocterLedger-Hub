//
//  PatientEntryViewController.swift
//  DocterLedger Hub
//
//  Created by ucf 2 on 18/12/2024.
//

import UIKit

class PatientEntryViewController: UIViewController, UITextFieldDelegate {

        @IBOutlet weak var nameTF: UITextField!
        @IBOutlet weak var contactTf: UITextField!
        @IBOutlet weak var addressTf: UITextField!
        @IBOutlet weak var gender: DropDown!
       @IBOutlet weak var bloodgroup: UITextField!
        @IBOutlet weak var other: UITextField!
        
        var datasource = [customerRecord]()
        var selectedRceord: customerRecord?
        var ID = String()
        
        override func viewDidLoad() {
            super.viewDidLoad()
           
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
            gender.delegate = self
            gender.optionArray = ["Male","Female","Other"]
            gender.didSelect { (selectedText, index, id) in
            self.gender.text = selectedText
                
            }
            
            if !(ID.isEmpty)
            {
                nameTF.text = selectedRceord?.Name
                contactTf.text = selectedRceord?.contact
                addressTf.text = selectedRceord?.address
                gender.text = selectedRceord?.gender
                bloodgroup.text = selectedRceord?.bloodgroup
                other.text = selectedRceord?.other
            }
            // Do any additional setup after loading the view.
        }
        
        @objc func hideKeyboard()
        {
           view.endEditing(true)
        }
        
        
         func saveData()
        {
            guard let name = nameTF.text, !name.isEmpty,
                  let contact = contactTf.text, !contact.isEmpty,
                  let gender = gender.text
            else {
                showAlert(title: "Error", message: "Please ensure all required fields are filled in before proceeding.")
                return
            }
            
          
            let adress = addressTf.text ?? ""
            let bloodgroup = bloodgroup.text ?? ""
            let other = other.text ?? ""
            
            
            let id = ID.isEmpty ? generateOrderNumber() : ID
            
            let newRecord = customerRecord(
                id: id,
                Name: name,
                contact: contact,
                address: adress,
                gender: gender,
                bloodgroup: bloodgroup,
                other: other
             
            )
            
            if let index = findRecordIndex(by: id) {
                    // Update existing record
                    updateSavedData(newRecord, at: index)
                } else {
                    // Save new record
                    saveCreateSaleDetail(newRecord)
                }
           
            
        }
        
        func saveCreateSaleDetail(_ order: customerRecord)
        {
            var orders = UserDefaults.standard.object(forKey: "customerRecord") as? [Data] ?? []
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(order)
                orders.append(data)
                UserDefaults.standard.set(orders, forKey: "customerRecord")
                clearTextFields()
               
            } catch {
                print("Error encoding medication: \(error.localizedDescription)")
            }
            showAlert(title: "Success", message: "Customer information has been saved successfully.")
            
        }
        
        func updateSavedData(_ updatedTranslation: customerRecord, at index: Int) {
            if var savedData = UserDefaults.standard.array(forKey: "customerRecord") as? [Data] {
                let encoder = JSONEncoder()
                do {
                    let updatedData = try encoder.encode(updatedTranslation)
                    savedData[index] = updatedData // Update the specific index
                    UserDefaults.standard.set(savedData, forKey: "customerRecord")
                } catch {
                    print("Error encoding data: \(error.localizedDescription)")
                }
            }
            showAlert(title: "Updated", message: "Customer information has Been Updated Successfully.")
        }
        
        func findRecordIndex(by id: String) -> Int? {
            if let records = UserDefaults.standard.array(forKey: "customerRecord") as? [Data] {
                let decoder = JSONDecoder()
                for (index, recordData) in records.enumerated() {
                    do {
                        let record = try decoder.decode(customerRecord.self, from: recordData)
                        if record.id == id {
                            return index
                        }
                    } catch {
                        print("Error decoding record: \(error.localizedDescription)")
                    }
                }
            }
            return nil
        }

        func clearTextFields()
        {
            nameTF.text = ""
            contactTf.text = ""
            gender.text = ""
            bloodgroup.text = ""
            other.text = ""
            addressTf.text = ""
        }
        
        @IBAction func SaveButton(_ sender: Any) {
            saveData()
        }
        
        @IBAction func backButton(_ sender: Any) {
            self.dismiss(animated: true)
        }

        
    }


