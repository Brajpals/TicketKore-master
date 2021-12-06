//
//  ViolationsListCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 05/08/21.
//

import UIKit

class ViolationsListCell: UITableViewCell {
    @IBOutlet weak var txtLbl: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
