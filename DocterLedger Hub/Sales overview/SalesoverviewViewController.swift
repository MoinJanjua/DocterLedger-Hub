//
//  SalesoverviewViewController.swift
//  DocterLedger Hub
//
//  Created by ucf 2 on 19/12/2024.
//

import UIKit

class SalesoverviewViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var FromDatePicker: UIDatePicker!
    @IBOutlet weak var ToDatePicker: UIDatePicker!
    
    var datasource: [ordersBooking] = []
    var selectedRceord: ordersBooking?
    var ID = String()
    var customer_record = [customerRecord]()
    
    // New filter variables
    var selectedGender: String = "" // Example filter by gender
    var selectedClothType: String = "" // Example filter by cloth type
    var filteredOrderDetails: [ordersBooking] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
        
        FromDatePicker.addTarget(self, action: #selector(fromDatePickerChanged(_:)), for: .valueChanged)
        ToDatePicker.addTarget(self, action: #selector(toDatePickerChanged(_:)), for: .valueChanged)
    }
    
    @objc func fromDatePickerChanged(_ sender: UIDatePicker) {
        filterTransactions()
    }

    @objc func toDatePickerChanged(_ sender: UIDatePicker) {
        filterTransactions()
    }

    func filterTransactions() {
        let fromDate = FromDatePicker.date
        let toDate = ToDatePicker.date
        
        // Debugging logs
        print("From Date: \(fromDate), To Date: \(toDate)")

        // Create a DateFormatter to parse the string into Date objects
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Match the format of your bookingdate string

        // Filter the orders using Date comparison
        filteredOrderDetails = datasource.filter { order in
            if let bookingDate = dateFormatter.date(from: order.bookingdate) {
                return bookingDate >= fromDate && bookingDate <= toDate
            }
            return false // If the bookingdate string is not valid, exclude the order
        }

        print("Filtered Results Count: \(filteredOrderDetails.count)")
        TableView.reloadData()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !(ID.isEmpty) {
            loadFilteredData()
        } else {
            loadAllData()
        }
        
        updateUI() // Update the UI after filtering
        getCustomerrecord() // Update customer records  
    }
    
    func loadFilteredData() {
        if let savedData = UserDefaults.standard.array(forKey: "bookingRecord") as? [Data] {
            let decoder = JSONDecoder()
            datasource = savedData.compactMap { data in
                do {
                    let productsData = try decoder.decode(ordersBooking.self, from: data)
                    return productsData
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                    return nil
                }
            }
            
            
            // Filter based on reference ID and other conditions
            datasource = datasource.filter { $0.referenceId.trimmingCharacters(in: .whitespacesAndNewlines) == ID }
                .filter { $0.clothType.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
                .filter { selectedGender.isEmpty || $0.gender == selectedGender } // Filter by gender
                .filter { selectedClothType.isEmpty || $0.clothType == selectedClothType } // Filter by cloth type
            
            // Filter based on date range
            let startDate = FromDatePicker.date
            let endDate = ToDatePicker.date
            
            // Inside loadFilteredData()
            datasource = datasource.filter { order in
                if let bookingDate = order.bookingdate.toDate() {
                    return bookingDate >= startDate && bookingDate <= endDate
                }
                return false
            }

            
        }
        
        
        // Update the UI with the filtered data
        updateUI()
    }

    func loadAllData() {
        if let savedData = UserDefaults.standard.array(forKey: "bookingRecord") as? [Data] {
            let decoder = JSONDecoder()
            datasource = savedData.compactMap { data in
                do {
                    let productsData = try decoder.decode(ordersBooking.self, from: data)
                    return productsData
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                    return nil
                }
            }
            // Filter only by cloth type (non-empty)
            datasource = datasource.filter { $0.clothType.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
        }
        
      
    }
    
    func getCustomerrecord() {
        if let savedData = UserDefaults.standard.array(forKey: "customerRecord") as? [Data] {
            let decoder = JSONDecoder()
            customer_record = savedData.compactMap { data in
                do {
                    let productsData = try decoder.decode(customerRecord.self, from: data)
                    return productsData
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                    return nil
                }
            }
        }

        // Update datasource with customer information (gender, contact, etc.)
        for cust_rec in customer_record {
            let matchingRecords = datasource.enumerated().filter { $0.element.referenceId == cust_rec.id }
            for (index, _) in matchingRecords {
                datasource[index].gender = cust_rec.gender
                datasource[index].contact = cust_rec.contact
            }
        }
        TableView.reloadData()
        updateUI()
    }
    
    func updateUI() {
        noDataLabel.text = "No records Found"
        if datasource.isEmpty {
            TableView.isHidden = true
            noDataLabel.isHidden = false
        } else {
            TableView.isHidden = false
            noDataLabel.isHidden = true
        }
        TableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOrderDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SalesoverviewTableViewCell
        let rec = filteredOrderDetails[indexPath.item]
        cell.namelb.text = rec.Name
        cell.bloodgroup.text = rec.clothType
        cell.genderlb.text = "Gender : \(rec.gender)"
        cell.currentdate.text = "Today Date : \(rec.bookingdate)"
        cell.appointdate.text = "Next appointment Date: \(rec.deliveryDate)"
        cell.amounlb.text = "Amount Paid : \(rec.amount)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    

    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}



