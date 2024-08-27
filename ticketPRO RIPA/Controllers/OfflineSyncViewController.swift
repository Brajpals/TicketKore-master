//
//  OfflineSyncViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 6/15/21.
//

import UIKit
import SwiftyJSON

protocol offlineDelegate : AnyObject {
    func syncOfflineDataCompleted()
}

class OfflineSyncViewController: PreviewModelDelegate,userSettingsDelegate, UserSettingModelDelegate {
    
    func updateUserSettingData(msg: String) {
        
    }
    
    func setPreviewDelegate(success: String, message: String) {
        print("new")
    }
    
    let defaults = UserDefaults.standard
    var viewType=""
    var savedRipaList = [RipaTempMaster]()
    var  personArray: [[String: Any]] = []
    var  ViewModel = DashboardViewModel()
    var previewModel = PreviewViewModel()
    var ripaActivity: Ripaactivity?
    var ripaPersonsArray = [RipaPerson]()
    var ripaActivityArray = [Ripaactivity]()
    var userSettingArray = UserSettingModel()
    var userSettingsModel = UserSettingViewModel()
    weak var delegate : offlineDelegate?
    
    let db = SqliteDbStore()
    var newRipa = ""
    var ripamaster:RipaTempMaster?
    var strIPAddress = ""
    
    // var ripamaster = [RipaTempMaster]()
    
    func updateActvityOffline(){
        
        self.userSettingsModel.userDelegate = self
        self.userSettingsModel.getUserSettings()
        
        let userDefaults = UserDefaults.standard
        let isUpdate = userDefaults.string(forKey: "isOffline")
        
        if isUpdate != "0" {
            return
        }
        db.openDatabase()
        
       
        savedRipaList = db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE syncStatus is 0") ?? []
        
        print(savedRipaList)
        // for item in savedRipaList {
        // Do this
        if savedRipaList.count > 0{
            
        }
        else{
            return
        }
        
        ripamaster = savedRipaList[0];//item
        personArray = ViewModel.getUseSavedRipa(key: ripamaster!.key)
        
        var traini : String = "0"
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
            traini = "1"
        }
        
        let os = ProcessInfo().operatingSystemVersion
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        
        ripaActivity = Ripaactivity(key: ripamaster!.key , custid: ripamaster!.custid , City: ripamaster!.city, date_time:  dateInFormat, userid:ripamaster!.userid , username:ripamaster!.username, Notes:ripamaster!.note, latitude:ripamaster!.lat, longitude:ripamaster!.long, start_date:ripamaster!.startDate, end_date:ripamaster!.endDate, deviceid:Int(ripamaster!.deviceid) ?? 0, Location:ripamaster!.location, officer_experience: previewModel.calculateYearOfExp(), is_K_12_Student:ripamaster!.is_K_12_Student, CreatedBy:ripamaster!.CreatedBy, ip_address:previewModel.strIPAddress, stop_date:ripamaster!.stopDate , stop_time:ripamaster!.stopTime, stop_duration:ripamaster!.stopDuration, app_version:previewModel.appVersion!, platform:"ios", traffic_id:ripamaster!.skeletonID, activity_status_id: "1", access_token: AppManager.getLastSavedLoginDetails()?.result?.access_token ?? "", timetaken:ripamaster!.timeTaken, citation_number: ripamaster!.citationNumber, county_id: ripamaster!.countyId, activity_id: ripamaster?.activityId ?? "", time_duration_enable: AppConstants.ripaTimeDuration, call_number: ripamaster!.callNumber, onscene_time: ripamaster!.onsceneTime , clear_time_of_the_Offrcer: ripamaster!.clearTimeOfOfficer, overall_call_clear_time: ripamaster!.overallCallClearTime, call_type: ripamaster!.callType, unitId: ripamaster!.unitId, zone: ripamaster!.zone, ripaPersons:[], supervisorId: "", ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, reason_for_stop: ripamaster?.reason_for_stop ?? "")
        
        print(ripamaster!.status)
        
        if ripamaster!.status == "Resume"{
            ripaActivity?.activity_status_id = "9"
        }
        
//        if ripamaster!.status == "Created"{
//            ripaActivity?.activity_status_id = "7"
//        }
//        else if ripamaster!.status == "Resume"{
//            ripaActivity?.activity_status_id = "9"
//        }
        
      //  print("Hello, \(personArray)!")
        
        var userRipaResponse : RipaResponse = db.getRipaResponse()!
        if userRipaResponse.question_id.isEmpty {
             userRipaResponse  = self.createRipaResponseData(data: self.userSettingArray)
        }
        var temp1 : String!
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String{
            temp1 = "\(userOption)"
            userRipaResponse.response = temp1
        }
        
        createUserSettingPersonsDict(personArray: personArray, ripaActivity: ripaActivity!, statusId: ripaActivity?.activity_status_id ?? "1", ripaResponse: userRipaResponse)
        
        let updateRipa:UpdateRipa =  updateRipaParam()
        submitParam(params: updateRipa, toSave: false)
        
    }
    
    func getUserSettingData(settingData: UserSettingModel?) {
        self.userSettingArray = settingData!
    }
    
    func sendSettingInfo(data: UserSettingModel) {
        self.userSettingArray = data
    }
    
    
    var updateResopnseArray = [RipaResponse]()
    
    func createUserSettingPersonsDict(personArray:[[String: Any]] ,ripaActivity:Ripaactivity ,statusId:String,ripaResponse : RipaResponse) {
        //setKey()
        // resetArray()
        self.personArray.removeAll()
        self.ripaPersonsArray.removeAll()
        
        print(AppConstants.activityID)
        
        var supervisorId : String = ""
        if  let userOption = UserDefaults.standard.object(forKey: "supervisorId") as? String{
            supervisorId = userOption
        }
        
        self.ripaActivity = ripaActivity
        
        var traini : String = "0"
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
            traini = "1"
        }
        
        let os = ProcessInfo().operatingSystemVersion
        let userId = Int((AppManager.getLastSavedLoginDetails()?.result?.userid)!)
        
        var i = 1
        for person in personArray{
            updateResopnseArray.removeAll()
            
            var questArray = (person["QuestionArray"] as! [QuestionResult1])
            
            self.personArray = personArray
            questArray.append(contentsOf: (person["CascadeQuestionArray"] as!  [QuestionResult1]))
            
            var  selectedOptionsArray=[[Questionoptions1]]()
            selectedOptionsArray = (person["SelectedOption"] as! [[Questionoptions1]])
            
            let address = createObj(mainQuestId: "21" , ripaID: "21", optionValue: AppConstants.address, physical_attribute: "")
            address.isSelected = true
            
            for question in questArray{
                
                if question.question == "City or Unincorporated Area"{
                    print("Hello")
                   // question.id = "21"  home btc 208
                }
                
                if question.question_code == "T7" {
                   
                }
                
                if question.question_code == "25" {
                    continue
                }
                
                if question.question_code == "C25" && AppConstants.LocTypeIndex != 1 {
                    continue
                }
                
                
                
                if question.question_code == "2"{
                    let timeTaken:String?
                    if AppConstants.ripaTimeDuration == "N"{
                        timeTaken = Date().calculateTime(from_date: ripaActivity.start_date , to_date: getCurrentTime())
                    }else{
                        timeTaken = getTimeTaken()
                    }
                    
                    var obj = RipaResponse(question_id: question.id, response: timeTaken!, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: "", key:AppConstants.key , personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "0", cascade_option_id: "0", main_question_id: question.id, supervisorId: supervisorId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, isSelected: "")
                    obj.activity_id = AppConstants.activityID
                    updateResopnseArray.append(obj)
                    continue
                }
              
                // FOR NON SELECTED OPTIONALS
                if question.is_required == "0" && question.visible_question == "1"{
                    let selectedOptionalArray =  question.questionoptions!.filter { $0.isSelected }
                    if selectedOptionalArray.count < 1{
                        var obj = RipaResponse(question_id: question.id, response: "", internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: "", key:AppConstants.key , personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "0", cascade_option_id: "0", main_question_id: question.id, supervisorId: supervisorId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, isSelected: "")
                        obj.activity_id = AppConstants.activityID
                        if obj.question_id == "62" && obj.question_code == "C27" {
                            
                        }
                        else {
                            updateResopnseArray.append(obj)
                        }
                        
                        continue
                    }
                }
                
                if question.question_code == "23"{
                    var ripaRes : RipaResponse = ripaResponse
                    ripaRes.activity_id = AppConstants.activityID
                    updateResopnseArray.append(ripaRes)
                    continue
                }
            
                var isVisible = UserDefaults.standard.integer(forKey: "isVisible")
                
                if isVisible == 1 ,question.question_code == "T2",let gender = UserDefaults.standard.object(forKey: "gender") as? String,gender.count > 0 {
                    var ripaRes : RipaResponse = ripaResponse
                    ripaRes.activity_id = AppConstants.activityID
                    ripaRes.question = question.question
                    ripaRes.main_question_id = question.id
                    ripaRes.question_code = question.question_code
                    ripaRes.question_id = question.id
                    ripaRes.order_number = question.order_number
                    ripaRes.option_id = ""
                    ripaRes.response = gender
                    if  let attribute = UserDefaults.standard.object(forKey: "officerGenderAttribute") as? String{
                        ripaRes.physical_attribute = attribute
                    }
                    updateResopnseArray.append(ripaRes)
                    continue
                }
             
                if isVisible == 1 ,question.question_code == "T1"{
                    let arr = UserDefaults.standard.array(forKey: "ethencity")
                    for i in (0 ..< (arr?.count ?? 0)) {
                        let dict = arr?[i] as! NSDictionary
                        var ripaRes : RipaResponse = ripaResponse
                        ripaRes.activity_id = AppConstants.activityID
                        ripaRes.question = question.question
                        ripaRes.option_id = ""
                        ripaRes.main_question_id = question.id
                        ripaRes.question_code = question.question_code
                        ripaRes.question_id = question.id
                        ripaRes.order_number = dict["order_number"] as! String
                        ripaRes.response = dict["option_value"] as! String
                        ripaRes.physical_attribute = dict["physical_attribute"] as! String
                        ripaRes.cascade_option_id = dict["cascade_ripa_id"] as! String
                        updateResopnseArray.append(ripaRes)
                    }
                    continue
                }
                
                if question.question_code == "22"{
                    let exp = calculateYearOfExp()
                    var obj = RipaResponse(question_id: question.id, response: exp, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: "", key:AppConstants.key, personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "0", cascade_option_id: "0", main_question_id: question.id, supervisorId: supervisorId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, isSelected: "")
                    obj.activity_id = AppConstants.activityID
                    updateResopnseArray.append(obj)
                    continue
                }

                
                if question.question_code == "C24"{
                    if AppConstants.isSchoolSelected == "Yes" {
                        let option = question.questionoptions!.first
                        var optionId : String = "0"
                         let opId = option!.option_id
                        if opId.count > 0 {
                            optionId = opId
                        }
                        optionId = "1225"
                       // let orderNo = option!.order_number
                        var obj = RipaResponse(question_id: "108", response: option!.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: address.physical_attribute, key: AppConstants.key, personId: String(i) , description: "", question_code: option!.question_code_for_cascading_id, cascade_ques_id: "0", order_number: option!.order_number, option_id: optionId, cascade_option_id: "0", main_question_id: address.main_question_id, supervisorId: supervisorId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, isSelected: "")
                        obj.activity_id = AppConstants.activityID
                       
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                if question.question_code == "5"{
                    address.isSelected = true
                    address.main_question_id = question.id
                    address.ripa_id = question.id
                    
                    var obj = RipaResponse(question_id: question.id, response: address.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: address.physical_attribute, key: AppConstants.key, personId: String(i) , description: address.optionDescription, question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "0", cascade_option_id: "0", main_question_id: question.id, supervisorId: supervisorId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, isSelected: "")
                    obj.activity_id = AppConstants.activityID
                    updateResopnseArray.append(obj)
                   
                }
                
                for options in selectedOptionsArray{
                    for opt in options{
                        print(question.id)
                        print(question.question_code)
                        print(opt.ripa_id)
                        print(opt.option_value)
                        print(opt.isSelected)
                        print(opt.cascade_ripa_id)
                        if opt.main_question_id == "21" && ( opt.option_value == "Block" || opt.option_value == "Street"){
                            continue
                        }
                        var obj:RipaResponse?
                        
                        var optionId : String = "0"
                        let opId = opt.option_id
                        
                        if opt.ripa_id == question.id || (question.question_code == "C6" && opt.cascade_ripa_id == question.id) || (question.question_code == "5" && opt.ripa_id == "118") || (question.question_code == "5" && opt.ripa_id == "122")||(question.question_code == "5" && opt.ripa_id == "26") || (question.question_code == "21" && opt.main_question_id == "39" && opt.isSelected == true) || (question.question_code == "C30" && opt.ripa_id == "67") && (question.question_code == "C5" && opt.mainQuestId == "14") || (question.question_code == "C1" && opt.mainQuestId == "15" && opt.option_id == "93") || (question.question_code == "17" && opt.ripa_id == "25") || (question.question_code == "T7" && opt.ripa_id == "32") || (question.question_code == "17" && opt.ripa_id == "84"){
                            
                            
                            if updateResopnseArray.count > 14 {
                                print("check 4 consent given")
                            }
                            
                            if opId.count > 0 {
                                optionId = opId
                            }
                            
                            if question.question_code == "C6" || question.question_code == "C7" || question.question_code == "C26" || question.question_code == "C25" {
                                obj = RipaResponse(question_id: question.id, response: opt.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: opt.physical_attribute, key: AppConstants.key, personId: String(i) , description: opt.optionDescription, question_code: question.question_code, cascade_ques_id: opt.ripa_id, order_number: opt.mainQuestOrder , option_id: optionId, cascade_option_id: opt.option_id, main_question_id: opt.main_question_id, supervisorId: supervisorId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, isSelected: "")
                            }
                            else{
                                obj = RipaResponse(question_id: question.id, response: opt.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: opt.physical_attribute, key: AppConstants.key, personId: String(i) , description: opt.optionDescription, question_code: opt.question_code_for_cascading_id, cascade_ques_id: opt.cascade_ripa_id, order_number:  opt.mainQuestOrder , option_id: optionId, cascade_option_id: opt.option_id, main_question_id: opt.main_question_id, supervisorId: supervisorId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, isSelected: "")
                                
                                
                                if question.question_code == "C9"{
                                    obj?.question_id = question.id
                                }
                            }
                            
                            if obj?.question_code == "C24"{
                                obj?.option_id = "1225"
                            }
                            
                            if obj?.main_question_id == "39"{
                              if obj?.question_code == "C40" || opt.ripa_id == "75"{
                                    obj?.question = "Verbal Warning"
                                    obj?.question_id = opt.ripa_id
                                    //obj?.question_code = "C40"
                                }
                                else if obj?.question_code == "C41" || opt.ripa_id == "76" {
                                    obj?.question = "Written Warning"
                                    obj?.question_id = opt.ripa_id
                                }
                                else if obj?.question_code == "C15" || opt.ripa_id == "40" {
                                    obj?.question = "Citation for infraction: Code"
                                    obj?.question_id = opt.ripa_id
                                  //  obj?.question_code = "C15"
                                }
                                else if obj?.question_code == "C17" || opt.ripa_id == "42" {
                                    obj?.question = "Custodial arrest without warrant"
                                    obj?.question_id = opt.ripa_id
                                   // obj?.question_code = "C17"
                                }
                                else if obj?.question_code == "C16" || opt.ripa_id == "41" {
                                    obj?.question = "In-field cite and release"
                                    obj?.question_id = opt.ripa_id
                                }
                            }
                            
                            if obj?.question_code == "T3" && obj?.isSelected != "Yes"{
                                let ans = obj!.response
                                obj?.question = ans
                                obj!.response = "No"
                            }

                            if obj?.question_code == "C44" && obj?.isSelected != "Yes"{
                                let ans = obj!.response
                                obj?.question = ans
                                obj!.response = "No"
                            }
                            if obj?.question_code == "T3" && obj?.isSelected != "Yes"{
                                let ans = obj!.response
                                obj?.question = ans
                                obj!.response = "No"
                            }
                            if obj?.question_code == "15" && obj?.isSelected != "Yes"{
                                let ans = obj!.response
                                obj?.question = ans
                                obj!.response = "No"
                            }
                            
                            if obj?.isSelected == "" &&  obj?.question_code == "C10" &&  obj?.question_id == "27" {
                                continue
                            }
                            if obj?.isSelected == "" &&  obj?.question_code == "C10" &&  obj?.cascade_ques_id == "27" {
                                continue
                            }
                            if obj?.question_code == "C5" && obj?.cascade_ques_id == "20" && obj?.main_question_id == "14" && obj?.cascade_option_id == "93" && obj?.question_id != "15"{
                                continue
                            }
                            
                            if AppConstants.isSchoolSelected == "" &&  obj?.question_code == "C9" {
                                continue
                            }
                            
                            if obj?.option_id == "1353"{
                                continue
                            }
                            
                            if obj?.question_code == "15"{
                                obj?.question_id = "35"
                                obj?.main_question_id = "35"
                                obj?.cascade_option_id = "169"

                            }
                            
                            if obj?.question_code == "C44"{
                                obj?.question_id = "79"
                                obj?.main_question_id = "79"
                            }
                            
                            if obj?.question_code == "C43"{
                                obj?.question_code = "T5"
                                //obj?.option_id = ""
                                obj?.main_question_id = "108"
                            }
                            
                            if obj?.question_code == "T3"{
                                obj?.question_id = "101"
                                obj?.main_question_id = "101"
                            }
                            
                            
                            if obj?.question_code == "C6" && obj?.question_id == "22" && obj?.option_id == "108"{
                                continue
                            }
                            
                            if obj?.question_code == "C6" && obj?.cascade_option_id == "108" && obj?.question == "Location"{
                                if let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
                                    obj?.isSelected = "Yes"
                                    obj?.response = "\(latString) , \(longString)"
                                }
                            }
                            
                            if obj?.question_code == "C6" && obj?.cascade_option_id == "108"{
                                obj?.response = AppConstants.city
                                obj?.question = "City or Unincorporated Area"
                                obj?.cascade_ques_id = ""
                                obj?.cascade_option_id = ""
                                obj?.option_id = "108"
                            }
                           
                            
                            if obj?.question_code == "C6" && obj?.question == "City or Unincorporated Area" {
                                let contains = updateResopnseArray.contains(where: {
                                    $0.question == "City or Unincorporated Area"
                                })
                                if contains == true {
                                   continue
                                }
                            }
                            
                            
                            
                            if obj?.question_code == "C57" && obj?.cascade_option_id == "1412" && question.id == "21"{
                                obj?.question = "Other"
                                obj?.response = AppConstants.LocTypeDescription
                            }
                            
                            if obj?.question_code == "C53" && obj?.cascade_option_id == "1408" && question.id == "21"{
                                obj?.question = "Geographic Coordinates"
                                obj?.question_id = "119"
                               // obj?.cascade_ques_id = ""
                                obj?.physical_attribute = ""
                                obj?.cascade_option_id = ""
                                if let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
                                   
                                    obj?.response = "\(latString) , \(longString)"
                                }
                            }
                          
                            if obj?.question_id == "21" && obj?.cascade_ques_id == "22"{
                                continue
                            }
                            
                            if opt.mainQuestId == ""{
                                obj?.order_number = question.order_number
                                obj?.question_id = question.id
                            }
                            
                            if obj?.question_code == "" || obj?.question_code == "0"{
                                obj?.question_code = question.question_code
                            }
                            
                            
                            if obj?.question_code == "C27" || obj?.question_id == "62"{
                                obj?.response = "Yes"
                            }
                            
                            if obj!.question == "Location Type"{
                                obj!.question_code = "C52"
                                if opt.option_id == "1408" {
                                    obj?.cascade_ques_id = "119"
                                }
                                else if opt.option_id == "1409" {
                                    obj?.cascade_ques_id = "120"
                                }
                                else if opt.option_id == "1410" {
                                    obj?.cascade_ques_id = "121"
                                }
                                else if opt.option_id == "1411" {
                                    obj?.cascade_ques_id = "122"
                                }
                                else if opt.option_id == "1412" {
                                    obj?.cascade_ques_id = "123"
                                }
                                obj?.option_id = "1407"
                            }
                            
                            
                            if obj!.cascade_ques_id == ""{
                                obj!.cascade_ques_id = "0"
                            }
                            
                            if opt.tag == "Description"{
                                if question.question_code == "14"{
                                    obj?.question = "Reason Description"
                                    obj?.response = opt.option_value
                                    obj?.description = "StReas_N"
                                }
                                if question.question_code == "17"{
                                    obj?.question = "Basis Description"
                                    obj?.response = opt.option_value
                                    obj?.description = "BasSearch_N"
                                }
                            }
                            
                            if obj!.response == "Highway and Closest Highway Exit" && obj!.question == "Location"{
                                continue
                            }
                            
                            if obj!.response == "Closest Intersection" && obj!.question == "Location"{
                                continue
                            }
                            if obj!.response == "Block Number and Street Name" && obj!.question == "Location"{
                                continue
                            }
                            if obj!.question == "Geographic Coordinates" && (obj!.cascade_ques_id != "0" || obj!.cascade_ques_id != "0"){
                                continue
                            }
                    
                            if obj?.question_code == "C6"{
                                obj?.cascade_ques_id = "22"
                            }
                            
                            if question.question == "Block Number and Street Name" {
                                print( question.question_code)
                            }
                                if question.question_code == "C54" && question.question == "Block Number and Street Name" {
                                    obj?.response = "Block"
                                    obj?.cascade_ques_id = "53"
                                    obj?.option_id = "1409"
                                    obj?.cascade_option_id = "1229"
                                    let streetObj = self.createBlockObject(data: obj!)
                                    let contains = updateResopnseArray.contains(where: {
                                        $0.question == "Block"
                                    })
                                    if contains == false {
                                        updateResopnseArray.append(streetObj!)
                                    }
                                    else {
                                        obj?.response = "Block"
                                    }
                                    
                                    updateResopnseArray.append(obj!)
                                }
                             else  if question.question_code == "C54" && question.question == "Block Number and Street Name" {
                                let contains = updateResopnseArray.contains(where: {
                                    $0.response == "Block"
                                })
                                if contains == false {
                                    obj?.response = "Block"
                                 }
                                 obj?.option_id = "1409"
                                 obj?.cascade_option_id = "1229"
                                 updateResopnseArray.append(obj!)
                               }
                            
                         
                             if question.question_code == "C54" && question.question == "Block Number and Street Name" {
                                  obj?.cascade_ques_id = "23"
                                  obj?.option_id = "1409"
                                  obj?.cascade_option_id = "109"
                                    let streetObj = self.createStreetObject(data: obj!)
                                  let contains = updateResopnseArray.contains(where: {
                                      $0.question == "Street"
                                  })
                                  if contains == false {
                                      obj?.cascade_option_id = "109"
                                      updateResopnseArray.append(streetObj!)
                                  }
                                  obj?.response = "Street"
                                   // updateResopnseArray.append(obj!)
                                }
                             else  if question.question_code == "C54" && question.question == "Block Number and Street Name" {
                                let contains = updateResopnseArray.contains(where: {
                                    $0.response == "Street"
                                })
                                if contains == false {
                                    obj?.response = "Street"
                                }
                                 obj?.option_id = "1409"
                                 obj?.cascade_option_id = "109"
                                 updateResopnseArray.append(obj!)
                             }
                            
                            if question.question_code == "C55" && question.question == "Closest Intersection" {
                                obj?.cascade_option_id = "1231"
                                obj?.cascade_ques_id = "54"
                                obj?.response = "First Intersection"
                                obj?.option_id = "1410"
                                 let interObj = self.createFirstIntersectionObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "First Intersection"
                                 })
                                 if contains == false && opt.isSelected == true{
                                     updateResopnseArray.append(interObj!)
                                 }
                                 else {
                                     obj?.response = "First Intersection"
                                 }
                               }
                            
                            if question.question_code == "C55" && question.question == "Closest Intersection" {
                                   let interObj = self.createSecondIntersectionObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "Second Intersection"
                                 })
                                 if contains == false && opt.isSelected == true {
                                     updateResopnseArray.append(interObj!)
                                 }
                                 else {
                                     obj?.cascade_option_id = "1404"
                                     obj?.cascade_ques_id = "115"
                                     obj?.option_id = "1410"
                                     obj?.response = "Second Intersection"
                                 }
                               }
                            
                            if question.question_code == "C56" && question.question == "Highway and Closest Highway Exit" {
                                obj?.cascade_option_id = "1405"
                                obj?.cascade_ques_id = "116"
                                obj?.response = "Highway"
                                obj?.option_id = "1411"
                                let highwayObj = self.createHighwayObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "Highway"
                                 })
                                 if contains == false && opt.isSelected == true{
                                     updateResopnseArray.append(highwayObj!)
                                 }
                                 else {
                                     obj?.response = "Highway"
                                 }
                               }
                            if question.question_code == "C56" && question.question == "Highway and Closest Highway Exit" {
                               //  obj?.cascade_ques_id = "23"
                                obj?.option_id = "1411"
                                var highwayObj = self.createClosetHighwayObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "Closest Highway"
                                 })
                                 if contains == false && opt.isSelected == true {
                                      updateResopnseArray.append(highwayObj!)
                                     if obj?.response == "Closest Highway"{
                                         obj?.question_code = "C56"
                                         obj?.question_id = "122"
                                         obj?.option_id = "1411"
                                     }
                                     let containsO = updateResopnseArray.contains(where: {
                                         $0.response == "Closest Highway"
                                     })
                                     if containsO == false {
                                         highwayObj?.cascade_option_id = "1406"
                                         highwayObj?.cascade_ques_id = "117"
                                         highwayObj?.question = question.question
                                         highwayObj?.response = "Closest Highway"
                                         highwayObj?.question_code = "C56"
                                         highwayObj?.question_id = "122"
                                         highwayObj?.option_id = "1411"
                                         updateResopnseArray.append(highwayObj!)
                                     }
                                 }
                                 else {
                                     obj?.response = "Closest Highway"
                                     obj?.cascade_option_id = "1406"
                                     obj?.cascade_ques_id = "117"
                                     highwayObj?.option_id = "1411"
                                     obj?.question_code = "C56"
                                     obj?.question_id = "122"
                                     
                                     let containsO = updateResopnseArray.contains(where: {
                                         $0.response == "Closest Highway"
                                     })
                                     if containsO == false {
                                         updateResopnseArray.append(obj!)
                                     }
                                 }
                               }
                            
                            if obj?.question_code == "T7" && obj?.cascade_option_id == "145"{
                                obj?.response = options[0].option_value
                            }
                  
                            if obj?.main_question_id == "21" && obj?.option_id == "113" && obj?.question_code == "C10" && obj?.question_id == "27"{
                                continue
                             }
                            
                            if obj?.cascade_option_id == "0" && obj?.option_id == "0" && obj?.question_code != "C29" && obj?.question_code != "14" && obj?.main_question_id != "21" && obj?.main_question_id != "14" && obj?.main_question_id != "39" && obj?.main_question_id != "25"{
                                continue
                             }
                            
                            if obj?.question_code == "C34",let casId = obj?.cascade_option_id{
                               // obj?.option_id = "1268"
                                obj?.option_id = casId
                            }
                        
                        
                            if obj?.question_code == "C33"{
                                obj?.option_id = "1240"
                            }
                            if obj?.question_code == "C28"{
                                obj?.option_id = "1249"
                                obj?.cascade_ques_id = ""
                            }
                            if obj?.question_code == "C32",let casId = obj?.cascade_option_id{
                               // obj?.option_id = "1260"
                                obj?.option_id = casId
                                obj?.cascade_ques_id = ""
                            }
                            if obj?.question_code == "C42"{
                                obj?.option_id = "1294"
                                obj?.cascade_ques_id = ""
                            }
                            if obj?.question_code == "C45"{
                                obj?.option_id = "1355"
                            }
                            if obj?.question_code == "C46"{
                                obj?.option_id = "1356"
                            }
                            if obj?.question_code == "C29"{
                                obj?.option_id = "1248"
                            }
                            if obj?.question_code == "C30"{
                                obj?.option_id = "1241"
                                obj?.cascade_ques_id = ""
                                let check = updateResopnseArray.contains(where: {
                                    $0.question == "Perceived Gender"
                                })
                                if check == true {
                                    continue
                                }
                            }
                            
                           
                            if obj?.question_id == "21" && obj?.option_id == "0" && obj?.question_code == "5" && obj?.question_code != "C9"{
                                continue
                             }
                            
                            let exist = updateResopnseArray.contains(where: {
                                $0.question_code == obj?.question_code
                            })
 
                            let index = updateResopnseArray.firstIndex(where: {
                                $0.question_code == obj?.question_code
                            })
                            let objjj = updateResopnseArray
                            
                            if obj?.main_question_id == "25" && (obj?.cascade_option_id == "1304" || obj?.cascade_option_id == "1305" || obj?.cascade_option_id == "1306"){
                                obj?.question = "Consent given"
                                obj?.question_code = options[0].question_code_for_cascading_id
                            }
                            
                            if obj?.question_code == "5" && obj?.cascade_ques_id != "118"{
                                obj?.option_id = "125"
                             }
                            
                          //  print(objjj)
                            if exist == true && index != nil && obj?.question_code != "C52" && obj?.question_code != "C43" && obj?.question_code != "14" && obj?.main_question_id != "21" && obj?.question_code != "C32" && obj?.question_code != "C34" && obj?.main_question_id != "14" && obj?.question_code != "T8" && obj?.question_code != "T7" && obj?.question_code != "18"  && obj?.question_code != "21" && obj?.question_code != "17" && obj?.question_code != "19" && obj?.question_code != "20" && obj?.question_code != "C13" && obj?.question_code != "C14"  {
                                
                                if obj?.question_code == "C40" && updateResopnseArray[index!].cascade_ques_id == "75" {
                                    continue
                                }
                                else if obj?.question_code == "C39" && updateResopnseArray[index!].cascade_ques_id == "74" {
                                    continue
                                }
                                else if obj?.question_code == "C41" && updateResopnseArray[index!].cascade_ques_id == "76" {
                                    continue
                                }
                                else if obj?.question_code == "C15" && updateResopnseArray[index!].cascade_ques_id == "40" {
                                    continue
                                }
                                else if obj?.question_code == "C17" && updateResopnseArray[index!].cascade_ques_id == "42" {
                                    continue
                                }
                                else if obj?.question_code == "C16" && updateResopnseArray[index!].cascade_ques_id == "41" {
                                    continue
                                }
                                else if obj?.question_code == "C47" && updateResopnseArray[index!].cascade_ques_id == "84" {
                                    continue
                                }
                                else if obj?.question_code == "C14" && updateResopnseArray[index!].cascade_ques_id == "32" {
                                   // continue home BTC 197 click to open long bar than confirm order 200n
                                }
                                
                                if obj?.question_code == "C44"{
                                    obj?.option_id = "1354"
                                }
                                if obj?.question_code == "T3"{
                                    obj?.option_id = "1415"
                                }
                                
                                updateResopnseArray.remove(at: index!)
                                updateResopnseArray.append(obj!)
                            }
                            else if obj?.question_id == "75"{
                                obj?.question_code = "C40"
                                updateResopnseArray.append(obj!)
                            }
                            else if obj?.question_code == "C39" && index != nil && updateResopnseArray[index!].cascade_ques_id == "74" {
                                continue
                            }
                           else if obj?.question_id == "76"{
                                obj?.question_code = "C41"
                                updateResopnseArray.append(obj!)
                            }
                            else {
                                
                                if obj?.question_code == "C52" && obj?.option_id == "1407" &&  obj!.question != "Location Type"{
                                    obj?.question_code = "5"
                                    obj?.option_id = ""
                                }
                                
                                if obj?.question_code == "15"{
                                    obj?.option_id = "1353"
                                }
                                
                                 if obj?.main_question_id == "39"{
                                     if opt.ripa_id == "75"{
                                         obj?.question_code = "C40"
                                     }
                                     else if opt.ripa_id == "76" {
                                         obj?.question_code = "C41"
                                     }
                                     else if opt.ripa_id == "40" {
                                         obj?.question_code = "C15"
                                     }
                                     else if opt.ripa_id == "42" {
                                         obj?.question_code = "C17"
                                     }
                                     else if opt.ripa_id == "41" {
                                         obj?.question_code = "C16"
                                     }
                                 }
                                
                                if obj?.question_code == "C9"{
                                    obj?.option_id = "1226"
                                   // obj?.cascade_option_id = "1226"
                                 }
                                
                                let checkExist = self.checkQuestionIsExist(questionCode: "C9")
                                if checkExist == true && obj?.question_code != "C29" && obj?.question_code != "C30" && obj?.question_code != "C28" && obj?.question_code != "C33" && obj?.question_code != "C34" && obj?.question_code != "C32" && obj?.question_code != "C43"{
                                    continue
                                }
                               
                                updateResopnseArray.append(obj!)
                            }
                            
                            let objj = updateResopnseArray
                          //  print(objj)
                           
                        }
                        let objj = updateResopnseArray
                    }
                    
                }
            }
            let objj = updateResopnseArray
            let obj = RipaPerson(CreatedBy: String(userId!), person_name: "P"+String(i), key: AppConstants.key,date: AppConstants.date,time: AppConstants.time,duration: AppConstants.duration, ripa_response :  updateResopnseArray.sorted(by: {Int($0.order_number) ?? 0 < Int($1.order_number) ?? 0 }))
           
            ripaPersonsArray.append(obj)
            i += 1
//            let arr = ripaPersonsArray
//            print(arr)
        }
        ripaActivityDict(statusId: statusId)
    }
    
    func checkQuestionIsExist(questionCode : String) -> Bool {
        let isExistIng = updateResopnseArray.contains(where: {
            $0.question_code == questionCode
        })
       return isExistIng
    }
    
    func calculateYearOfExp()->String{
        var fromYear = 2010
        let result = AppManager.getLastSavedLoginDetails()?.result
        if result?.start_year != ""{
            fromYear = Int(result?.start_year ?? "2010")!
        }
        
        let year = Calendar.current.component(.year, from: Date())
        let yearofexp = year - fromYear
        return String(yearofexp)
    }
    
    func createObj( mainQuestId:String?, ripaID:String?,optionValue:String?,physical_attribute:String?)->Questionoptions1{
        let option:Questionoptions1 = Questionoptions1(mainQuestId: mainQuestId!, mainQuestOrder:"" ,option_id: "", ripa_id:ripaID!, custid: "", option_value: optionValue!, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "", tag: "", physical_attribute: physical_attribute!, default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: mainQuestId!, isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        return option
    }
    
    
    func ripaActivityDict(statusId:String){
        ripaActivityArray.removeAll()
        strIPAddress = self.getIPAddress()
        print("IPAddress :: \(String(describing: strIPAddress))")
        
        ripaActivity?.end_date = getCurrentTime()
      //  ripaActivity?.City = AppConstants.address
        ripaActivity?.ip_address = strIPAddress
        ripaActivity?.ripaPersons = self.ripaPersonsArray
       // ripaActivity?.stop_date = AppConstants.date
        //+ " "+ AppConstants.time
     //   ripaActivity?.stop_time = AppConstants.time
     //   ripaActivity?.stop_duration = AppConstants.duration
//        ripaActivity?.Location = AppConstants.address
//        ripaActivity?.key = AppConstants.key
//        ripaActivity?.activity_status_id = AppConstants.activityStatusId
//        ripaActivity?.latitude = AppConstants.lati
//        ripaActivity?.longitude = AppConstants.longi
//        ripaActivity?.activity_id = AppConstants.activityID
//        ripaActivity?.time_duration_enable = AppConstants.ripaTimeDuration
//        if AppConstants.ripaTimeDuration == "Y"{
//            ripaActivity?.timetaken = getTimeTaken()
//        }
//        else{
//            let timeTaken =  Date().calculateTime(from_date: ripaActivity?.start_date ?? getCurrentTime() , to_date: getCurrentTime())
//            ripaActivity?.timetaken = timeTaken
//        }
//
//        ripaActivity?.is_K_12_Student = AppConstants.isStudent
//        ripaActivity?.citation_number = ""
//        ripaActivity?.deviceid = 0
        
//        if AppConstants.status == "Created"{
//            ripaActivity?.citation_number = AppConstants.citation
//            ripaActivity?.deviceid = Int(AppConstants.deviceid) ?? 0
//        }
//
//
//
//        if viewType == "UseSaveRipa" && AppConstants.trafficId != ""{
//            print(AppConstants.trafficId)
//            ripaActivity?.traffic_id = AppConstants.trafficId
//        }
        
        ripaActivityArray.append(ripaActivity!)
    }
    
    func createHighwayObject(data : RipaResponse) -> RipaResponse? {
        var obj:RipaResponse?
        obj = data
        obj?.question = "Highway"
        obj?.response = AppConstants.highway
        obj?.question_code = "C50"
        obj?.question_id = "116"
        obj?.cascade_ques_id = "0"
        obj?.cascade_option_id = "0"
        return obj
    }
    
    func createClosetHighwayObject(data : RipaResponse) -> RipaResponse? {
        var obj:RipaResponse?
        obj = data
        obj?.question = "Closest Highway"
        obj?.response = AppConstants.closestHighway
        obj?.question_code = "C51"
        obj?.question_id = "117"
        obj?.cascade_ques_id = "0"
        obj?.cascade_option_id = "0"
        return obj
    }
    
    func createFirstIntersectionObject(data : RipaResponse) -> RipaResponse? {
        var obj:RipaResponse?
        obj = data
        obj?.question = "First Intersection"
        obj?.response = AppConstants.firstIntersection
        obj?.question_code = "C26"
        obj?.question_id = "54"
        return obj
    }
    
    func createSecondIntersectionObject(data : RipaResponse) -> RipaResponse? {
        var obj:RipaResponse?
        obj = data
        obj?.question = "Second Intersection"
        obj?.response = AppConstants.secondIntersection
        obj?.question_code = "C49"
        obj?.question_id = "115"
        return obj
    }
    
    func createBlockObject(data : RipaResponse) -> RipaResponse? {
        var obj:RipaResponse?
        obj = data
        obj?.question = "Block"
        obj?.response = AppConstants.block
        obj?.question_code = "C25"
        obj?.cascade_option_id = "1229"
        obj?.option_id = "109"
        obj?.question_id = "53"
        return obj
    }
   
    func createStreetObject(data : RipaResponse) -> RipaResponse? {
        var obj:RipaResponse?
        obj = data
        obj?.question = "Street"
        obj?.cascade_option_id = "109"
        obj?.response = AppConstants.street
        obj?.question_code = "C7"
        obj?.option_id = "1229"
        obj?.question_id = "23"
        return obj
    }
    
    func getTimeTaken()-> String{
        let timetaken =  (Double(AppConstants.applicationtime) ?? 0.0)/60
        var roundedtimetaken = Int(timetaken.rounded())
        if roundedtimetaken == 0{
            roundedtimetaken = 1
        }
        return String(roundedtimetaken)
    }
    
    
    @objc func getCurrentTime()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        
        return dateInFormat
    }
    
    @objc func getCurrentDateTime()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        
        return dateInFormat
    }
    
    
    func getIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address ?? ""
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
        
        var opId : String = "0"
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
        
        let ripaRes = RipaResponse(question_id: questionId, response: rep, internal: inter, userid: idUser, question: questn, CreatedBy: cDate, physical_attribute: attri, key: keyS, personId: pId, description: "", question_code: qCode, cascade_ques_id: "0", order_number: orderN, option_id: opId, cascade_option_id: "0", main_question_id: mId, supervisorId: supId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version : os.getFullVersion(), is_trainee: traini, isSelected: "")
        
        return ripaRes
    }
    
    
    func submitParam(params:UpdateRipa , toSave:Bool){
        let encodedData = try! JSONEncoder().encode(params)
        let jsonString = String(data: encodedData,
                                encoding: .utf8)
        print(jsonString!)
        let dict = previewModel.convertStringToDictionary(text: jsonString!)
        
        submitAnswers(params: dict!)
    }
    
    
    func submitAnswers(params:[String:Any]) {
        // AppUtility.showProgress(nil, title:nil)
        var URL:String?
    
        URL = AppConstants.Api.updateRipa
        print(URL as Any)
        print(params)
        ApiManager.updateRipa(params: params, methodTyPe: .post, url: URL!, completion: { [self] (success,message) in
            
            if message == "Success"{
                if let json = try? JSON(data: success as! Data){
                    let errorMsg = json["result"]["serviceError"].stringValue
                    
                    if  errorMsg == ""{
                        saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "1")
                        
                        db.openDatabase()
                        savedRipaList = db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE syncStatus is 0")!
                        if savedRipaList.count > 0
                        {
                            updateActvityOffline()
                        }
                    }
                    else{
                        saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "0")
                        guard let ddelegate = delegate else { return }
                        ddelegate.syncOfflineDataCompleted()
                    }
                }
            }
            else{
                saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "0")
            }
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            
        }
        
        
        
    }
    
    func saveToDB(updateRipa : UpdateRipa , isUpdate: Bool, syncSccessful:String){
        
        db.openDatabase()
        //db.deleteAllfrom(table: "saveRipaPersonTable")
        // db.deleteAllfrom(table: "useSaveRipaOptionsTable")
        let wer:String = ripaActivity!.key
        let key = "\"\(wer)\""
        let activityArray = updateRipa.params.ripaactivity
        
        //FOR TEMPMASTER
        
        db.createTable(insertTableString: db.createRipaTempMasterTable)
        db.createTable(insertTableString: db.createSaveRipaPersonTable)
        db.createTable(insertTableString: db.createUseSaveRipaOptionTable)
        
        if isUpdate{
            db.deleteAllfrom(table: "ripaTempMasterTable WHERE key = \(key)")
            db.deleteAllfrom(table: "saveRipaPersonTable WHERE key = \(key)")
            db.deleteAllfrom(table: "useSaveRipaOptionsTable WHERE key = \(key)")
            ripamaster!.mainStatus = "0"
            ripamaster!.syncStatus = ""
            if syncSccessful == "1"{
                ripamaster!.syncStatus = "1"
                ripamaster!.mainStatus = "1"
            }
            else if syncSccessful == "0"{
                ripamaster!.syncStatus = "0"
                ripamaster!.mainStatus = "1"
            }
        }
        
        db.insertRipaTempMaster(ripaResponse: ripamaster!, tableName: db.ripaTempMaster)
        
        for activity in activityArray{
            db.openDatabase()
            // db.createTable(insertTableString: db.createSaveRipaActivityTable)
            // db.insertRipaActivity(ripaActivity: activity, tableName: "saveRipaActivityTable")
            var i = 0
            for person in activity.ripaPersons{
                
                db.insertRipaPerson(ripaPerson: person, tableName: "saveRipaPersonTable")
                
                let response = personArray[i]
                var questionArray = (response["QuestionArray"] as! [QuestionResult1])
                let cascadeOptionsArray = (response["CascadeQuestionArray"] as! [QuestionResult1])
                questionArray.append(contentsOf: cascadeOptionsArray)
                
                for question in questionArray{
                    if question.question_code == "5"{
                        if question.questionoptions!.count > 5{
                            question.questionoptions?.removeLast()
                        }
                    }
                    for options in question.questionoptions!{
                        //  if options.isSelected{
                        db.insertOptions(options: options, tableName: "useSaveRipaOptionsTable", personID: person.person_name, key: ripaActivity!.key)
                        //  }
                    }
                }
                i += 1
            }
        }
    }
    
    
    func updateRipaParam()-> UpdateRipa{
        let updateParam = UpdateParam(ripaactivity: self.ripaActivityArray)
        let param = UpdateRipa(id:(AppManager.getLastSavedLoginDetails()?.id)! , method: "updateRipaActivity", params: updateParam, jsonrpc: "2.0")
        
        return param
    }
    
}
