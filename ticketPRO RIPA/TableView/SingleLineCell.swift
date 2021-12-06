//
//  SingleLineCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 26/02/21.
//

import UIKit

class SingleLineCell: UITableViewCell {

    @IBOutlet weak var TxtField: UITextField!
    @IBOutlet weak var cellView: UIView!
     @IBOutlet weak var clearTxtBtn: UIButton!
    
    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var imgView: UIView!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     }
    
}
