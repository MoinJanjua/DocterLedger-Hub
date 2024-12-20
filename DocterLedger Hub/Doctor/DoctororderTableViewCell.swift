//
//  DoctororderTableViewCell.swift
//  DocterLedger Hub
//
//  Created by ucf 2 on 19/12/2024.
//

import UIKit

class DoctororderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var namelb: UILabel!
    @IBOutlet weak var bloodgroup: UILabel!
    @IBOutlet weak var genderlb: UILabel!
    @IBOutlet weak var currentdate: UILabel!
    @IBOutlet weak var appointdate: UILabel!
    @IBOutlet weak var bgview: UIView!
    @IBOutlet weak var amountlb: UILabel!
    
    var orderButtonAction: (() -> Void)?
    var updateButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func orderButtonTapped(_ sender: UIButton) {
            // Call the closure when the Update button is tapped
        orderButtonAction?()
        }
    @IBAction func updateButtonTapped(_ sender: UIButton) {
            // Call the closure when the Update button is tapped
            updateButtonAction?()
        }
}
