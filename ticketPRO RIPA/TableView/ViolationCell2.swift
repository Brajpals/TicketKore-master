//
//  ViolationTableViewCell2.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 05/08/21.
//

import UIKit

protocol violDelegate: class {
    func reload(section:Int,index:Int)
 }


class ViolationCell2: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownBtn: UIButton!
    @IBOutlet weak var dropdownLbl: UILabel!
    @IBOutlet weak var dropdownBackgroundView: UIView!

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var textView: UIView!
    
    @IBOutlet weak var requiredView: UIView!
    @IBOutlet weak var requiredImg: UIImageView!
    @IBOutlet weak var violTable: UITableView!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var ClearBtn: UIButton!
    
    
    var violationsArr = [Questionoptions1]()
    var section:Int?
    weak var delegate: violDelegate?
    var violDict:[String:Any]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        violTable.delegate = self
        violTable.dataSource = self
        violTable.isScrollEnabled = false
        violTable.register(UINib(nibName: "ViolationsListCell", bundle: nil), forCellReuseIdentifier: "ViolationsListCell")
 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return violationsArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViolationsListCell", for: indexPath as IndexPath) as! ViolationsListCell
        let index = indexPath.row as Int
        
        cell.txtLbl.text = violationsArr[index].option_value
        cell.removeBtn.tag = index
        cell.removeBtn.addTarget(self, action: #selector(removeViol(sender:)), for: .touchUpInside)
        cell.layoutIfNeeded()
 
        return cell
    }
    
    
 
    
    
    @objc func removeViol(sender: UIButton){
        print(violationsArr.count)
        print(section!)
         print(violationsArr.count)
        delegate?.reload(section: section!, index: sender.tag)
     }
    
    
    private func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
   
    
}
