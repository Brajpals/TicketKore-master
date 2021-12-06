//
//  AllQuestionViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 5/5/21.
//

import UIKit

protocol ViolationPopupDelegate: class {
    func selectedOptionFromViolationPopup(optionArray:[Questionoptions1])
    func selectedOptionFromConsentPopup(consentQuestion: QuestionResult1 )
}


class ViolationPopup: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    static func instantiateOption() -> ViolationPopup? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(ViolationPopup.self)") as? ViolationPopup
    }
    
    
    weak var violationPopupDelegate : ViolationPopupDelegate?
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var doneView: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var questionLbl: UILabel!
    
    
    var selectionType:String?
    var question:String?
    var violationArray : [ViolationsResult]?
    // var optionsArray : [Questionoptions1]?
    var concentQuestion : QuestionResult1?
    var consentArray = [Questionoptions1]()
    var cascadeQuestionArray = [QuestionResult1]()
    var newRipaViewModel = NewRipaViewModel()
    var popupFor:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // makeToggleList()
        
        
        
        //  NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "optionViolNotif"), object: nil)
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
        
        if popupFor == "Consent"{
            questionLbl.text = "Select search related consent"
            makeToggleList()
        }
        else{
            questionLbl.text = "Select Violation"
        }
        
        doneView.isHidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        tableView.register(UINib(nibName: "togglCell", bundle: nil), forCellReuseIdentifier: "togglCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "optionViolNotif"), object: nil)
        
    }
    
    var personArray = [Questionoptions1]()
    var propertyArray = [Questionoptions1]()
    
    func makeToggleList(){
        consentArray.removeAll()
        personArray.removeAll()
        propertyArray.removeAll()
        
 
        for consentOption in concentQuestion!.questionoptions!{
           
                if consentOption.physical_attribute == "17" || consentOption.physical_attribute == "18"{
                    if consentOption.physical_attribute == "18"{
                        personArray.insert(consentOption, at: 0)
                     }
                    else{
                    personArray.append(consentOption)
                    }
                }
                
                if consentOption.physical_attribute == "19" || consentOption.physical_attribute == "20"{
                    
                    if consentOption.physical_attribute == "20"{
                        propertyArray.insert(consentOption, at: 0)
                     }
                    else{
                        propertyArray.append(consentOption)
                    }
                }
         }
        
        let personConsentObj = newRipaViewModel.createObj(mainQuestId: concentQuestion!.id, ripaID: "", optionValue: "Consent Given?", physical_attribute: "100", description: "", isSelected: false, mainQuestOrder: "")
        
        let propertyConsentObj = newRipaViewModel.createObj(mainQuestId: concentQuestion!.id, ripaID: "", optionValue: "Consent Given?", physical_attribute: "100", description: "", isSelected: false, mainQuestOrder: "")
        
        
        consentArray.append(contentsOf: personArray)
        consentArray.append(contentsOf: propertyArray)
        
        consentArray.insert(personConsentObj, at: 2)
        consentArray.insert(propertyConsentObj, at: 5)
 
        var ewrw = consentArray
        
        tableView.reloadData()
        
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if popupFor == "Consent"{
            return 6
        }
        return violationArray!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if popupFor == "Consent"{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "togglCell", for: indexPath as IndexPath) as! togglCell
            print(indexPath.row)
            cell.seperator.isHidden = true
            cell.requiredView.isHidden = true
            cell.textLbl.text =  consentArray[indexPath.row].option_value
            
            cell.toggleBtn.removeTarget(nil, action: nil, for: .allEvents)
       
            cell.toggleBtn.isUserInteractionEnabled = true
            cell.textLbl.textColor = UIColor(named: "BlackWhite")
            let cascadeId = consentArray[indexPath.row].cascade_ripa_id
            
            if  indexPath.row == 2 {
                cell.seperator.isHidden = false
            }
            
            
            if  indexPath.row == 2 || indexPath.row == 5{
                cell.toggleBtn.addTarget(self, action: #selector(self.checkCnsent(_:)), for: .valueChanged)
                cell.toggleBtn.tag = indexPath.row
                cell.toggleBtn.isOn = checkConsent(quest:consentArray[indexPath.row-1], index:indexPath.row-1)
                return cell
            }
            else if cascadeId != "" {
                cell.toggleBtn.addTarget(self, action: #selector(self.switchChangedAsked(_:)), for: .valueChanged)
                cell.toggleBtn.tag = indexPath.row
                
              if consentArray[indexPath.row].isSelected == true{
                    cell.toggleBtn.isOn = true
                }
                else{
                    cell.toggleBtn.isOn = false
                }
                return cell
            }
            
            else{
                cell.toggleBtn.addTarget(self, action: #selector(self.switchChangedConducted(_:)), for: .valueChanged)
                cell.toggleBtn.tag = indexPath.row
                
                if consentArray[indexPath.row].isSelected == true{
                     cell.toggleBtn.isOn = true
                }
                else{
                    cell.toggleBtn.isOn = false
                }
                return cell
            }
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath as IndexPath) as! ListCell
            print(indexPath.row)
            cell.checkImg.image =  UIImage(named: "checkboxEmpty")
            cell.label.text = violationArray![indexPath.row].violationDisplay
            
            if violationArray![indexPath.row].isSelected{
                cell.checkImg.image =  UIImage(named: "checked-1")
            }
            
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if popupFor == "Consent"{
            
        }
        else{
            violationArray![indexPath.row].isSelected = !violationArray![indexPath.row].isSelected
            self.tableView.reloadData()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
    
    
    @IBAction func actionDone(_ sender: Any) {
        if popupFor == "Consent"{
            self.violationPopupDelegate?.selectedOptionFromConsentPopup(consentQuestion:concentQuestion!)
        }
        else{
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func createViolationList(){
        var optionsArray = [Questionoptions1]()
        for options in violationArray!{
            if options.isSelected{
                let option = newRipaViewModel.createObj(mainQuestId: "", ripaID: "", optionValue: options.violationDisplay, physical_attribute:"", description: options.code, isSelected: true, mainQuestOrder: "")
                optionsArray.append(option)
            }
        }
        
        self.violationPopupDelegate?.selectedOptionFromViolationPopup(optionArray:optionsArray )
    }
    
    
    
    @objc func refresh() {
        self.tableView.reloadData() // a refresh the tableView.
    }
    
    
    @objc func checkCnsent(_ sender : UISwitch!){
        consentArray[sender.tag-1].isSelected = true
       consentArray[sender.tag-1].isExpanded = true
         print(sender.tag-1)
        var qww = consentArray
        if sender.isOn{
             consentArray[sender.tag-1].questionoptions![0].isSelected = true
            consentArray[sender.tag-1].questionoptions![1].isSelected = false
          }
        else{
            consentArray[sender.tag-1].questionoptions![0].isSelected = false
            consentArray[sender.tag-1].questionoptions![1].isSelected = true
         }
        tableView.reloadData()
    }
    
    
    
    
    @objc func switchChangedAsked(_ sender : UISwitch!){
        // var ae =  consentArray[sender.tag]
        let cascadeOpt = consentArray[sender.tag].questionoptions!
        if sender.isOn{
             consentArray[sender.tag].isSelected = true
            consentArray[sender.tag].isExpanded = true
            cascadeOpt[0].isSelected = false
            cascadeOpt[1].isSelected = true
         }
        else{
            consentArray[sender.tag].isSelected = false
           consentArray[sender.tag].isExpanded = false
           cascadeOpt[0].isSelected = false
           cascadeOpt[1].isSelected = false
        }
        tableView.reloadData()
    }
    
    
    
    
    @objc func switchChangedConducted(_ sender : UISwitch!){
        if sender.isOn{
            consentArray[sender.tag].isSelected = true
        }
        else{
            consentArray[sender.tag].isSelected = false
            consentArray[sender.tag+1].isSelected = false
            consentArray[sender.tag+1].questionoptions![0].isSelected = false
            consentArray[sender.tag+1].questionoptions![1].isSelected = false
         }
        tableView.reloadData()
    }
    
    
 
    
    
    func checkConsent(quest:Questionoptions1, index:Int)->Bool{
        var consent = false
        setOrder(quest:quest)
        if quest.questionoptions![0].isSelected == true{
            //quest.questionoptions![1].isSelected = false
            consent = true
        }
        else if quest.questionoptions![1].isSelected == true{
          //  quest.questionoptions![0].isSelected = false
            consent = false
        }
        
        return consent
    }
    
    
    func setOrder(quest:Questionoptions1){
        for option in quest.questionoptions!{
            option.mainQuestOrder = concentQuestion!.order_number
            option.mainQuestId = concentQuestion!.id
            option.main_question_id = concentQuestion!.id
        }
    }
    
   
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if popupFor == "Consent"{
            self.violationPopupDelegate?.selectedOptionFromConsentPopup(consentQuestion:concentQuestion!)
        }
        if popupFor == "Violation"{
            createViolationList()
        }
    }
    
}
