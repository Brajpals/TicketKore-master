//
//  togglCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 25/05/21.
//

import UIKit

class togglCell: UITableViewCell {

    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var toggleBtn: UISwitch!
    @IBOutlet weak var requiredView: UIView!
    @IBOutlet weak var reqImg: UIImageView!
    @IBOutlet weak var seperator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
