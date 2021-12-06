//
//  SavedListTableViewCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 27/05/21.
//

import UIKit

class SavedListTableViewCell: UITableViewCell {
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var leftstyleview: UIView!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var callTypeTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
