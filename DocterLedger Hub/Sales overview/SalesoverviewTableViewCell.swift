//
//  SalesoverviewTableViewCell.swift
//  DocterLedger Hub
//
//  Created by ucf 2 on 19/12/2024.
//

import UIKit

class SalesoverviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var namelb: UILabel!
    @IBOutlet weak var genderlb: UILabel!
    @IBOutlet weak var bgview: UIView!
    @IBOutlet weak var bloodgroup: UILabel!
    @IBOutlet weak var amounlb: UILabel!
    @IBOutlet weak var currentdate: UILabel!
    @IBOutlet weak var appointdate: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgview.layer.cornerRadius = 18
        bgview.layer.shadowColor = UIColor.white.cgColor
        bgview.layer.shadowOffset = CGSize(width: 0, height: 2)
        bgview.layer.shadowOpacity = 0.3
        bgview.layer.shadowRadius = 4.0
        bgview.layer.masksToBounds = false
        bgview.alpha = 1.5 // Adjust opacity as needed
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


