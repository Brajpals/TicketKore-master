//
//  LocationCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 26/02/21.
//

import UIKit

class ViolationCell: UITableViewCell {

    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownBtn: UIButton!
    @IBOutlet weak var dropdownLbl: UILabel!
    @IBOutlet weak var dropdownBackgroundView: UIView!
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var textView: UIView!
    
    @IBOutlet weak var requiredView: UIView!
    @IBOutlet weak var requiredImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
