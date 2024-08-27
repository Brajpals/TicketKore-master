//
//  PreviewViewController.swift
//  ticketPRO RIPA
//  Created by Nitin on 2/26/21.
//

import UIKit
import EzPopup
import SwiftCSVExport


protocol GoToQuestion: AnyObject {
    func goToSelectedQuestion(personIndex: Int,  personArray: [[String : Any]], index:Int ,descriptionString : String)
    func addPerson(personIndex:Int , personArray:[[String: Any]])
    func editForPerson(personIndex:Int , personArray:[[String: Any]])
    func setPreviewDelegate()
}

class PreviewViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,PersonTypeDelegate,PreviewModelDelegate,PopupViewControllerDelegate,PendingQuestionDelegate ,UIGestureRecognizerDelegate, LoginOTPViewModelDelegate {
   
    let enterDescription = EnterDescriptionPopupViewController.instantiate()
    let pendingQuestionPopup = PendingQuestionsPopup.instantiateQuestion()
    
    weak var selectedIndexDelegate : GoToQuestion?
    var questionsArray : [QuestionResult1]?
    var optionsArray : [Questionoptions1]?
    var cascadeQuestionsArray : [QuestionResult1]?
    var previewViewModel = PreviewViewModel()
    // var previewViewModel = PreviewViewModel()
    var  selectedOptionsArray=[[Questionoptions1]]()
    var questionnumber : Int?
    var  personArray: [[String: Any]] = []
//    var previewPersonArray = [RipaPerson]()
//    var previewPersonIndex = 0
    var personIndex:Int?
    var viewType:String = ""
    var saveRipaStatus:String?
    
    var addressString:String!
    var descriptionString:String!
    
     let db = SqliteDbStore()
    var ripaActivity : Ripaactivity?
    var loginModel = LoginViewModel()
    var userSettingArray = UserSettingModel()
    
    @IBOutlet weak var preview_tbl: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var notesBtn: UIButton!
    @IBOutlet weak var personLbl: UILabel!
    
    var descriptionFirst:String = ""
    var descriptionSecond:String = ""
    var isPendingEdit:Bool = false
    var isEditRequired:Bool = false
    var isCreatedSaved:Bool = false

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        trackApplicationTime()
        super.touchesEnded(touches , with: event)
    }
    
     func trackApplicationTime(){
         if AppConstants.applicationtime.count > 0{
             AppConstants.applicationtime = String(Int(AppConstants.applicationtime)! + MyGlobalTimer.sharedTimer.time)
         }
        
        MyGlobalTimer.sharedTimer.stopTimer()
        MyGlobalTimer.sharedTimer.startTimer()
     }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         if scrollView.isDragging {
            trackApplicationTime()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackApplicationTime()
        preview_tbl.dataSource = self
        preview_tbl.delegate = self
        preview_tbl.register(UINib(nibName: "PreviewCell", bundle: nil), forCellReuseIdentifier: "PreviewCell")
        preview_tbl.estimatedRowHeight = 30.0
        preview_tbl.rowHeight = UITableView.automaticDimension
        
        let personDict = personArray[personIndex!]
        
       if AppConstants.status == "Pending Review" || AppConstants.status == "Approved" || AppConstants.status == "Template" || AppConstants.status == "Edit Required"{
           // addBtn.isHidden = true
             notesBtn.isHidden = true
            questionsArray = personDict["QuestionArray"] as? [QuestionResult1]
            cascadeQuestionsArray = personDict["CascadeQuestionArray"] as? [QuestionResult1]
        }
       
        
        if #available(iOS 15.0, *) {
           self.preview_tbl.sectionHeaderTopPadding = 0.0
        }
        
      //  else{
             selectedOptionsArray = personDict["SelectedOption"] as! [[Questionoptions1]]
//            let aob = selectedOptionsArray
//            print(aob)
        // questionsArray = personDict["QuestionArray"] as? [QuestionResult1]
        //selectedOptionsArray[indexPath.section][indexPath.row].option_value
              previewViewModel.ripaActivity = ripaActivity
          //  selectedOptionsArray[0][1].option_value = AppConstants.city
            previewViewModel.viewType = viewType
            previewViewModel.questionArray = questionsArray!
            previewViewModel.cascadeQuestionArray = cascadeQuestionsArray!
        
//        let aob = cascadeQuestionsArray!
//        print(aob)
    //    }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved" || AppConstants.status == "Template"{
            if personArray.count > 1{
                addBtn.isHidden = true
                submitBtn.setTitle("REVIEW FOR ALL", for: .normal)
            }
            else{
                submitBtn.isHidden = true
                addBtn.isHidden = true
            }
        }
        else{
        if personArray.count > 1{
            submitBtn.setTitle("REVIEW FOR ALL", for: .normal)
        }
        else{
            submitBtn.setTitle("SUBMIT", for: .normal)
        }
     }
        
        print(viewType)
        print(saveRipaStatus)
        if viewType == "UseSaveRipa" && saveRipaStatus == "Saved"{
            self.submitBtn.setTitle("SUBMIT RIPA", for: .normal)
        }
        
        if isPendingEdit {
            addBtn.isHidden = false
            submitBtn.isHidden = false
            if personArray.count > 1{
                submitBtn.setTitle("REVIEW FOR ALL", for: .normal)
            }
        }
        
        if AppConstants.theme == "1"{
            overrideUserInterfaceStyle = .dark
        }
        else{
            overrideUserInterfaceStyle = .light
            AppConstants.theme = "0"
        }
  
    }
    
    
    func sendSettingInfo(data : UserSettingModel){
        self.userSettingArray = data
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//            personLbl.text = "Person" + " " + String(previewPersonIndex + 1)
//         }
//        else{
        personLbl.text = "Person" + " " + String(Int(personIndex!)+1)
   //     }
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
           return questionsArray!.count
     }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70.0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        let view = UIView()
        //  let imgView = UIImage()
        let sectionButton = UIButton()
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 70))
        
        view.frame = CGRect.init(x: 0, y: 2, width: headerView.frame.width, height: headerView.frame.height-4)
        view.backgroundColor = #colorLiteral(red: 0.3789433241, green: 0.6938186288, blue: 0.8649699092, alpha: 1)
        
        label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
        let questNumber:String = String(section+1)+". "+" "
//        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//            label.text = previewPersonArray[0].ripa_response[section].question
//        }
//        else{
        label.text = questNumber + (questionsArray?[section].question ?? "")
 //       }
        
        
        
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.font =  UIFont.boldSystemFont(ofSize:18)
        
        headerView.addSubview(view)
        headerView.addSubview(label)
        if section == 7 {
            
        }
        
        if questionsArray![section].is_required == "1" {
            let mandatoryImgView = UIImageView()
            var mandatoryImage = UIImage()
            
            mandatoryImage = UIImage(named: "asterisk")!
            
            mandatoryImgView.frame = CGRect.init(x: headerView.frame.width-40, y:(headerView.frame.height/2)-10, width: 15, height: 15)
            mandatoryImgView.image = mandatoryImage
            
            headerView.addSubview(mandatoryImgView)
        }
         
        sectionButton.tag = section
        sectionButton.addTarget(self, action: #selector(self.goToSelectedQuest(sender:)), for: .touchUpInside)
        sectionButton.frame = CGRect.init(x: 0, y: 2, width: headerView.frame.width, height: headerView.frame.height-4)
         headerView.addSubview(sectionButton)

        
         return headerView
    }
    
    
    var locationArray=[String]()
    
    func locationCellCount()-> Int{
        locationArray.removeAll()
        var i = 1
        
        if AppConstants.city != ""{
            locationArray.append(AppConstants.city)
        }
        
        if AppConstants.address != "" && addressString == ""{
            locationArray.append(AppConstants.address)
            i += 1
        }
       else  if addressString != nil{
            locationArray.append(addressString)
            i += 1
        }
        
        if AppConstants.isSchoolSelected != ""{
            locationArray.append("Is K-12 school?")
            locationArray.append(AppConstants.isSchoolSelected)
            i += 2
        }
        if AppConstants.schoolName != ""{
            locationArray.append(AppConstants.schoolName)
             i += 1
        }
        
        return i
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if AppConstants.isSchoolSelected != "" && section == 0 {
            return 8
        }
        if section == 0 {
            return 4
          //  return locationCellCount()
        }
        let count = selectedOptionsArray.count
        if section < count {
            if selectedOptionsArray[section].count>0{
                if section == 0{
                    return locationCellCount()
                }
                return selectedOptionsArray[section].count
            }
            return 1
        }
        else {
            return 1
        }
    }
    
    
    func gotoselectedQuestion(index: Int, personArray: [[String : Any]]) {
        print(index)
       
        self.selectedIndexDelegate?.goToSelectedQuestion(personIndex: personIndex!, personArray: personArray, index: index, descriptionString: "")
        navigationController?.popViewController(animated: true)
    }
    
    
    func addPerson(personIndex: Int, personArray: [[String : Any]]) {
        self.selectedIndexDelegate?.addPerson(personIndex:personIndex, personArray: personArray)
        navigationController?.popViewController(animated: true)
    }
    
    func editPerson(personIndex: Int,  personArray: [[String : Any]]) {
        self.selectedIndexDelegate?.editForPerson(personIndex:personIndex, personArray: personArray)
        navigationController?.popViewController(animated: true)
    }
    
    
    
    func previewPerson(personIndex: Int, personArray: [[String : Any]]) {
//        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//            previewPersonIndex = personIndex
//         }
//        else{
        personLbl.text = "Person" + " " + String(Int(personIndex)+1)
        self.personArray = personArray
        self.personIndex = personIndex
        let personDict = personArray[personIndex]
        selectedOptionsArray = personDict["SelectedOption"] as! [[Questionoptions1]]
//    }
        preview_tbl.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewCell", for: indexPath as IndexPath) as! PreviewTableViewCell

//        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//            print(previewPersonIndex)
//            cell.check_img.isHidden = false
//            cell.answer_lbl.text = previewPersonArray[previewPersonIndex].ripa_response[indexPath.section].response
//            return cell
//         }
//        else{
       
        cell.check_img.isHidden = true
        cell.answer_lbl.text = "_ _ _ _ _ _ _ _ _"
        cell.answer_lbl.textColor = UIColor(named: "BlackWhite")
        if indexPath.section == 0 {
            if indexPath.row == 0 && AppConstants.city != ""{
                cell.answer_lbl.text = AppConstants.city
                cell.check_img.isHidden = false
            }
            else if indexPath.row == 1{
                cell.answer_lbl.text = "Location Type"
            }
            else if indexPath.row == 2{
                if AppConstants.LocTypeIndex == 6 {
                    cell.answer_lbl.text = "Geographic Coordinates"
                }
                else  if AppConstants.LocTypeIndex == 1 {
                    cell.answer_lbl.text = "Block Number and Street Name"
                }
                else  if AppConstants.LocTypeIndex == 2 {
                    cell.answer_lbl.text = "Closest Intersection"
                }
                else  if AppConstants.LocTypeIndex == 3 {
                    cell.answer_lbl.text = "Highway and Closest Highway Exit"
                }
                else {
                    cell.answer_lbl.text = "Other"
                }
            }
            else if indexPath.row == 3{
                print(AppConstants.LocTypeIndex)
                if AppConstants.LocTypeIndex == 6,let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
                    cell.answer_lbl.text = String(format: "Latitude : %@ , Longitude %@", String(latString.prefix(6)), String(longString.prefix(6)))
                }
                else  if AppConstants.LocTypeIndex == 1 {
                    if AppConstants.block.count == 0 {
                        cell.answer_lbl.text = String(format: "%@", AppConstants.street)
                    }
                    else if AppConstants.street.count == 0 {
                        cell.answer_lbl.text = String(format: "%@", AppConstants.block)
                    }
                    else {
                        cell.answer_lbl.text = String(format: " %@ & %@",AppConstants.block , AppConstants.street)
                    }
                }
                else  if AppConstants.LocTypeIndex == 2 {
                    if AppConstants.firstIntersection.count == 0 {
                        cell.answer_lbl.text = String(format: "%@", AppConstants.secondIntersection)
                    }
                    else if AppConstants.secondIntersection.count == 0 {
                        cell.answer_lbl.text = String(format: "%@", AppConstants.firstIntersection)
                    }
                    else {
                        cell.answer_lbl.text = String(format: "%@ & %@", AppConstants.firstIntersection, AppConstants.secondIntersection)
                    }
                }
                else  if AppConstants.LocTypeIndex == 3 {
                    if AppConstants.highway.count == 0 {
                        cell.answer_lbl.text = String(format: "%@", AppConstants.closestHighway)
                    }
                    else if AppConstants.closestHighway.count == 0 {
                        cell.answer_lbl.text = String(format: "%@", AppConstants.highway)
                    }
                    else {
                        cell.answer_lbl.text = String(format: "%@ & %@", AppConstants.highway, AppConstants.closestHighway)
                    }
                }
                else {
                    cell.answer_lbl.text = AppConstants.LocTypeDescription
                }
            }
            else if indexPath.row == 4{
                cell.answer_lbl.text = "iS K-12 school?"
            }
            else if indexPath.row == 5{
                cell.answer_lbl.text = "Yes"
                cell.answer_lbl.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            }
            else if indexPath.row == 6{
                cell.answer_lbl.text = "Name Of School"
            }
            else if indexPath.row == 7,selectedOptionsArray[0].count > 3,selectedOptionsArray[0][4].questionoptions?.count ?? 0 > 0 ,let nameStr = selectedOptionsArray[0][4].questionoptions?[0].option_value,nameStr != "Yes" {
                cell.answer_lbl.text = nameStr
            }
            else if indexPath.row == 7,selectedOptionsArray[0].count > 3,selectedOptionsArray[0][4].questionoptions?.count ?? 0 > 0 ,let nameStr = selectedOptionsArray[0][4].questionoptions?[0].option_value,nameStr != "Yes" {
                cell.answer_lbl.text = nameStr
            }
            else if indexPath.row == 7{
                let obj = selectedOptionsArray[0].filter({
                    $0.ripa_id == "26" && $0.mainQuestId == "21"
                })
                if obj.count > 0 , obj[0].questionoptions?.count ?? 0 > 0 {
                    cell.answer_lbl.text = obj[0].questionoptions?[0].option_value
                }
                else if obj.count > 0 {
                    cell.answer_lbl.text = obj[0].option_value
                }
            }
            if indexPath.row == 0 && AppConstants.city == ""{
                return  cell
            }
            
            return  cell
        }
        
        if selectedOptionsArray[indexPath.section].count>0 {
           
            if selectedOptionsArray[indexPath.section][indexPath.row].tag == "Description",selectedOptionsArray[indexPath.section][indexPath.row].option_value.count > 0{
                cell.answer_lbl.text = "Reason Description - " + selectedOptionsArray[indexPath.section][indexPath.row].option_value
                descriptionFirst = selectedOptionsArray[indexPath.section][indexPath.row].option_value
                print(descriptionFirst)
                if indexPath.section == 5{
                    descriptionString = selectedOptionsArray[indexPath.section][indexPath.row].option_value
                }
            }
            else if selectedOptionsArray[indexPath.section][indexPath.row].tag == "Description"{
                cell.answer_lbl.text = "Reason Description - " + descriptionString
                descriptionSecond = descriptionString
                    // print(descriptionString)
            }
            else{
                cell.answer_lbl.text = selectedOptionsArray[indexPath.section][indexPath.row].option_value
            }
           
            if indexPath.row == 0{
                cell.check_img.isHidden = false
            }
        }
        return cell
//        }
    }
    
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        trackApplicationTime()
        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
         }
        else{
            if questionsArray![indexPath.section].is_required == "1" {
                self.selectedIndexDelegate?.goToSelectedQuestion(personIndex: personIndex!, personArray: personArray, index: indexPath.section,descriptionString : descriptionString)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //1,1
    @objc func goToSelectedQuest(sender:UIButton){
        if questionsArray![sender.tag].is_required == "1" {
            trackApplicationTime()
            self.selectedIndexDelegate?.goToSelectedQuestion(personIndex: personIndex!, personArray:  personArray, index: sender.tag, descriptionString: descriptionString)
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    func setPreviewDelegate(success: String, message: String) {
       // if message == "Success"{
            //  self.db.openDatabase()
            //                           self.db.deleteAllfrom(table: "saveRipaPersonTable")
            //                           self.db.deleteAllfrom(table: "useSaveRipaOptionsTable")
            AppConstants.notes = ""
            //            UserDefaults.standard.removeObject(forKey: "CrashedDict")
            //            UserDefaults.standard.synchronize()
            self.performSegue(withIdentifier: "ShowSuccess", sender: self)
      //  }
    }
    
    
    func goToSuccess(){
        
    }
    
    func proceedToOTP(isValidLogin: Int, message: String) {}
    
    func showPopupForCustId() {}
    
    
    @IBAction func actionSubmit(_ sender: Any) {
        AppUtility.showProgress(nil, title:nil)
        self.loginModel.OTPdelegate = self
        self.loginModel.updateVesionApp()
    }
    
    func currentVersionIsRunning() {
       
        let checkReasonStop = consensualEncounterAtSubmitting()
        if checkReasonStop == false{
           AppUtility.showAlertWithProperty("Alert", messageString: "Consensual encounter resulting in search was selected as a Reason for stop. Either Search of property was conducted or Search of Person was conducted must be selected for this question.")
           return
        }
          trackApplicationTime()
          if (AppConstants.status == "Pending Review" || AppConstants.status == "Approved") && self.submitBtn.title(for: .normal) != "SUBMIT RIPA" {
              self.performSegue(withIdentifier: "ShowPersonView", sender: self)
           }
          else{
            
           let requiredFilledData = previewViewModel.checkPreviewRequiredQuestion(questArray: questionsArray, cascadeQuestArray: cascadeQuestionsArray, selectedOpt: selectedOptionsArray)
              
          if personArray.count > 1{
              self.performSegue(withIdentifier: "ShowPersonView", sender: self)
          }
          else{
              if requiredFilledData.0.count < 1 {
                  previewViewModel.previewModelDelegate = self
                  previewViewModel.personArray = personArray
                //  previewViewModel.createPersonsDict(personArray: personArray, ripaActivity: ripaActivity!, statusId: "1")
              db.openDatabase()
              var userRipaResponse : RipaResponse = db.getRipaResponse()!
              if userRipaResponse.question_id.isEmpty {
                   userRipaResponse  = self.createRipaResponseData(data: self.userSettingArray)
              }
              var typeAssignment : String = ""
              if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String{
                  typeAssignment = "\(userOption)"
                  userRipaResponse.response = typeAssignment
              }
              if  let userOption = UserDefaults.standard.object(forKey: "supervisorId") as? String{
                  ripaActivity?.supervisorId = userOption
              }
                  
                  if viewType == "UseSaveRipa" && saveRipaStatus == "Saved"{
                      AppConstants.activityStatusId = "1"
                      ripaActivity?.activity_status_id = "1"
                  }
                  if AppConstants.isTemplate == "temp" {
                      AppConstants.activityStatusId = "1"
                      ripaActivity?.activity_status_id = "1"
                  }
                  else if isEditRequired {
                      AppConstants.activityStatusId = "4"
                      ripaActivity?.activity_status_id = "4"
                  }
                  
                  var traini : String = "0"
                  if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
                      traini = "1"
                  }
                  
                  if AppConstants.trafficId != ""{
                      print(AppConstants.trafficId)
                      ripaActivity?.traffic_id = AppConstants.trafficId
                  }

                  let os = ProcessInfo().operatingSystemVersion
                  ripaActivity?.os_version = os.getFullVersion()
                  ripaActivity?.is_trainee = traini
                  
                userRipaResponse.ripa_activity = AppConstants.activityID
                ripaActivity?.ripa_activity = AppConstants.activityID
                previewViewModel.createUserSettingPersonsDict(personArray: personArray, ripaActivity: ripaActivity!, statusId: "1", ripaResponse: userRipaResponse)
                  
                  self.saveRipaDataToCSV()
                  AppUtility.showProgress(nil, title:nil)
                  if typeAssignment.count == 0{
                      AppUtility.showAlertWithProperty("", messageString: "Type of assignment is blank.")
                  }
                  else if isEditRequired {
                      let updateRipa:UpdateRipa = previewViewModel.ripaCudActivity_postParam()
                     // print(updateRipa)
                      previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
                  }
                  else if isCreatedSaved {
                      let updateRipa:UpdateRipa = previewViewModel.updateRipaParam()
                     // print(updateRipa)
                      previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
                  }
                  else if viewType == "UseSaveRipa" && saveRipaStatus == "Saved"{
                       let updateRipa:UpdateRipa = previewViewModel.ripaCudActivity_postParam()
                      // print(updateRipa)
                       previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
                   }
                  else if saveRipaStatus == "Saved"{
                      let updateRipa:UpdateRipa = previewViewModel.updateRipaParam()
                     // print(updateRipa)
                      previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
                  }
                  else {
                      let updateRipa:UpdateRipa = previewViewModel.updateRipaParam()
                     // print(updateRipa)
                      previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
                  }
               }
              else{
                  AppUtility.hideProgress()
                  guard let customAlertVC1 = pendingQuestionPopup else { return }
                  customAlertVC1.pendingQuestionDelegate = self
                  customAlertVC1.newquestionArry = requiredFilledData.0
                  customAlertVC1.newquestionIDArray = requiredFilledData.1
                  
                  customAlertVC1.personArray = personArray
                  customAlertVC1.personIndex = personIndex
                  let popupVC = PopupViewController(contentController: customAlertVC1, position:.bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight:500)
                  popupVC.cornerRadius = 5
                  popupVC.delegate = self
                  
                  present(popupVC, animated: true, completion: nil)
              }
          }
      }
    }
    
   
    func consensualEncounterAtSubmitting()->Bool{
        var conducted = true
        for optionArr in selectedOptionsArray{
            for questions in questionsArray!{
                if questions.question_code == "16"{
                    let question = self.getQuestionUsingQuestionCode(question_code: 14)
                    for option in question.questionoptions!{
                        if option.physical_attribute == "6" && option.isSelected == true{
                            conducted = false
                            for option in optionArr{
                                if (option.physical_attribute == "18" || option.physical_attribute == "20") && option.isSelected{
                                    conducted = true
                                    return conducted
                                }
                            }
                        }
                    }
                }
            }
        }
        return conducted
    }
    
    func getQuestionUsingQuestionCode(question_code:Int)->QuestionResult1{
        var quest:QuestionResult1?
         for question in questionsArray!{
             if Int(question.question_code) == question_code{
                quest = question
            }
        }
        if quest == nil{
            quest = getCascadeQuestionUsingQuestionCode(questionCode: String(question_code))
        }
         return quest!
    }
    
    func getCascadeQuestionUsingQuestionCode(questionCode:String) -> QuestionResult1{
        var quest:QuestionResult1?
        for question in cascadeQuestionsArray!{
            if question.question_code == questionCode{
                quest = question
            }
        }
        return quest!
    }
    
    func saveRipaDataToCSV() {
        let ripa1 = ["latitude":AppConstants.lati,"longitude" :AppConstants.longi,"City":AppConstants.city,"activity_id":AppConstants.activityID,"ripa_activity":AppConstants.activityID,"Location":AppConstants.address,"description1":self.descriptionFirst,"description2":self.descriptionSecond] as [String : Any]
       print(ripa1)
        let data:NSMutableArray  = NSMutableArray()
        data.add(ripa1)
        
        let header = ["latitude", "longitude", "City", "activity_id","ripa_activity","Location","description1","description2"]
        // Create a object for write CSV
        let writeCSVObj = CSV()
        writeCSVObj.rows = data
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = header as NSArray
        writeCSVObj.name = "ripalist"
        
        // Write File using CSV class object
        let output = CSVExport.export(writeCSVObj)
     
        if output.result.isSuccess {
            guard let filePath =  output.filePath else {
                print("Export Error: \(String(describing: output.message))")
                return
            }
            
            print("File Path: \(filePath)")
          //  self.readCSVPath(filePath)
        } else {
            print("Export Error: \(String(describing: output.message))")
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
        
        var rep : String = ""
        if let respo = data.question?.response {
            rep = respo
        }
        
        var inter : String = ""
        if let respo = data.question?.internall {
            inter = respo
        }
        
        var questn : String = ""
        if let respo = data.question?.question {
            questn = respo
        }
        
        var cDate : String = ""
        if let respo = data.question?.CreatedBy {
            cDate = respo
        }
        
        var attri : String = ""
        if let respo = optionArray?[0].physical_attribute {
            attri = respo
        }
        
        var keyS : String = ""
        if let respo = data.question?.question_key {
            keyS = respo
        }
        
        var pId : String = ""
        if let respo = data.supervisor?[0].PersonId {
            pId = respo
        }
        
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
        
        var mId : String = ""
        if let respo = data.question?.id {
            mId = respo
        }
        
        var supId : String = ""
        if let arr = data.supervisor,let respo = arr[0].SupervisorId {
            supId = respo
        }
        
        var traini : String = "0"
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
            traini = "1"
        }
        
        let os = ProcessInfo().operatingSystemVersion
        
        let ripaRes = RipaResponse(question_id: questionId, response: rep, internal: inter, userid: idUser, question: questn, CreatedBy: cDate, physical_attribute: attri, key: keyS, personId: pId, description: "", question_code: qCode, cascade_ques_id: "0", order_number: orderN, option_id: opId, cascade_option_id: "0", main_question_id: mId, supervisorId: supId, other_assignment_value: "", activity_id: AppConstants.activity_id, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, isSelected: "")
        
        return ripaRes
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let segueID = segue.identifier
        
        if(segueID! == "ShowPersonView"){
            let vc = segue.destination as! PersonViewController
            vc.personTypeDelegate = self
//            if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//                vc.previewPersonArray = self.previewPersonArray
//                vc.previewPersonIndex =  self.previewPersonIndex
//             }
//            else{
            vc.userSettingArray = self.userSettingArray
            vc.viewType = viewType
            vc.isPendingEdit = isPendingEdit
            vc.prsonIndex = personIndex
            vc.questionsArray = questionsArray!
            vc.cascadeQuestionsArray = cascadeQuestionsArray
            vc.personArray = personArray
            vc.ripaActivity = ripaActivity
       
      //      }
        }
        else if(segueID! == "ShowSuccess"){
            let vc = segue.destination as! SuccessViewController
            vc.isPendingEdit = isPendingEdit
            if viewType == "UseSaveRipa" && saveRipaStatus == "Saved"{
                vc.viewType = "Saved"
            }
            else{
                vc.viewType = "New"
            }
        }
        
    }
    
    @IBAction func actionBack(_ sender: Any) {
        trackApplicationTime()
        self.selectedIndexDelegate?.editForPerson(personIndex:personIndex!, personArray: personArray)
        if AppConstants.isTemplate == "temp" {
            navigationController?.popViewController(animated: true)
        }
        else if isPendingEdit {
            for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: RejectedApplicationViewController.self) {
                        _ =  self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
        }
        else {
         navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    @IBAction func actionAdd(_ sender: Any) {
        trackApplicationTime()
        checkRequired()
    }
    
    
    
    @IBAction func actionNotes(_ sender: Any) {
        trackApplicationTime()
        guard let customAlertVC = enterDescription else { return }
        
        //customAlertVC.addDescriptionDelegate = self
        customAlertVC.enteredText = AppConstants.notes
        customAlertVC.inputType = "Notes"
        
        let popupVC = PopupViewController(contentController: customAlertVC, position: .bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: 370)
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    
    
    func checkRequired(){
        let requiredFilledData = previewViewModel.checkRequiredQuestion(questArray: questionsArray, cascadeQuestArray: cascadeQuestionsArray, selectedOpt: selectedOptionsArray)
        
        
         if requiredFilledData.0.count < 1 {
            AppConstants.isAddPerson = true
            navigationController!.removeViewController(PersonViewController.self)
            self.selectedIndexDelegate?.addPerson(personIndex:personIndex!, personArray: personArray)
            navigationController?.popViewController(animated: true)
        }
        else{
            guard let customAlertVC1 = pendingQuestionPopup else { return }
            customAlertVC1.pendingQuestionDelegate = self
            customAlertVC1.newquestionArry = requiredFilledData.0
            customAlertVC1.newquestionIDArray = requiredFilledData.1
            
            customAlertVC1.personArray = personArray
            customAlertVC1.personIndex = personIndex
            let popupVC = PopupViewController(contentController: customAlertVC1, position:.bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight:500)
            popupVC.cornerRadius = 5
            popupVC.delegate = self
            
            present(popupVC, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func actionLogout(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Are you sure want to logout?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertAction.Style.default, handler: { action in
            AppManager.logout()
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "EnrollementViewController") as! EnrollementViewController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }         )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        
    }
    
}

extension UINavigationController {
    
    func removeViewController(_ controller: UIViewController.Type) {
        if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            viewController.removeFromParent()
        }
    }
    
    
}
