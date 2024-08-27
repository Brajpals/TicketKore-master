//
//  RadioTextCell.swift
//  ticketPRO RIPA
//
//  Created by mac on 03/10/23.
//

import UIKit

class RadioTextCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var radioImage: UIImageView!
    @IBOutlet weak var lineView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setEthncity(data : Ethncity) {
        if let titleTxt = data.option_value {
            self.titleLbl.text = titleTxt
        }
        if data.isSelected {
            self.titleLbl.font = UIFont.boldSystemFont(ofSize: 16.0)
            radioImage.image = UIImage(named: "Check")
        }
        else {
            self.titleLbl.font = UIFont.systemFont(ofSize: 17.0)
            radioImage.image = UIImage(named: "uncheck")
        }
    }
    
    func setGender(data : GenderOption) {
        if let titleTxt = data.option_value {
            self.titleLbl.text = titleTxt
        }
        if data.isSelected {
            self.titleLbl.font = UIFont.boldSystemFont(ofSize: 16.0)
            radioImage.image = UIImage(named: "Select")
        }
        else {
            self.titleLbl.font = UIFont.systemFont(ofSize: 17.0)
            radioImage.image = UIImage(named: "Unselect")
        }
    }
    
}
