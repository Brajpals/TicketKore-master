//
//  PerceivedGenderCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 25/05/21.
//

import UIKit

class PerceivedGenderCell: UITableViewCell {

    @IBOutlet weak var optionTxt: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var requiredIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
