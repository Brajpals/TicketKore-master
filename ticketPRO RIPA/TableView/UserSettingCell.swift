//
//  UserSettingCell.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 26/11/21.
//

import UIKit

class UserSettingCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var SelectLbl: UILabel!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var selectOneHeightConstrait : NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataSupervisor(data : Supervisor) {
        self.titleLbl.text = "Select your supervisor"
        if let lName = data.LastName, let fName = data.FirstName {
            self.categoryLbl.text = lName + " " + fName
        }
    }
    
    func setQuestionData(data : Question){
        self.titleLbl.text = "Type of assignment of Officer"
        if let question =  data.question, question != "Type of Assignment of Officer"{
            self.categoryLbl.text = question
        }
        
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption != "Type of Assignment of Officer" {
            self.categoryLbl.text = userOption
        }
        
        if let info =  data.question_info {
            self.SelectLbl.text = info
        }
    }
    
    func setData (index : Int){
        if index == 0 {
            selectOneHeightConstrait.constant = CGFloat(0)
            UIView.animate(withDuration: 0, animations:{
              self.SelectLbl.layoutIfNeeded()
            })
        }
        if index == 1 {
            selectOneHeightConstrait.constant = CGFloat(20)
            UIView.animate(withDuration: 0, animations:{
              self.SelectLbl.layoutIfNeeded()
            })
        }
    }
    
}
