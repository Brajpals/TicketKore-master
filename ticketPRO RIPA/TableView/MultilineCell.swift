//
//  TextAnswerCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 17/02/21.
//

import UIKit

class MultilineCell: UITableViewCell {

    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        micBtn.layer.cornerRadius = 30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
