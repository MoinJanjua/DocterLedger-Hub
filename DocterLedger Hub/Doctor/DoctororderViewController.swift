//
//  DoctororderViewController.swift
//  DocterLedger Hub
//
//  Created by ucf 2 on 19/12/2024.
//

import UIKit

class DoctororderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var datasource: [ordersBooking] = []
    var selectedRceord: ordersBooking?
    var ID = String()
    var customer_record = [customerRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        if !(ID.isEmpty)
        {
            if let savedData = UserDefaults.standard.array(forKey: "bookingRecord") as? [Data]
            {
                let decoder = JSONDecoder()
                datasource = savedData.compactMap { data in
                    do {
                        let productsData = try decoder.decode(ordersBooking.self, from: data)
                        print("productsData",productsData)
                        return productsData
                    } catch {
                        print("Error decoding product: \(error.localizedDescription)")
                        return nil
                    }
                }.filter({ $0.referenceId.trimmingCharacters(in: .whitespacesAndNewlines) == ID}).filter({ $0.clothType.trimmingCharacters(in: .whitespacesAndNewlines) != ""})
             }
            
            noDataLabel.text = "No records Found"// Set the message
            // Show or hide the table view and label based on data availability
                   if datasource.isEmpty {
                       TableView.isHidden = true
                       noDataLabel.isHidden = false  // Show the label when there's no data
                   } else {
                       TableView.isHidden = false
                       noDataLabel.isHidden = true   // Hide the label when data is available
                   }
            print(datasource)  // Check if data is loaded
            getCustomerrecord()
           
            return
        }

        if let savedData = UserDefaults.standard.array(forKey: "bookingRecord") as? [Data] {
            let decoder = JSONDecoder()
            datasource = savedData.compactMap { data in
                do {
                    let productsData = try decoder.decode(ordersBooking.self, from: data)
                    print("productsData",productsData)
                    return productsData
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                    return nil
                }
            }.filter({ $0.clothType.trimmingCharacters(in: .whitespacesAndNewlines) != ""})
        }
        noDataLabel.text = "No Bookings Found"// Set the message
        // Show or hide the table view and label based on data availability
               if datasource.isEmpty {
                   TableView.isHidden = true
                   noDataLabel.isHidden = false  // Show the label when there's no data
               } else {
                   TableView.isHidden = false
                   noDataLabel.isHidden = true   // Hide the label when data is available
               }
        getCustomerrecord()  // Check if data is loaded
       
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

        print("Customer Record:", customer_record)
        
        for cust_rec in customer_record {
                // Find all matching records in datasource for this customer
                let matchingRecords = datasource.enumerated().filter { $0.element.referenceId == cust_rec.id }
                
                for (index, _) in matchingRecords {
                    // Update the properties for each matching record
                    datasource[index].gender = cust_rec.gender
                    datasource[index].contact = cust_rec.contact
                }
            }
        TableView.reloadData()
    }

    
    func updateUI()
    {
       noDataLabel.text = "No Bookings Found"
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
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DoctororderTableViewCell
        
        let rec = datasource[indexPath.item]
        cell.namelb.text = rec.Name
        cell.bloodgroup.text = rec.clothType
        cell.genderlb.text = "Gender : \(rec.gender)"
        cell.currentdate.text =  "Today Date : \(rec.bookingdate)"
        cell.amountlb.text = "Amount Paid : \(rec.amount)"
        cell.appointdate.text = "Next appointement Date:\(rec.deliveryDate)"
        
        cell.updateButtonAction = { [weak self] in
        guard let self = self else { return }
        self.navigateToUpdate(record: rec)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 196
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              // Remove record from datasource
              datasource.remove(at: indexPath.row)

              // Update UserDefaults
              let encoder = JSONEncoder()
              let updatedData = datasource.compactMap { try? encoder.encode($0) }
              UserDefaults.standard.set(updatedData, forKey: "bookingRecord")

              // Delete row from table view
              tableView.deleteRows(at: [indexPath], with: .fade)

              // Update UI
              updateUI()
          }
      }
    
    func navigateToUpdate(record: ordersBooking)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "DoctorSaleViewController") as! DoctorSaleViewController
        newViewController.selectedRecordID = record.id
        newViewController.selectedRecord = record
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

//    @IBAction func removeAllButton(_ sender: Any) {
//        UserDefaults.standard.removeObject(forKey: "bookingRecord")
//        datasource.removeAll()
//        TableView.reloadData()
//        noDataLabel.text = "No Customers Found"// Set the message
//        // Show or hide the table view and label based on data availability
//       if datasource.isEmpty {
//           TableView.isHidden = true
//           noDataLabel.isHidden = false  // Show the label when there's no data
//       } else {
//           TableView.isHidden = false
//           noDataLabel.isHidden = true   // Hide the label when data is available
//       }
//    }

}
