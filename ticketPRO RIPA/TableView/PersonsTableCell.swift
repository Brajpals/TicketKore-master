//
//  PersonsTableCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 06/04/21.
//

import UIKit

class PersonsTableCell: UITableViewCell {

    @IBOutlet weak var personNumberLbl: UILabel!
    @IBOutlet weak var personTypeLbl: UILabel!
    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
