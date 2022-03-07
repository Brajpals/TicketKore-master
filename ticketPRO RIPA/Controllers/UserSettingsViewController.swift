//
//  UserSettingsViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 26/11/21.
//

import UIKit

protocol userSettingsDelegate: AnyObject {
    func sendSettingInfo(data : UserSettingModel)
}


class UserSettingsViewController: UIViewController,UserSettingModelDelegate,supervisorDelegate,assignmntDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    var userSettingsModel = UserSettingViewModel()
    var userSettingArray = UserSettingModel()
    var supervisorData = Supervisor()
    var supervisorView = UserSettingOptionController()
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    var otherAssignmentText : String = ""
    var officeAssignmentId : String = ""
    var supervisorId : String = ""
    var flag : Int!
    var selectIndex : Int = 0
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
        if flag == 0 {
            self.backBtn.isHidden = true
        }
        
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    func removeView(){
        self.blurEffectView.removeFromSuperview()
    }
    
  func getUserSettingData(settingData:UserSettingModel?){
      self.userSettingArray = settingData!

      self.tableView.reloadData()
  }
    
  func getUserSupervisor(sData:Supervisor?){
      self.supervisorData = sData!
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
    
    @IBAction func action_UpdateUserInfo(_ sender: Any) {
//        if supervisorId.count == 0 {
//            self.showAlertMessage(titleStr: "", messageStr: "Please select your supervisor.")
//        }
//        else
        if officeAssignmentId.count == 0{
            self.showAlertMessage(titleStr: "", messageStr: "Please select an option first.")
        }
        else {
            self.userSettingsModel.sendRipaUpdateuser(office_assignment_id: officeAssignmentId, supervisorid: supervisorId,other_assignment_value: otherAssignmentText)
        }
     }
    
    func updateUserSettingData(msg:String){
       
        let  createRipaResponseTable = "create table if not exists ripaResponseTable (question_id TEXT, response TEXT, internal TEXT, userid TEXT,question TEXT,CreatedBy TEXT,physical_attribute TEXT,key TEXT,personId TEXT,description TEXT,question_code TEXT,cascade_ques_id TEXT,order_number TEXT,option_id TEXT,cascade_option_id TEXT,main_question_id TEXT,supervisorId TEXT)"
        
        db.openDatabase()
        db.createTable(insertTableString: createRipaResponseTable)
        if msg.lowercased() == "success" && flag == 0{
            let vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            db.deleteAllfrom(table: createRipaResponseTable)
            let userRipaResponse  = self.createRipaResponseData(data: self.userSettingArray)
            db.insertRipaResponse(ripaRes: userRipaResponse)
            vc2.userSettingArray = self.userSettingArray
            self.navigationController?.pushViewController(vc2, animated: true)
        }
        else if msg.lowercased() == "success" && flag == 1{
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
        
        let  supId : String = self.supervisorId

        let ripaRes = RipaResponse(question_id: questionId, response: responseStr, internal: inter, userid: idUser, question: questn, CreatedBy: createBy, physical_attribute: attri, key: keyS, personId: personId, description: "", question_code: qCode, cascade_ques_id: "0", order_number: orderN, option_id: opId, cascade_option_id: "0", main_question_id: mainQuestionId, supervisorId: supId, other_assignment_value: otherAssignmentText, activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID)
        
        return ripaRes
    }
    
    
}


extension UserSettingsViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0,let is_active = self.userSettingArray.is_active, is_active == "Y" {
            return 65
        }
        else if indexPath.row == 0,let question = userSettingArray.supervisor ,question.count == 0 {
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
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 1
        if let option = userSettingArray.option{
            count = count + option.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 1 {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red:111/255.0, green:212/255.0, blue:255/255.0, alpha: 1.0)
            
            userSettingArray.option = self.setArray(options: userSettingArray.option!)
            
            if let assignId = userSettingArray.option?[indexPath.row - 2].option_id{
                self.officeAssignmentId = assignId
            }
            
            if let pAttribute = userSettingArray.option?[indexPath.row - 2].physical_attribute,pAttribute == "10" {
                self.selectIndex = indexPath.row - 2
                userSettingArray.option?[indexPath.row - 2].is_select = true
                self.openAssignmentPopup()
            }
            else if let text =  userSettingArray.option?[indexPath.row - 2].option_value{
                UserDefaults.standard.set(text, forKey: "userOption")
                userSettingArray.option?[selectIndex].subOption = ""
                userSettingArray.option?[indexPath.row - 2].is_select = true
            }
            self.tableView.reloadData()
        }
        else if indexPath.row == 0{
            if let question = userSettingArray.supervisor ,question.count > 0{
                self.blurEffectView.frame = view.bounds
                self.blurEffectView.backgroundColor = .black
                self.blurEffectView.alpha = 0.6
                self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.view.addSubview(blurEffectView)
                
                self.tabBarController?.tabBar.isHidden = true
                self.definesPresentationContext = true
               
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserSettingOptionController") as! UserSettingOptionController
                vc.supervisorArray = question
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                self.present(vc, animated: true)
            }
            else {
                
            }
        }
    }
    
    func setArray(options:[Option]) -> [Option] {
        for i in 0..<options.count {
            options[i].is_select =  false
        }
        return options
    }
    
    func openAssignmentPopup(){
        self.blurEffectView.frame = view.bounds
        self.blurEffectView.backgroundColor = .black
        self.blurEffectView.alpha = 0.6
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        
        self.tabBarController?.tabBar.isHidden = true
        self.definesPresentationContext = true
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EnterAssignmentController") as! EnterAssignmentController
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        vc.assignmentText = otherAssignmentText
        self.present(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row > 1 {
        let cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath )!
        cellToDeSelect.contentView.backgroundColor = UIColor(red:222/255.0, green:222/255.0, blue:224/255.0, alpha: 1.0)
       
        }
    }
    
    //if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption != "Type of Assignment of Officer" {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleChoiceCell", for: indexPath as IndexPath) as! SingleChoiceCell
            cell.optionView.backgroundColor = .clear
            cell.backgroundColor = UIColor(red:222/255.0, green:222/255.0, blue:224/255.0, alpha: 1.0)
            cell.contentView.backgroundColor = UIColor(red:222/255.0, green:222/255.0, blue:224/255.0, alpha: 1.0)
            if let option = userSettingArray.option {
                
                if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String {
                    let filterA = self.userSettingArray.option?.filter({ item in
                        item.option_value == userOption
                    })
                    if filterA?.count == 0 && userSettingArray.option?[indexPath.row - 2].option_value == "Other (manually specify type of assignment)"{
                        userSettingArray.option?[indexPath.row - 2].subOption = userOption
                    }
                }
                
                cell.setUserSettingData(data: option[indexPath.row - 2])
            }
            if let check = userSettingArray.option?[indexPath.row - 2].is_select,check == true {
                cell.contentView.backgroundColor = UIColor(red:111/255.0, green:212/255.0, blue:255/255.0, alpha: 1.0)
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserSettingCell", for: indexPath as IndexPath) as! UserSettingCell
            if indexPath.row == 0{
                cell.setDataSupervisor(data: self.supervisorData)
            }
            
            if indexPath.row == 1,let question = self.userSettingArray.question {
                cell.setQuestionData(data: question)
            }
            cell.selectionStyle = .none
            cell.setData(index: indexPath.row)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > 1 {
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor(red:111/255.0, green:212/255.0, blue:255/255.0, alpha: 1.0)
        UITableViewCell.appearance().selectedBackgroundView = backgroundColorView
        }
    }
    
}

extension Array where Element: Equatable {

    func indexes(of item: Element) -> [Int]  {
        return enumerated().compactMap { $0.element == item ? $0.offset : nil }
    }
}
