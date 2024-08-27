//
//  UserSettingsViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 26/11/21.
//

import UIKit
import EzPopup

protocol userSettingsDelegate: AnyObject {
    func sendSettingInfo(data : UserSettingModel)
}


class UserSettingsViewController: UIViewController,UserSettingModelDelegate,supervisorDelegate,assignmntDelegate,AddDescriptionDelegate, PopupViewControllerDelegate, NoteDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    var userSettingsModel = UserSettingViewModel()
    var userSettingArray = UserSettingModel()
    var supervisorData = Supervisor()
    var supervisorView = UserSettingOptionController()
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let enterDescription = EnterDescriptionPopupViewController.instantiate()
    
    var otherAssignmentText : String = ""
    var officeAssignmentId : String = ""
    var userOption : String = ""
    var physical_attribute : String = ""
    var supervisorId : String = ""
    var isDropOpen : Bool = true
    var flag : Int!
    var selectIndex : Int = 0
    var selectItem : Int = 0
    var  delegate : userSettingsDelegate?
    let db = SqliteDbStore()
        
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.userSettingsModel.userDelegate = self
       
        self.userSettingsModel.getUserSettings()
      
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SingleChoiceCell", bundle: nil), forCellReuseIdentifier: "SingleChoiceCell")
        tableView.register(UINib(nibName: "UserSettingCell", bundle: nil), forCellReuseIdentifier: "UserSettingCell")
        if flag == 0 || flag == 9{
            self.backBtn.isHidden = true
        }
        tableView.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func addEnteredDescription(text:String?) {
        UserDefaults.standard.set(text, forKey: "userOption")
        userSettingArray.option?.forEach({$0.subOption = ""})
        userSettingArray.option?[selectIndex].subOption = text
        userSettingArray.question?.response = text
        otherAssignmentText = text ?? ""
        self.tableView.reloadData()
    }
    
    func addnote(forSave: Bool) {
        print("hello")
    }
    
    func clearDescription() {}

    func removeView(){
        self.blurEffectView.removeFromSuperview()
    }
    
  func getUserSettingData(settingData:UserSettingModel?){
      let ethinicity = AppManager.getLastSavedLoginDetails()?.result?.Ethnicity
      let gender = AppManager.getLastSavedLoginDetails()?.result?.Gender
      if let genderArr = settingData?.gender_option {
          for obj in genderArr {
              if gender == obj.option_id {
                  UserDefaults.standard.set(obj.option_value, forKey: "gender")
              }
          }
      }
     
      var ethencityArr = NSMutableArray()
      let fullNameArr = ethinicity?.components(separatedBy: ",")
      if let ethenArr = settingData?.ethncity_option{
          for i in (0 ..< (fullNameArr?.count ?? 0)) {
              let eId = fullNameArr?[i]
              for obj in ethenArr {
                  if eId == obj.option_id {
                      let dict = NSMutableDictionary()
                       dict["option_value"] = obj.option_value ?? ""
                       dict["order_number"] = obj.order_number ?? ""
                       dict["physical_attribute"] = obj.physical_attribute ?? ""
                       dict["cascade_ripa_id"] = obj.option_id ?? ""
                       ethencityArr.add(dict)
                  }
              }
          }
      }
      
      UserDefaults.standard.set(ethencityArr, forKey: "ethencity")
     
      self.userSettingArray = settingData!
      tableView.isHidden = false
      if self.userSettingArray.supervisor?.count ?? 0 > 0,let data = self.userSettingArray.supervisor {
          userSettingArray.supervisor?[0].isSelected = true
          self.supervisorData = data[0]
          if let sId = data[0].SupervisorId {
              self.supervisorId = sId
              UserDefaults.standard.set(sId, forKey: "supervisorId")
          }
      }
      if let userOption = UserDefaults.standard.object(forKey: "physical_attribute") as? String,userOption.count > 0{
          self.physical_attribute = UserDefaults.standard.object(forKey: "physical_attribute") as? String ?? ""
           if let index = userSettingArray.option?.firstIndex(where: {$0.physical_attribute == userOption}) {
               self.userSettingArray.option?[index].is_select = true
               self.officeAssignmentId = userSettingArray.option?[index].option_id ?? ""
               print(self.officeAssignmentId)
               if userOption == "10" || userOption == "11" {
                   self.otherAssignmentText = UserDefaults.standard.object(forKey: "userOption") as? String ?? ""
               }
           }
      }
      self.userOption = UserDefaults.standard.object(forKey: "userOption") as? String ?? ""
      self.tableView.reloadData()
  }
    
    func getUserSupervisor(sData:Supervisor?,index : Int) {
      self.supervisorData = sData!
        userSettingArray.supervisor?.forEach({
            $0.isSelected = false
        })
      userSettingArray.supervisor?[index].isSelected = true
      if let sId = sData?.SupervisorId {
          self.supervisorId = sId
          UserDefaults.standard.set(sId, forKey: "supervisorId")
      }
      self.tableView.reloadData()
  }
    
 func sendAssignment(assignmentTxt : String){
     self.removeView()
     UserDefaults.standard.set(assignmentTxt, forKey: "userOption")
     userSettingArray.option?[selectIndex].subOption = assignmentTxt
     userSettingArray.question?.response = assignmentTxt
     otherAssignmentText = assignmentTxt
     self.tableView.reloadData()
 }

    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
     }
    
    @objc func dropDownBtnAction(_ sender: UIButton)  {
        let tag = Int(sender.tag)
            if tag == 0 , let supervisorArr = userSettingArray.supervisor ,supervisorArr.count > 0 && userSettingArray.is_active == "Y"{
                self.blurEffectView.frame = view.bounds
                self.blurEffectView.backgroundColor = .black
                self.blurEffectView.alpha = 0.6
                self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.view.addSubview(blurEffectView)
                
                self.tabBarController?.tabBar.isHidden = true
                self.definesPresentationContext = true
               
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserSettingOptionController") as! UserSettingOptionController
                vc.supervisorArray = supervisorArr
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                self.present(vc, animated: true)
            }
        else {
            self.isDropOpen = !isDropOpen
            self.tableView.reloadData()
        }
     }
    
    
    @IBAction func action_UpdateUserInfo(_ sender: Any) {

        let pAtt = userSettingArray.option?[self.selectItem].physical_attribute
        if officeAssignmentId.count == 0{
            self.showAlertMessage(titleStr: "", messageStr: "Please select an option first.")
        }
        else if otherAssignmentText.count == 0 && (pAtt == "11" || pAtt == "10") {
            self.openAssignmentPopup()
        }
        else {
            UserDefaults.standard.set(officeAssignmentId, forKey: "officeAssignmentId")
            self.userSettingsModel.sendRipaUpdateuser(office_assignment_id: officeAssignmentId, supervisorid: supervisorId,other_assignment_value: otherAssignmentText)
        }
     }
    
    func updateUserSettingData(msg:String){
        UserDefaults.standard.set("yes", forKey: "settingDone")
        let  createRipaResponseTable = "create table if not exists ripaResponseTable (question_id TEXT, response TEXT, internal TEXT, userid TEXT,question TEXT,CreatedBy TEXT,physical_attribute TEXT,key TEXT,personId TEXT,description TEXT,question_code TEXT,cascade_ques_id TEXT,order_number TEXT,option_id TEXT,cascade_option_id TEXT,main_question_id TEXT,supervisorId TEXT,os_version TEXT,is_trainee TEXT)"
        
        db.openDatabase()
        db.createTable(insertTableString: createRipaResponseTable)
        print(userOption)
        
        let pAtt = userSettingArray.option?[self.selectItem].physical_attribute
        
        if msg.lowercased() == "success" && flag == 0{
            UserDefaults.standard.set(physical_attribute, forKey: "physical_attribute")
            if pAtt != "11" && pAtt != "10" {
                UserDefaults.standard.set(userOption, forKey: "userOption")
            }
            let vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            db.deleteAllfrom(table: createRipaResponseTable)
            let userRipaResponse  = self.createRipaResponseData(data: self.userSettingArray)
            db.insertRipaResponse(ripaRes: userRipaResponse)
            vc2.userSettingArray = self.userSettingArray
            self.navigationController?.pushViewController(vc2, animated: true)
        }
        else if msg.lowercased() == "success" && flag == 9{
            UserDefaults.standard.set(physical_attribute, forKey: "physical_attribute")
            if pAtt != "11" && pAtt != "10" {
                UserDefaults.standard.set(userOption, forKey: "userOption")
            }
            let vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            db.deleteAllfrom(table: createRipaResponseTable)
            let userRipaResponse  = self.createRipaResponseData(data: self.userSettingArray)
            db.insertRipaResponse(ripaRes: userRipaResponse)
            vc2.userSettingArray = self.userSettingArray
            self.navigationController?.pushViewController(vc2, animated: true)
        }
        else if msg.lowercased() == "success" && flag == 1{
            UserDefaults.standard.set(physical_attribute, forKey: "physical_attribute")
            if pAtt != "11" && pAtt != "10" {
                UserDefaults.standard.set(userOption, forKey: "userOption")
            }
            db.deleteAllfrom(table: createRipaResponseTable)
            let userRipaResponse  = self.createRipaResponseData(data: self.userSettingArray)
            db.insertRipaResponse(ripaRes: userRipaResponse)
            self.delegate?.sendSettingInfo(data: self.userSettingArray)
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.showAlertMessage(titleStr: "", messageStr: msg)
        }
    }
    
    func createRipaResponseData(data:UserSettingModel) -> RipaResponse {
        let optionArray = data.option?.filter({ item in
            item.is_select == true
        })
        let idUser = (AppManager.getLastSavedLoginDetails()?.result?.userid)!
        var questionId : String = ""
        if let qId = data.question?.id {
            questionId = qId
        }
        
        var responseStr : String = ""
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String{
            responseStr = userOption
        }
        
        var inter : String = ""
        if let respo = data.question?.internall {
            inter = respo
        }
        
        var questn : String = ""
        if let respo = data.question?.question {
            questn = respo
        }
        
        var createBy : String = ""
        if let respo = data.question?.CreatedBy {
            createBy = respo
        }
        
        var attri : String = ""
        if let respo = optionArray?[0].physical_attribute {
            attri = respo
        }
        
        var keyS : String = ""
        if let respo = data.question?.question_key {
            keyS = respo
        }
        
        let personId : String = ""
//        if let respo = data.supervisor?[0].PersonId {
//            pId = respo
//        }
        
        var qCode : String = ""
        if let respo = data.question?.question_code {
            qCode = respo
        }
        
        var orderN : String = ""
        if let respo = optionArray?[0].order_number {
            orderN = respo
        }
        
        var opId : String = ""
        if let respo = optionArray?[0].option_id {
            opId = respo
        }
        
        var mainQuestionId : String = ""
        if let respo = data.question?.id {
            mainQuestionId = respo
        }
        
        var traini : String = "0"
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
            traini = "1"
        }
        
        let os = ProcessInfo().operatingSystemVersion
        let  supId : String = self.supervisorId

        let ripaRes = RipaResponse(question_id: questionId, response: responseStr, internal: inter, userid: idUser, question: questn, CreatedBy: createBy, physical_attribute: attri, key: keyS, personId: personId, description: "", question_code: qCode, cascade_ques_id: "0", order_number: orderN, option_id: opId, cascade_option_id: "0", main_question_id: mainQuestionId, supervisorId: supId, other_assignment_value: otherAssignmentText, activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version : os.getFullVersion(),is_trainee : traini, isSelected: "")
        
        return ripaRes
    }
    
    
}

extension UserSettingsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0,let is_active = self.userSettingArray.is_active, is_active == "Y"{
            return 65
        }
        else if indexPath.row == 0,let question = userSettingArray.supervisor ,question.count == 0 {
            return 0
        }
        else if indexPath.row == 0 && userSettingArray.default_supervisor != "0" {
            return 0
        }
        else if indexPath.row == 0,userSettingArray.supervisor?.count == 0 {
            return 0
        }
        else if indexPath.row == 0{
            return 0
        }
        else if indexPath.row == 1 {
            return 85
        }
        else{
            return 70
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 1
        
        if let option = userSettingArray.option, self.isDropOpen == true{
            count = count + option.count + 1
        }
        else if self.isDropOpen == false {
            return 2
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 1 {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red:111/255.0, green:212/255.0, blue:255/255.0, alpha: 1.0)
            
            userSettingArray.option = self.setArray(options: userSettingArray.option!)
            userSettingArray.option?.forEach({$0.is_select = false})
            
            if let assignId = userSettingArray.option?[indexPath.row - 2].option_id{
                self.officeAssignmentId = assignId
            }
            if let pAttribute = userSettingArray.option?[indexPath.row - 2].physical_attribute {
                self.physical_attribute = pAttribute
            }
            self.selectItem = indexPath.row - 2
            if let pAttribute = userSettingArray.option?[indexPath.row - 2].physical_attribute,pAttribute == "10" {
                self.selectIndex = indexPath.row - 2
                userSettingArray.option?[indexPath.row - 2].is_select = true
                self.openAssignmentPopup()
            }
            else if let pAttribute = userSettingArray.option?[indexPath.row - 2].physical_attribute,pAttribute == "11" {
                self.selectIndex = indexPath.row - 2
                userSettingArray.option?[indexPath.row - 2].is_select = true
                self.openAssignmentPopup()
            }
            else if let text =  userSettingArray.option?[indexPath.row - 2].option_value{
                self.userOption = text
                UserDefaults.standard.set(false, forKey: "isTraini")
                if let pAttribute = userSettingArray.option?[indexPath.row - 2].physical_attribute {
                    self.physical_attribute = pAttribute
                    if pAttribute == "9999" {
                        UserDefaults.standard.set(true, forKey: "isTraini")
                    }
                }
                UserDefaults.standard.set(text, forKey: "userOption")
                userSettingArray.option?[selectIndex].subOption = ""
                userSettingArray.option?[indexPath.row - 2].is_select = true
            }
            self.tableView.reloadData()
        }
        else if indexPath.row == 0{
            if let supervisorArr = userSettingArray.supervisor ,supervisorArr.count > 0 && userSettingArray.is_active == "Y"{
                self.blurEffectView.frame = view.bounds
                self.blurEffectView.backgroundColor = .black
                self.blurEffectView.alpha = 0.6
                self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.view.addSubview(blurEffectView)
                
                self.tabBarController?.tabBar.isHidden = true
                self.definesPresentationContext = true
               
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserSettingOptionController") as! UserSettingOptionController
                vc.supervisorArray = supervisorArr
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                self.present(vc, animated: true)
            }
            else {
                
            }
        }
        else if indexPath.row == 1 {
            self.isDropOpen = !isDropOpen
            self.tableView.reloadData()
        }
    }
    
    func setArray(options:[Option]) -> [Option] {
        for i in 0..<options.count {
            options[i].is_select =  false
        }
        return options
    }
    
    func openAssignmentPopup(){
        guard let customAlertVC = enterDescription else { return }
        customAlertVC.addDescriptionDelegate = self
        //customAlertVC.popupLbl.text = "Enter Assignment Description"
        customAlertVC.noteDelegate = self
        customAlertVC.flag = 1
        customAlertVC.placeholder = "Assignment type" 
        customAlertVC.inputType = "Enter Assignment"
        
        let popupVC = PopupViewController(contentController: customAlertVC, position: .bottom(UIScreen.main.bounds.size.height/2.8), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: 370)
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row > 1 {
        let cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath )!
            cellToDeSelect.contentView.backgroundColor = .white
       
        }
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleChoiceCell", for: indexPath as IndexPath) as! SingleChoiceCell
        
            cell.contentView.backgroundColor = UIColor(red:236/255.0, green:236/255.0, blue:236/255.0, alpha: 1.0)
            let check = userSettingArray.option?[indexPath.row - 2].is_select
            if let option = userSettingArray.option {
                
                if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption.count > 0 {
                    let filterA = self.userSettingArray.option?.filter({ item in
                        item.option_value == userOption
                    })
                    if filterA?.count == 0 && userSettingArray.option?[indexPath.row - 2].physical_attribute == "10" && check == true{
                        userSettingArray.option?[indexPath.row - 2].subOption = userOption
//                        userSettingArray.option?[indexPath.row - 2].is_select = true
//                        cell.contentView.backgroundColor = UIColor(red:111/255.0, green:212/255.0, blue:255/255.0, alpha: 1.0)
                    }
                     else if filterA?.count == 0 && userSettingArray.option?[indexPath.row - 2].physical_attribute == "11" && check == true{
                         userSettingArray.option?[indexPath.row - 2].subOption = userOption
                     }
                }
                cell.setUserSettingData(data: option[indexPath.row - 2])
            }
            cell.radioImage.image = UIImage(named: "Unselect")
            cell.optionTxt.font = UIFont.systemFont(ofSize: 17.0)
            if check == true {
              //  cell.contentView.backgroundColor = UIColor(red:111/255.0, green:212/255.0, blue:255/255.0, alpha: 1.0)
                cell.radioImage.image = UIImage(named: "Select")
                cell.optionTxt.font = UIFont.boldSystemFont(ofSize: 16.0)
            }
            
            cell.backgroundColor = UIColor(red:236/255.0, green:236/255.0, blue:236/255.0, alpha: 1.0)
            cell.optionView.backgroundColor = UIColor(red:236/255.0, green:236/255.0, blue:236/255.0, alpha: 1.0)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserSettingCell", for: indexPath as IndexPath) as! UserSettingCell
            if indexPath.row == 0{
                cell.setDataSupervisor(data: self.supervisorData)
            }
            
            cell.dropDownBtn.tag = indexPath.row
            cell.dropDownBtn.addTarget(self,action:#selector(dropDownBtnAction), for: UIControl.Event.touchUpInside)
            
            cell.dropDownBtn.setImage(UIImage(named: "down"), for: .normal)
            if indexPath.row == 1 , isDropOpen == true {
                cell.dropDownBtn.setImage(UIImage(named: "up"), for: .normal)
            }
            
            if indexPath.row == 1,let question = self.userSettingArray.question {
                cell.setQuestionData(data: question)
            }
            
            cell.selectionStyle = .none
            cell.setData(index: indexPath.row)
            
         //   cell.backgroundColor = UIColor(red:236/255.0, green:236/255.0, blue:236/255.0, alpha: 1.0)
            
            return cell
        }
    }

//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row > 1 {
//        let backgroundColorView = UIView()
//            backgroundColorView.backgroundColor = .white
//        UITableViewCell.appearance().selectedBackgroundView = backgroundColorView
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
}

extension Array where Element: Equatable {

    func indexes(of item: Element) -> [Int]  {
        return enumerated().compactMap { $0.element == item ? $0.offset : nil }
    }
}

extension OperatingSystemVersion {
    func getFullVersion(separator: String = ".") -> String {
        return "\(majorVersion)\(separator)\(minorVersion)\(separator)\(patchVersion)"
    }
}

extension NSMutableAttributedString {

    func setColor(color: UIColor, forText stringValue: String) {
       let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }

}

