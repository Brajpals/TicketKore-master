//
//  ViolationTextCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 01/04/21.
//

import UIKit

class ViolationTextCell: UITableViewCell {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewText: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var bottomViewText: UILabel!
    
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
