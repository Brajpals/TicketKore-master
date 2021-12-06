//
//  CLCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 03/03/21.
//

import UIKit

class CLCell: UITableViewCell {
    @IBOutlet weak var label: UITextField!
    @IBOutlet weak var citybtn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomLbl: UILabel!
    @IBOutlet weak var swapBtn: UIButton!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
