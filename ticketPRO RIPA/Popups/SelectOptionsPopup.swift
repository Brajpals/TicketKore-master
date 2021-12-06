//
//  AllQuestionViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 5/5/21.
//

import UIKit

protocol SelectOptionsPopupDelegate: class {
    func selectedOptionFromPopup(optionArray:[Questionoptions1])
}


class SelectOptionsPopup: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    static func instantiateOption() -> SelectOptionsPopup? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(SelectOptionsPopup.self)") as? SelectOptionsPopup
    }
    
    
    weak var selectOptionsPopupDelegate : SelectOptionsPopupDelegate?
    var optionsArray : [Questionoptions1]?
    
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var doneView: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var questionLbl: UILabel!
    
    
    var selectionType:String?
    var question:String?
    var questionFor=""
    var isK12:Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppConstants.theme == "1"{
            overrideUserInterfaceStyle = .dark
        }
        else{
            overrideUserInterfaceStyle = .light
            AppConstants.theme = "0"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        
        doneView.isHidden = false
        if selectionType == "SC"{
            doneView.isHidden = true
        }
        
        if question!.contains("Disability"){
            questionFor = "Disability"
        }
        else{
            questionFor = ""
        }
        
        questionLbl.text = question
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "optionNotif"), object: nil)
    }
    
    
    
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath as IndexPath) as! ListCell
        print(indexPath.row)
        cell.label.text = (optionsArray![indexPath.row].option_value)
        
        if selectionType == "SC"{
            cell.checkImg.isHidden = true
        }
        else{
            cell.checkImg.isHidden = false
            cell.checkImg.image =  UIImage(named: "checkboxEmpty")
        }
        cell.label.textColor = UIColor(named: "BlackWhite")
        if optionsArray![indexPath.row].isSelected{
            cell.checkImg.isHidden = false
            cell.checkImg.image =  UIImage(named: "checked-1")
        }
        
        if optionsArray![indexPath.row].isK_12School == "1"{
            cell.label.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        optionsArray![indexPath.row].isSelected = !optionsArray![indexPath.row].isSelected
        if questionFor == "Disability"{
            checkNone(index: indexPath.row)
        }
        if selectionType == "SC"{
            checkOptions(index:indexPath.row)
            self.selectOptionsPopupDelegate?.selectedOptionFromPopup(optionArray:optionsArray!)
            dismiss(animated: true, completion: nil)
        }
        else{
            self.tableView.reloadData()
        }
        
    }
    
    
    
    
    func checkNone(index:Int){
        
        //   for options in optionsArray!{
        if (optionsArray![index].option_value == "None" || optionsArray![index].option_id == "164") && optionsArray![index].isSelected{
            for opt in optionsArray!{
                if opt.option_id != optionsArray![index].option_id{
                    opt.isSelected = false
                }
            }
        }
        else{
            optionsArray!.filter { $0.option_id != "164"}.first?.isSelected = false
        }
        
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if questionFor == "Disability"{
            if isK12 == false && optionsArray![indexPath.row].isK_12School == "1"{
                return 0
            }
        }
        return 50
    }
    
    func checkOptions(index:Int){
        var i = 0
        for options in optionsArray!{
            options.isSelected = false
            if i == (index){
                options.isSelected = true
            }
            i += 1
        }
    }
    
    
    @IBAction func actionDone(_ sender: Any) {
        
        self.selectOptionsPopupDelegate?.selectedOptionFromPopup(optionArray:optionsArray!)
    }
    
    
    
    @objc func refresh() {
        self.tableView.reloadData() // a refresh the tableView.
    }
    
    
}
