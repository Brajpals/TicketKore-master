//
//  SingleChoiceCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 17/02/21.
//

import UIKit

class SingleChoiceCell: UITableViewCell {
    @IBOutlet weak var optionTxt: UILabel!
    @IBOutlet weak var optionBtn: UIButton!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var subOptionTxt: UILabel!
    @IBOutlet weak var selectOneHeightConstrait : NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUserSettingData (data : Option){
        if let opTxt = data.option_value {
            self.optionTxt.text = opTxt
            selectOneHeightConstrait.constant = CGFloat(0)
            UIView.animate(withDuration: 0, animations:{
              self.subOptionTxt.layoutIfNeeded()
            })
        }
        if let opTxt = data.subOption {
            self.subOptionTxt.text = opTxt
            selectOneHeightConstrait.constant = CGFloat(20)
            UIView.animate(withDuration: 0, animations:{
              self.subOptionTxt.layoutIfNeeded()
            })
        }
    }
    
    
}
