import UIKit

class PatientRecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!

    var datasource: [customerRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let savedData = UserDefaults.standard.array(forKey: "customerRecord") as? [Data] {
            let decoder = JSONDecoder()
            datasource = savedData.compactMap { data in
                do {
                    let productsData = try decoder.decode(customerRecord.self, from: data)
                    return productsData
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        noDataLabel.text = "No Patient Found"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PatientrecordTableViewCell

        let record = datasource[indexPath.item]
        cell.namelb.text = record.Name
        cell.bloodgroup.text = record.bloodgroup
        cell.contactlb.text = "Contact :\(record.contact)"
        cell.genderlb.text = "Gender : \(record.gender)"
        cell.addreslb.text = "Address :\(record.address)"
        cell.orderButtonAction = { [weak self] in
            guard let self = self else { return }
            self.navigateToOrder(record: record)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 164
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecord = datasource[indexPath.row]
        navigateToUpdate(record: selectedRecord)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            self.datasource.remove(at: indexPath.row)
            
            let encoder = JSONEncoder()
            if let updatedData = try? self.datasource.map({ try encoder.encode($0) }) {
                UserDefaults.standard.set(updatedData, forKey: "customerRecord")
            }
            
            if self.datasource.isEmpty {
                tableView.isHidden = true
                self.noDataLabel.isHidden = false
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func navigateToUpdate(record: customerRecord) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PatientEntryViewController") as! PatientEntryViewController
        newViewController.ID = record.id
        newViewController.selectedRceord = record
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    func navigateToOrder(record: customerRecord)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "DoctororderViewController") as!  DoctororderViewController
        newViewController.ID = record.id
       // newViewController.selectedRecord = record
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func removeAllButton(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "customerRecord")
        UserDefaults.standard.removeObject(forKey: "bookingRecord")
        datasource.removeAll()
        TableView.reloadData()
        noDataLabel.text = "No records Found"
        if datasource.isEmpty {
            TableView.isHidden = true
            noDataLabel.isHidden = false
        } else {
            TableView.isHidden = false
            noDataLabel.isHidden = true
        }
    }
}
