//
//  LocationUpdateCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 04/06/21.
//

import UIKit

class RejectedApplicationCell: UITableViewCell {

    @IBOutlet weak var personLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var micBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
