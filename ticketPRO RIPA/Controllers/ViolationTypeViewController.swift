//
//  ViolationTypeViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 01/04/21.
//

import UIKit

protocol ViolationTypeDelegate:AnyObject {
    func refreshViolationLists(list:[Questionoptions1]?, listType: String)
 }

class ViolationTypeViewController: UIViewController {
    
    weak var violationTypeDelegate: ViolationTypeDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    var listArray:[Questionoptions1]?
    var listType:String?
    var selectionType:String?
    var basisName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if basisName.count > 0 {
            viewLbl.text = basisName
        }
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
  override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     if AppConstants.theme == "1"{
        overrideUserInterfaceStyle = .dark
        }
     else{
       overrideUserInterfaceStyle = .light
        AppConstants.theme = "0"
     }
 }
    
    @IBAction func actionSubmit(_ sender: Any) {
        self.violationTypeDelegate?.refreshViolationLists(list:listArray, listType: listType!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func action_back(_ sender: Any) {
      //  listArray?.forEach({$0.isSelected = false})
        self.dismiss(animated: true, completion: nil)
    }
}


extension ViolationTypeViewController: UITableViewDelegate,UITableViewDataSource{

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listArray!.count
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
    
   // cell.checkImg.isHidden = true
    let arr = listArray
    cell.checkImg.image = UIImage(named: "uncheck")
    cell.label.font = UIFont.systemFont(ofSize: 18.0)
    cell.label.text = listArray![indexPath.row].option_value
      if listArray![indexPath.row].isSelected == true{
        cell.checkImg.isHidden = false
        cell.label.font = UIFont.boldSystemFont(ofSize: 18.0)
        cell.checkImg.image = UIImage(named: "Check")
        cell.checkImg.image = #imageLiteral(resourceName: "checked-1")
    }
    
    if selectionType == "SC"{
        cell.checkImg.image = UIImage(named: "Unselect")
        if listArray![indexPath.row].isSelected == true{
            cell.checkImg.image = UIImage(named: "Select")
        }
    }
    
    
    return cell
}
    
    
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    listArray![indexPath.row].isSelected = !listArray![indexPath.row].isSelected
   // print(selectionType)
     if selectionType == "SC"{
        checkSingleSelection(indexpath:indexPath.row)
      self.violationTypeDelegate?.refreshViolationLists(list:listArray, listType: listType!)
      self.dismiss(animated: true, completion: nil)
    }
    else {
        submitBtn.isHidden = false
        tableView.reloadData()
    }
}
    
    
    func checkSingleSelection(indexpath:Int){
        var i = 0
        for options in  listArray!{
            if  i != indexpath {
                options.isSelected = false
            }
             i += 1
        }
    }

}
