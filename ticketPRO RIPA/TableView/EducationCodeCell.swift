//
//  EducationCodeCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 16/04/21.
//

import UIKit

class EducationCodeCell: UITableViewCell {

    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
