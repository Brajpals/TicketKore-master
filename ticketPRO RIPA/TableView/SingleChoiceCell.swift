//
//  SingleChoiceCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 17/02/21.
//

import UIKit

class SingleChoiceCell: UITableViewCell {
    @IBOutlet weak var optionTxt: UILabel!
    @IBOutlet weak var optionBtn: UIButton!
    @IBOutlet weak var optionView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
