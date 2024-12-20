import UIKit
import UserNotifications

class DoctorSaleViewController: UIViewController {
    @IBOutlet weak var nameTF: DropDown!
    @IBOutlet weak var currentdate: UIDatePicker!
    @IBOutlet weak var diseasename: UITextField!
    @IBOutlet weak var labtest: UITextField!
    @IBOutlet weak var bloodgroup: UITextField!
    @IBOutlet weak var appointdate: UIDatePicker!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var discountTF: UITextField!
    @IBOutlet weak var comments: UITextField!
    @IBOutlet weak var switchbtn: UISwitch!
    
    var customerRecords: [customerRecord] = [] // To store fetched records
    var bookingRecords: [ordersBooking] = [] // To store fetched records
    var selectedRecord: ordersBooking?
    var selectedRecordID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRecords()
        setupNameDropdown()
        
        let notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        switchbtn.isOn = notificationsEnabled
        
        if let selectedRecord = selectedRecord {
            populateFields(with: selectedRecord)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func fetchRecords() {
        if let savedData = UserDefaults.standard.array(forKey: "customerRecord") as? [Data] {
            let decoder = JSONDecoder()
            customerRecords = savedData.compactMap { data in
                do {
                    return try decoder.decode(customerRecord.self, from: data)
                } catch {
                    print("Error decoding record: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }
    
    func setupNameDropdown() {
        nameTF.optionArray = customerRecords.map { $0.Name }
        nameTF.didSelect { [weak self] selectedName, index, _ in
            guard let self = self else { return }
            let selectedRecord = self.customerRecords[index]
            self.selectedRecordID = selectedRecord.id
            self.nameTF.text = selectedName
            self.updateFields(with: selectedRecord)
        }
    }
    
    func updateFields(with record: customerRecord) {
        bloodgroup.text = record.bloodgroup
        comments.text = record.other
    }
    
    func populateFields(with record: ordersBooking) {
        nameTF.text = record.Name
        diseasename.text = record.clothType
        labtest.text = record.measurement
        bloodgroup.text = record.gender
        amountTF.text = "\(record.amount)"
        discountTF.text = "\(record.discount)"
        comments.text = record.referenceId
        
        if let bookingDate = record.bookingdate.toDate() {
            currentdate.date = bookingDate
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        // Retrieve and calculate the adjusted doctor fee
        let doctorFee = Int(amountTF.text ?? "0") ?? 0
        let discount = Int(discountTF.text ?? "0") ?? 0
        let adjustedDoctorFee = doctorFee - discount
        
        // Ensure adjusted fee is non-negative
        if adjustedDoctorFee < 0 {
            showAlert(title: "Error", message: "Discount cannot be greater than the doctor fee.")
            return
        }
        var id = ""
        if (selectedRecordID == "" || selectedRecordID == nil)
        {
            id =  generateOrderNumber()
        }
        else
        {
            id = selectedRecordID ?? ""
        }
        
//        let id = (((selectedRecordID?.isEmpty) != nil) ? generateOrderNumber() : selectedRecordID) ?? ""
        // Create a new record with the adjusted doctor fee
        let newRecord = ordersBooking(
            id: id,
            Name: nameTF.text ?? "",
            bookingdate: currentdate.date.toString(),
            deliveryDate: appointdate.date.toString(),
            clothType: diseasename.text ?? "",
            measurement: labtest.text ?? "",
            referenceId: selectedRecordID ?? UUID().uuidString,
            gender: bloodgroup.text ?? "",
            contact: "",
            stitchtype: "",
            amount: adjustedDoctorFee, // Save the adjusted amount
            discount: discount,
            advance: 0,
            orderComplete: comments.text ?? ""
        )
        
        // Debugging - Print the new record
        print("New Record:", newRecord)
        
        // Save or update the record
        saveOrUpdateRecord(newRecord)
        
        // Clear input fields
        clearFields()
        
        // Show success alert
        showAlert(title: "Success", message: "Record saved successfully with adjusted doctor fee.")
    }


    func saveOrUpdateRecord(_ record: ordersBooking) {
        var orders = UserDefaults.standard.object(forKey: "bookingRecord") as? [Data] ?? []
        let encoder = JSONEncoder()
        
        if let recordIndex = orders.firstIndex(where: {
            let decoder = JSONDecoder()
            guard let existingRecord = try? decoder.decode(ordersBooking.self, from: $0) else { return false }
            return existingRecord.id == record.id
        }) {
            do {
                let data = try encoder.encode(record)
                orders[recordIndex] = data
            } catch {
                print("Error encoding updated record: \(error.localizedDescription)")
            }
        } else {
            do {
                let data = try encoder.encode(record)
                orders.append(data)
            } catch {
                print("Error encoding new record: \(error.localizedDescription)")
            }
        }
        
        UserDefaults.standard.set(orders, forKey: "bookingRecord")
    }
    
    func clearFields() {
        nameTF.text = ""
        diseasename.text = ""
        labtest.text = ""
        bloodgroup.text = ""
        amountTF.text = ""
        discountTF.text = ""
        comments.text = ""
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "notificationsEnabled")
        if !sender.isOn {
            cancelAllNotifications()
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications have been canceled.")
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    
}


extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

