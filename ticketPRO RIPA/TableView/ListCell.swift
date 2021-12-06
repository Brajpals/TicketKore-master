//
//  ListCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 30/03/21.
//

import UIKit

class ListCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
