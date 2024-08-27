//
//  PreviewViewModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 03/04/21.
//

import UIKit
import SwiftyJSON
import Foundation

protocol PreviewModelDelegate: AnyObject {
    func setPreviewDelegate(success:String,message:String)
}

protocol SaveDelegate: AnyObject {
    func moveToPrevScreen(move:Bool)
    func getDefaultCityFromServer(data:[DefaultCityModel])
}


class PreviewViewModel {
    
    let db = SqliteDbStore()
    
    weak var previewModelDelegate : PreviewModelDelegate?
    weak var saveDelegate : SaveDelegate?
    
    var updateResopnseArray = [RipaResponse]()
    var selectedObj=[[String:Any]]()
    var personArray: [[String: Any]] = []
    
    var questionArray=[QuestionResult1]()
    var cascadeQuestionArray=[QuestionResult1]()
    var ripaPersonsArray = [RipaPerson]()
    var ripaActivityArray = [Ripaactivity]()
    
    var ripaActivity : Ripaactivity?
    var viewType = ""
    
    
    let result = AppManager.getLastSavedLoginDetails()?.result
    let custId = AppManager.getLastSavedLoginDetails()?.result?.custid
    let userId = Int((AppManager.getLastSavedLoginDetails()?.result?.userid)!)
    // var countyId = AppManager.getLastSavedLoginDetails()?.result?.county_id
    let userName = AppManager.getLastSavedLoginDetails()?.result?.username
    //let accessToken = AppManager.getLastSavedLoginDetails()?.result?.access_token
    let rmsid = AppManager.getLastSavedLoginDetails()?.result?.rmsid
    let phone = AppManager.getLastSavedLoginDetails()?.result?.phone
    //let city = AppManager.getLastSavedLoginDetails()?.result?.c
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    //Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    let id = AppManager.getLastSavedLoginDetails()?.id
    //let startDate = "01/04/2021 18:33"
    let device_id = UIDevice.current.identifierForVendor?.uuidString
    var strIPAddress = ""
    
    
    
    
    
    
    func calculateYearOfExp()->String{
        var fromYear = 2010
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
    
    
    
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    
    func updateRipaParam()-> UpdateRipa{
        let updateParam = UpdateParam(ripaactivity: self.ripaActivityArray)
        let param = UpdateRipa(id:id! , method: "updateRipaActivity", params: updateParam, jsonrpc: "2.0")
        
        return param
    }
    
    func ripaCudActivity_postParam()-> UpdateRipa{
        let updateParam = UpdateParam(ripaactivity: self.ripaActivityArray)
        let param = UpdateRipa(id:id! , method: "ripaCudActivity_post", params: updateParam, jsonrpc: "2.0")
        
        return param
    }
    
    
    
    
    func resetArray(){
        db.openDatabase()
        _ = db.getQuestions(tableName: "QuestionTable", getcascadeQuest: 1)
        cascadeQuestionArray = db.getQuestionOptions(tableName: "OptionTable", optionFor: "", person_name: "", key: "")!
        _ = db.getQuestions(tableName: "QuestionTable", getcascadeQuest: 0)
        questionArray = db.getQuestionOptions(tableName: "OptionTable", optionFor: "", person_name: "", key: "")!
    }
    
    
    
    
    func getTempObj(activityArr:[Ripaactivity])->RipaTempMaster{
        let activity = (activityArr.first)!
        print(AppConstants.notes)
        let ripaTemp = RipaTempMaster(key: AppConstants.key, skeletonID: activity.traffic_id, activityId: "", custid: activity.custid, userid: activity.userid, username: activity.username, rmsid: rmsid ?? "", phoneNumber: phone ?? "", location: activity.Location, city: activity.City, street: "", block: "", intersectionStreet: "", note: AppConstants.notes, activity_notes: "", CreatedBy: activity.CreatedBy, ticketDate: "", declarationDate: activity.end_date, violation: "", violationCode: "", violationType: "", violationID: "", offenceCode: "", email: result?.email_address ?? "" , createdOn: activity.stop_date, updatedBy: result?.UpdatedBy ?? "", updatedOn: result?.UpdatedOn ?? "", citationNumber: activity.citation_number, status: AppConstants.status, mainStatus: "0", statusChnageDate: "", ripaTempId: "", tempType: "", stopDate: activity.stop_date + " " + AppConstants.time , stopTime:AppConstants.time  ,stopDuration: AppConstants.duration, rejectedURL: "", syncStatus: "", startDate:activity.start_date, endDate:activity.end_date, is_K_12_Student:AppConstants.isStudent, lat:activity.latitude, long: activity.longitude, timeTaken: activity.timetaken, countyId: (AppManager.getLastSavedLoginDetails()?.result!.county_id)!, deviceid: String(ripaActivity!.deviceid), callNumber: AppConstants.call_number, callTime: "", onsceneTime: AppConstants.onscene_time, clearTimeOfOfficer: AppConstants.clear_time_of_the_Offrcer, overallCallClearTime: AppConstants.overall_call_clear_time, callType: AppConstants.call_type, unitId: AppConstants.unitId, zone: AppConstants.zone,reason_for_stop: activity.reason_for_stop, Previous_Platform: "",Ripa_version: "",Previous_app_Version: "")
        
        if AppConstants.status == "Saved"{
            ripaTemp.status = "Saved"
            ripaTemp.activityId = AppConstants.activityID
        }
        if AppConstants.status == "" || AppConstants.status == "Template" || AppConstants.status == "LastRipa" {
            ripaTemp.status = "Resume"
         }
                 return ripaTemp
    }
    
    
    
    func saveToDB(updateRipa : UpdateRipa , isUpdate: Bool, syncSccessful:String){
        
        db.openDatabase()
        //db.deleteAllfrom(table: "saveRipaPersonTable")
        // db.deleteAllfrom(table: "useSaveRipaOptionsTable")
        let key = "\"\(AppConstants.key)\""
        let activityArray = updateRipa.params.ripaactivity
        
        //FOR TEMPMASTER
        let ripaTemp = getTempObj(activityArr:updateRipa.params.ripaactivity)
        db.createTable(insertTableString: db.createRipaTempMasterTable)
        db.createTable(insertTableString: db.createSaveRipaPersonTable)
        db.createTable(insertTableString: db.createUseSaveRipaOptionTable)
        
        if isUpdate{
            db.deleteAllfrom(table: "ripaTempMasterTable WHERE key = \(key)")
            db.deleteAllfrom(table: "saveRipaPersonTable WHERE key = \(key)")
            db.deleteAllfrom(table: "useSaveRipaOptionsTable WHERE key = \(key)")
            ripaTemp.mainStatus = "0"
            ripaTemp.syncStatus = ""
            
            if syncSccessful == "1"{
                ripaTemp.syncStatus = "1"
                ripaTemp.mainStatus = "1"
            }
            else if syncSccessful == "0"{
                ripaTemp.syncStatus = "0"
                ripaTemp.mainStatus = "1"
            }
        }
        
        db.insertRipaTempMaster(ripaResponse: ripaTemp, tableName: db.ripaTempMaster)
        
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
                        db.insertOptions(options: options, tableName: "useSaveRipaOptionsTable", personID: person.person_name, key: AppConstants.key)
                        //  }
                    }
                }
                i += 1
            }
        }
    }
    
    
    var newRipaViewModel = NewRipaViewModel()
    
    func getCascadeQuestionUsingId(cascadeQuestArray:[QuestionResult1]?,questionID:Int) -> QuestionResult1{
        var quest:QuestionResult1?
        for question in cascadeQuestArray!{
            if Int(question.id) == questionID{
                quest = question
            }
        }
        return quest!
    }
    
   
    func submitParam(params:UpdateRipa , toSave:Bool, showAlertForSave:Bool){
        let encodedData = try! JSONEncoder().encode(params)
        let jsonString = String(data: encodedData,
                                encoding: .utf8)
        print(jsonString!)
        let dict = convertStringToDictionary(text: jsonString!)
        saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "")
        if toSave == true{
            saveAnsToServer(params:dict!, showAlertForSave: showAlertForSave)
        }
        else{
           submitAnswers(params: dict!)
        }
    }
    
    
    func saveAnsToServer(params:[String:Any], showAlertForSave:Bool) {
        
        var URL:String?
        
        URL = AppConstants.Api.updateRipa
        ApiManager.updateRipa(params: params, methodTyPe: .post, url: URL!, completion: { [self]  (success,message) in
            
            if message == "Success"{
                AppUtility.hideProgress(nil)
                if let json = try? JSON(data: success as! Data){
                    print(json)
                    let errorMsg = json["result"]["serviceError"].stringValue
                    AppUtility.hideProgress(nil)
                    let status = json["result"]["status"].stringValue
                    let statusInt = json["result"]["status"].intValue
                    if status == "11" || statusInt == 11{
                        saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "")
                        AppUtility.showAlertWithProperty("", messageString: errorMsg)
                        return
                    }
                   else if  errorMsg == ""{
                        let activityId = json["result"]["activity_id"].stringValue
                        AppConstants.activityID = activityId
                        db.updateActivityId(key: AppConstants.key, activityId: activityId)
                    }
                    else{
                        
                        let code = json["result"]["status"].intValue
                        DashboardViewModel.showAlertWithProperty("Alert", messageString: errorMsg, code:code )
                        return
                    }
                }
                if showAlertForSave == true{
                    AppUtility.showAlertWithProperty("Saved", messageString: "Your Data has been saved on server!. Activity saved successfully.")
                    self.saveDelegate?.moveToPrevScreen(move: true)
                }
                else{
                    self.saveDelegate?.moveToPrevScreen(move: true)
                }
            }
            else{
                saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "0")
                self.saveDelegate?.moveToPrevScreen(move: true)
            }
            AppUtility.hideProgress(nil)
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            if let errorMessage = message {
                if showAlertForSave == true{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Unable to save on server. Something went wrong")
                    print(errorMessage)
                }
                else{
                    self.saveDelegate?.moveToPrevScreen(move: true)
                }
            }
        }
    }
    
    
    
    func submitAnswers(params:[String:Any]) {
        
        var URL:String?
        
        URL = AppConstants.Api.updateRipa
        ApiManager.updateRipa(params: params, methodTyPe: .post, url: URL!, completion: { [self] (success,message) in

            if message == "Success"{
                if let json = try? JSON(data: success as! Data){
                    print(json)
                    AppUtility.hideProgress(nil)
                    let errorMsg = json["result"]["serviceError"].stringValue
                    let status = json["result"]["status"].stringValue
                    let statusInt = json["result"]["status"].intValue
                    if status == "11" || statusInt == 11{
                        saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "")
                        AppUtility.showAlertWithProperty("", messageString: errorMsg)
                        return
                    }
                   else if  errorMsg == ""{
                        saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "1")
                    }
                    else{
                        saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "")
                        let code = json["result"]["status"].intValue
                        DashboardViewModel.showAlertWithProperty("Alert", messageString: errorMsg, code:code )
                        return
                    }
                }
            }
            else{
                saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "0")
            }
            previewModelDelegate?.setPreviewDelegate(success: ""  ,message:message)
            AppUtility.hideProgress(nil)
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            if let errorMessage = message {
                self.previewModelDelegate?.setPreviewDelegate(success: errorMessage,message:errorMessage)
                AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
            }
        }
    }
    
    
    func createPersonsDict(personArray:[[String: Any]] ,ripaActivity:Ripaactivity ,statusId:String,ripaResponse : RipaResponse) {
        
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
                  
                }
                
                if question.question_code == "21" {
                   
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
                            if obj.question_code == "C25" && obj.question.capitalized == "Block" {
                                obj.response = AppConstants.block
                                obj.order_number = "1"
                            }
                            updateResopnseArray.append(obj)
                        }
                        
                        continue
                    }
                }
                
                if question.question_code == "23"{
                    var ripaRes : RipaResponse = ripaResponse
                    ripaRes.activity_id = AppConstants.activityID
                    ripaRes.order_number = "19"
                    ripaRes.question_id = "44"
                    ripaRes.main_question_id = "44"
                    ripaRes.question_code = question.question_code
                    if ripaRes.question.count == 0 {
                        let pAtt = UserDefaults.standard.string(forKey: "physical_attribute")
                        ripaRes.physical_attribute = pAtt ?? ""
                        ripaRes.question = "Type of Assignment of Officer"
                        ripaRes.option_id = UserDefaults.standard.string(forKey: "officeAssignmentId") ?? ""
                    }
                    updateResopnseArray.append(ripaRes)
                    continue
                }
            
                let isVisible = UserDefaults.standard.integer(forKey: "isVisible")
                
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
             
                if question.question_code == "T1"{
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
                       // ripaRes.order_number = dict["order_number"] as! String
                        ripaRes.order_number = "100"
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
                        
                        if obj.question_code == "C9" {
                            obj.cascade_ques_id = "26"
                        }
                        
                        if obj.question_code == "C9" && obj.question_id == "108" {
                            obj.question_id = "52"
                            obj.option_id = "114"
                          //  obj.cascade_option_id = "1226"
                        }
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                if question.question_code == "5"{
                    address.isSelected = true
                    address.main_question_id = question.id
                    address.ripa_id = question.id
                    var respovalue =  address.option_value
                    respovalue = respovalue.replacingOccurrences(of: "/", with: "&")
                    if AppConstants.LocTypeIndex == 6,let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
                        respovalue = String(format: "%@,%@", latString, longString)
                    }
                    else if viewType == "UseSaveRipa" && AppConstants.LocTypeIndex == 1 {
                        respovalue = String(format: "%@ BLK & %@", AppConstants.block, AppConstants.street)
                    }
                    
                    var obj = RipaResponse(question_id: question.id, response: respovalue, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: address.physical_attribute, key: AppConstants.key, personId: String(i) , description: address.optionDescription, question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "0", cascade_option_id: "0", main_question_id: question.id, supervisorId: supervisorId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, isSelected: "")
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
                        
                        if question.question_code == "C25" {
                            print(question.question_code)
                        }
                        
                        if question.order_number == "100" {
                            print(question.question_code)
                        }
                        
                        if updateResopnseArray.count > 35 {
                            
                        }
                        
                       
                        if opt.ripa_id == question.id || (question.question_code == "C6" && opt.cascade_ripa_id == question.id) || (question.question_code == "5" && opt.ripa_id == "118") || (question.question_code == "5" && opt.ripa_id == "122")||(question.question_code == "5" && opt.ripa_id == "26") || (question.question_code == "21" && opt.main_question_id == "39" && opt.isSelected == true) || (question.question_code == "C30" && opt.ripa_id == "67") && (question.question_code == "C5" && opt.mainQuestId == "14") || (question.question_code == "C1" && opt.mainQuestId == "15" && opt.option_id == "93") || (question.question_code == "17" && opt.ripa_id == "25") || (question.question_code == "T7" && opt.ripa_id == "32") || (question.question_code == "17" && opt.ripa_id == "84") || (question.question_code == "14" && opt.ripa_id == "46") || (question.question_code == "21" && opt.ripa_id == "50" && opt.isSelected == true) || question.question_code == "14" && opt.ripa_id == "70" || question.question_code == "14" && opt.ripa_id == "71" || (question.question_code == "14" && opt.ripa_id == "72") || (question.question_code == "C55" && opt.ripa_id == "21") || (question.question_code == "14" && opt.ripa_id == "17") || (question.question_code == "14" && opt.ripa_id == "28") || (question.question_code == "21" && opt.ripa_id == "75" && opt.mainQuestId == "39"){
                          
                       
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
                       
                            if obj?.question_code == "C9" {
                                print("Isperson")
                            }
                                
                            
                            if obj?.question_code == "C24"{
                                obj?.option_id = "1225"
                            }
                            
                            if obj?.main_question_id == "39" || obj?.question_id == "39"{
                              if obj?.question_code == "C40" || opt.ripa_id == "75"{
                                    obj?.question = "Verbal Warning"
                                    obj?.question_id = opt.ripa_id
                                    obj?.order_number = "17"
                                    obj?.main_question_id = "39"
                                }
                                else if obj?.question_code == "C41" || opt.ripa_id == "76" {
                                    obj?.question = "Written Warning"
                                    obj?.question_id = opt.ripa_id
                                    obj?.order_number = "17"
                                }
                                else if obj?.question_code == "C15" || opt.ripa_id == "40" {
                                    obj?.question = "Citation for infraction: Code"
                                    obj?.question_id = opt.ripa_id
                                    obj?.order_number = "17"
                                }
                                else if obj?.question_code == "C17" || opt.ripa_id == "40" {
                                    obj?.question = "Custodial arrest without warrant: Code/ordinance cited"
                                    obj?.question_id = opt.ripa_id
                                    obj?.physical_attribute = "6"
                                }
                                else if obj?.question_code == "C17" || opt.ripa_id == "42" {
                                    obj?.question = "Custodial arrest without warrant: Code"
                                    obj?.question_id = opt.ripa_id
                                   // obj?.question_code = "C17"
                                }
                                else if obj?.question_code == "C16" || opt.ripa_id == "51" {
                                    obj?.question = "In-field cite and release: Code/ordinance cited"
                                    obj?.response = "In-field cite and release: Code"
                                    obj?.question_id = opt.ripa_id
                                    obj?.physical_attribute = "4"
                                }
                                else if obj?.question_code == "C16" || opt.ripa_id == "41" {
                                    obj?.question = "In-field cite and release: Code"
                                    obj?.question_id = opt.ripa_id
                                    obj?.option_id = "225"
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
                                obj?.order_number = "2"
                            }
                            
                            
                            if obj?.isSelected == "" &&  obj?.question_code == "C10" &&  obj?.question_id == "27" {
                                continue
                            }
                            
                            if obj?.isSelected == "" &&  obj?.question_code == "C10" &&  obj?.cascade_ques_id == "27" && AppConstants.isSchoolSelected != "Yes"{
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
                                obj?.order_number = "2"
                            }
                            
                            if obj?.question_code == "C44"{
                                obj?.question_id = "79"
                                obj?.order_number = "2"
                                obj?.main_question_id = "79"
                            }
                            
                            if obj?.question_code == "C43"{
                                obj?.question_code = "T5"
                                obj?.order_number = "2"
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
                                    obj?.response = "\(latString),\(longString)"
                                    obj?.order_number = "1"
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
                                obj?.question_id = "123"
                                obj?.main_question_id = "21"
                                obj?.physical_attribute = ""
                                obj?.response = AppConstants.LocTypeDescription
                                obj?.order_number = "1"
                            }
                            
                            if obj?.question_code == "C53" && obj?.cascade_option_id == "1408" && question.id == "21"{
                                obj?.question = "Geographic Coordinates"
                                obj?.question_id = "119"
                               // obj?.cascade_ques_id = ""
                                obj?.physical_attribute = ""
                                obj?.cascade_option_id = ""
                                obj?.order_number = "1"
                                if let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
                                   
                                    obj?.response = "\(latString),\(longString)"
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
                            
                            if question.question_code == "14" && opt.ripa_id == "70" && opt.option_id == "1275"{
                                obj?.question = "Probable cause to arrest or search"
                                obj?.response = "Specific Code"
                                obj?.physical_attribute = "9"
                                obj?.question_id = "70"
                             }
                            else if question.question_code == "14" && opt.ripa_id == "70" && opt.option_id == "1276"{
                                obj?.question = "Probable cause to arrest or search"
                                obj?.response = "Basis"
                                obj?.physical_attribute = "9"
                                obj?.question_id = "70"
                             }
                            else if question.question_code == "14" && opt.ripa_id == "71"{
                                 obj?.question = "Specific Code"
                                 obj?.question_code = "C36"
                                 obj?.question_id = opt.ripa_id
                                 obj?.option_id = "1275"
                             }
                            else if question.question_code == "14" && opt.ripa_id == "72"{
                                 obj?.question = "Basis"
                                 obj?.question_code = "C37"
                                 obj?.question_id = opt.ripa_id
                             }
                            else if question.question_code == "14" && opt.ripa_id == "28"{
                                 obj?.question = "Specific Code"
                                 obj?.question_code = "C11"
                                 obj?.question_id = opt.ripa_id
                             }
                            else if obj?.question_id == "14" && obj?.question_code == "C4" && obj?.cascade_ques_id == "18"{
                                obj?.question_id = "17"
                                 obj?.question = "Reasonable suspicion that person was engaged in criminal activity"
                             }
                            else if obj?.question_id == "14" && obj?.question_code == "C11" && obj?.cascade_ques_id == "28"{
                                 obj?.question_id = "17"
                                 obj?.question = "Reasonable suspicion that person was engaged in criminal activity"
                             }
                            
                            if obj?.question_code == "C27" || obj?.question_id == "62"{
                                obj?.response = "Yes"
                                obj?.option_id = "1234"
                            }
                            
                            if obj!.question == "Location Type"{
                                obj!.question_code = "C52"
                                obj?.main_question_id = "21"
                                obj?.order_number = "1"
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
                            if obj!.question == "Closest Intersection" && AppConstants.LocTypeIndex != 2{
                                continue
                            }
                            
                            let containsInter = updateResopnseArray.contains(where: {
                                $0.response.capitalized == "Closest Intersection" && $0.question.capitalized == "Location"
                            })
                            
                            if obj!.response == "Closest Intersection" && obj!.question == "Location" && containsInter == true{
                                continue
                            }
                            if obj!.response == "Block Number and Street Name" && obj!.question == "Location"{
                                continue
                            }
                            if obj!.question == "Geographic Coordinates" && (obj!.cascade_ques_id != "0" || obj!.cascade_ques_id != "0"){
                             //   continue
                            }
                    
                            if obj?.question_code == "C6"{
                                obj?.cascade_ques_id = "22"
                            }
                            
                                if question.question_code == "C54" && question.question == "Block Number and Street Name" {
                                    obj?.order_number = "1"
                                    obj?.response = "Block"
                                    obj?.cascade_ques_id = "53"
                                    obj?.option_id = "1409"
                                    obj?.cascade_option_id = "1229"
                                    let streetObj = self.createBlockObject(data: obj!)
                                    let contains = updateResopnseArray.contains(where: {
                                        $0.question == "Block"
                                    })
                                    
                                    if contains == false {
                                        if AppConstants.LocTypeIndex != 1 {
                                            continue
                                        }
                                        updateResopnseArray.append(streetObj!)
                                    }
                                    else {
                                        obj?.response = "Block"
                                    }
                                    if AppConstants.LocTypeIndex != 1 {
                                        continue
                                    }
                                    updateResopnseArray.append(obj!)
                                }
                             else  if question.question_code == "C54" && question.question == "Block Number and Street Name" {
                                 obj?.order_number = "1"
                                let contains = updateResopnseArray.contains(where: {
                                    $0.response == "Block"
                                })
                                if contains == false {
                                    obj?.response = "Block"
                                 }
                                 obj?.option_id = "1409"
                                 obj?.cascade_option_id = "1229"
                                 let containsResponse = updateResopnseArray.contains(where: {
                                     $0.response == "Block"
                                 })
                                 if AppConstants.LocTypeIndex != 1 || containsResponse == true {
                                     continue
                                 }
                                 updateResopnseArray.append(obj!)
                               }
                            
                         
                             if question.question_code == "C54" && question.question == "Block Number and Street Name" {
                                  obj?.order_number = "1"
                                  obj?.cascade_ques_id = "23"
                                  obj?.option_id = "1409"
                                  obj?.cascade_option_id = "109"
                                  let streetObj = self.createStreetObject(data: obj!)
                                  let contains = updateResopnseArray.contains(where: {
                                      $0.question == "Street"
                                  })
                                  if contains == false {
                                      obj?.cascade_option_id = "109"
                                      if AppConstants.LocTypeIndex != 1 {
                                          continue
                                      }
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
                                 obj?.order_number = "1"
                                 obj?.option_id = "1409"
                                 obj?.cascade_option_id = "109"
                                 let containsStreet = updateResopnseArray.contains(where: {
                                     $0.response == "Street"
                                 })
                                 if AppConstants.LocTypeIndex != 1 || containsStreet == true {
                                     continue
                                 }
                                 updateResopnseArray.append(obj!)
                             }
                            
                            if question.question_code == "C55" && question.question == "Closest Intersection" && AppConstants.LocTypeIndex == 2 {
                                print(updateResopnseArray.count)
                                obj?.cascade_option_id = "1231"
                                obj?.cascade_ques_id = "54"
                                obj?.order_number = "1"
                                obj?.response = "First Intersection"
                                obj?.option_id = "1410"
                                obj?.question_code = question.question_code
                                 let interObj = self.createFirstIntersectionObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "First Intersection"
                                 })
                                 if contains == false && (opt.isSelected == true || AppConstants.LocTypeIndex == 2){
                                     if AppConstants.LocTypeIndex != 2 {
                                         continue
                                     }
                                     updateResopnseArray.append(interObj!)
                                 }
                                 else {
                                     obj?.response = "First Intersection"
                                 }
                               }
                            
                            if question.question_code == "C55" && question.question == "Closest Intersection" && AppConstants.LocTypeIndex == 2{
                                var interObj = self.createSecondIntersectionObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "Second Intersection"
                                 })
                                 if contains == false && (opt.isSelected == true || AppConstants.LocTypeIndex == 2) {
                                     if AppConstants.LocTypeIndex != 2 {
                                         continue
                                     }
                                     interObj?.order_number = "1"
                                     updateResopnseArray.append(interObj!)
                                 }
                                 else {
                                     obj?.cascade_option_id = "1404"
                                     obj?.cascade_ques_id = "115"
                                     obj?.option_id = "1410"
                                     obj?.response = "Second Intersection"
                                     obj?.order_number = "1"
                                     let containsRes = updateResopnseArray.contains(where: {
                                         $0.response == "Second Intersection"
                                     })
                                     if containsRes == true {
                                         continue
                                     }
                                 }
                               }
                            
                            if question.question_code == "C56" && question.question == "Highway and Closest Highway Exit" {
                                obj?.cascade_option_id = "1405"
                                obj?.cascade_ques_id = "116"
                                obj?.response = "Highway"
                                obj?.option_id = "1411"
                                obj?.order_number = "1"
                                let highwayObj = self.createHighwayObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "Highway"
                                 })
                                 if contains == false && opt.isSelected == true{
                                     if AppConstants.LocTypeIndex != 3 {
                                         continue
                                     }
                                     updateResopnseArray.append(highwayObj!)
                                 }
                                 else {
                                     obj?.response = "Highway"
                                 }
                               }
                            if question.question_code == "C56" && question.question == "Highway and Closest Highway Exit" {
                               //  obj?.cascade_ques_id = "23"
                                obj?.option_id = "1411"
                                obj?.order_number = "1"
                                var highwayObj = self.createClosetHighwayObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "Closest Highway"
                                 })
                                 if contains == false && opt.isSelected == true {
                                     if AppConstants.LocTypeIndex != 3 {
                                         continue
                                     }
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
                                         if AppConstants.LocTypeIndex != 3 {
                                             continue
                                         }
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
                                         if AppConstants.LocTypeIndex != 3 {
                                             continue
                                         }
                                         updateResopnseArray.append(obj!)
                                     }
                                 }
                               }
                            if obj?.question_code == "T7" {
                                
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
                            
                            if (obj?.question_id == "25" || obj?.main_question_id == "25") && (obj?.cascade_option_id == "1304" || obj?.cascade_option_id == "1305" || obj?.cascade_option_id == "1306") {
                                obj?.question = "Consent given"
                                obj?.question_code = "C47"
                                obj?.question_id = "84"
                                obj?.order_number = "13"
                                obj?.main_question_id = "25"
                                if options[0].question_code_for_cascading_id.count > 0 {
                                    obj?.question_code = options[0].question_code_for_cascading_id
                                }
                            }
                            
                            
                          //  print(objjj)
                            if exist == true && index != nil && obj?.question_code != "C52" && obj?.question_code != "C43" && obj?.question_code != "14" && obj?.main_question_id != "21" && obj?.question_code != "C32" && obj?.question_code != "C34" && obj?.main_question_id != "14" && obj?.question_code != "T8" && obj?.question_code != "T7" && obj?.question_code != "18"  && obj?.question_code != "21" && obj?.question_code != "17" && obj?.question_code != "19" && obj?.question_code != "20" && obj?.question_code != "C13" && obj?.question_code != "C14" && obj?.question_code != "C47" && obj?.question_code != "T4" {
                                
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
                                else if obj?.question_code == "C47" && updateResopnseArray[index!].question_code == "17" && obj?.question_id != "84"{
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
                                    obj?.order_number = "2"
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
                                if checkExist == true && obj?.question_code != "C29" && obj?.question_code != "C30" && obj?.question_code != "C28" && obj?.question_code != "C33" && obj?.question_code != "C34" && obj?.question_code != "C32" && obj?.question_code != "C43" && obj?.question_code != "C5" && obj?.question_code != "C2"{
                                    continue
                                }
                                
                                let eduCodeExist = self.updateResopnseArray.contains(where: {
                                    $0.option_id == "222" && $0.question_code == "C19"
                                })
                                
                                if eduCodeExist == true && obj?.question_code == "C19" {
                                    continue
                                }
                                
                                if self.updateResopnseArray.contains(where: {$0.cascade_ques_id == "71" && $0.question_code == "C36" && $0.response.lowercased() == obj?.response.lowercased()}) {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C37" && $0.response.lowercased() == obj?.response.lowercased()}) && obj?.question_code != "T4" {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C36" && $0.response.lowercased() == obj?.response.lowercased() && obj?.question_code != "C17"}) {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C37" && $0.cascade_ques_id == "72" && $0.response.lowercased() == obj?.response.lowercased()}) {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C11" && $0.question_id == "28" && $0.response.lowercased() == obj?.response.lowercased()}) {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C4" && $0.question_id == "14" && $0.response.lowercased() == obj?.response.lowercased()}) {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C11" && $0.question_id == "14" && $0.cascade_ques_id == "14"}){
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C11" && $0.question_id == "14" && $0.cascade_ques_id == "14"}){
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C11" && $0.cascade_ques_id == "28" && $0.main_question_id == "14" && $0.response.lowercased() == obj?.response.lowercased()}){
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C24" && $0.cascade_ques_id == "52" && $0.main_question_id == "21" }){
                                   // continue
                                }
                                
                                if question.question_code == "C20" && obj?.question_code == "C20" && obj?.question.capitalized == "Education Code" {
                                    obj?.description = "EDU_sec_CD"
                                    if let responseStr = obj?.response.lowercased(),responseStr.contains("select subsection") {
                                        obj?.description = "EDU_subDiv_CD"
                                    }
                                }
                                if obj?.question_code == "C5" && obj?.cascade_ques_id == "20" {
                                    let checkContain = updateResopnseArray.contains(where: {$0.response.uppercased() == "TYPE OF VIOLATION"})
                                    if checkContain ==  false {
                                        updateResopnseArray.append(self.createViolationObject())
                                    }
                                }
                                if obj?.question.capitalized == "K-12 School?",obj?.question_code == "C24",opt.isSelected == false{
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
            updateResopnseArray = self.removeZeroOptionIdFromAllQuestions(createdArr: updateResopnseArray)
            
            let isStu = updateResopnseArray.contains(where: {
                $0.question_code == "C27"
            })
            if isStu == false{
                updateResopnseArray.append(self.isPersonObject())
            }
            
            let isStreet = updateResopnseArray.contains(where: {
                 $0.question.capitalized == "Street"
            })
            if isStreet == false && AppConstants.LocTypeIndex == 1{
                updateResopnseArray.append(self.createStreetDataObject()!)
            }
            
            let isStreetObj = updateResopnseArray.contains(where: {
                 $0.question.capitalized == "Block Number and Street Name" && $0.response.capitalized == "Street"
            })
            if isStreetObj == false && AppConstants.LocTypeIndex == 1{
                updateResopnseArray.append(self.addStreetObject())
            }
            let isBlockObj = updateResopnseArray.contains(where: {
                 $0.question.capitalized == "Block Number and Street Name" && $0.response.capitalized == "Block"
            })
            if isBlockObj == false && AppConstants.LocTypeIndex == 1{
                updateResopnseArray.append(self.addBlockObject())
            }
            
            
            if AppConstants.LocTypeIndex == 2 {
                let contains = updateResopnseArray.contains(where: {
                    $0.response == "Second Intersection"
                })
                if contains == false {
                    updateResopnseArray.append(self.addSecondIntersectionObject())
                }
            }
            
            let dupArr = updateResopnseArray.filter({$0.question_code == "C24" && $0.cascade_ques_id == "52"})
            if dupArr.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C24" && $0.cascade_ques_id == "52"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            if let indexN = updateResopnseArray.firstIndex(where: {$0.question_code == "T7" && $0.cascade_option_id == "146" && $0.question_id == "106"}) {
                updateResopnseArray.remove(at: indexN)
            }
            
            let dupStreet = updateResopnseArray.filter({$0.question_code == "C54" && $0.cascade_ques_id == "23"})
            if dupStreet.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C54" && $0.cascade_ques_id == "23"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            let dupBlk = updateResopnseArray.filter({$0.question_code == "C54" && $0.cascade_ques_id == "53"})
            if dupBlk.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C54" && $0.cascade_ques_id == "53"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            let dupProbable1 = updateResopnseArray.filter({$0.question_code == "C36" && $0.cascade_ques_id == "71"})
            if dupProbable1.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C36" && $0.cascade_ques_id == "71"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            let dupProbable2 = updateResopnseArray.filter({$0.question_code == "C37" && $0.cascade_ques_id == "72"})
            if dupProbable2.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C37" && $0.cascade_ques_id == "72"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            let dupVioType = updateResopnseArray.filter({$0.question_code == "C2" && $0.response == "Type Of Violation"})
            if dupVioType.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C2" && $0.response == "Type Of Violation"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            if  let indexVio = updateResopnseArray.firstIndex(where: {$0.question_code == "C2" && $0.response.capitalized == "Specific Code" && $0.cascade_ques_id == "16" && $0.main_question_id == "14"}) {
                updateResopnseArray.remove(at: indexVio)
            }
         
            
            let dupConsent = updateResopnseArray.filter({$0.question_code == "C47" && $0.main_question_id == "25" && $0.question.capitalized == "Consent Given"})
            if dupConsent.count > 1{
                let indexC = updateResopnseArray.lastIndex(where: {$0.question_code == "C47" && $0.main_question_id == "25" && $0.question.capitalized == "Consent Given"})!
                updateResopnseArray.remove(at: indexC)
            }
            
          
            if let indexL = updateResopnseArray.lastIndex(where: {$0.question_code == "C55" && $0.main_question_id == "108" && $0.question.capitalized == "Location"}){
                updateResopnseArray.remove(at: indexL)
            }
            
            let dupReaso = updateResopnseArray.filter({$0.cascade_option_id == "98" && $0.cascade_ques_id == "28" && $0.question_code == "C11"})
            if dupReaso.count > 1{
                let indexC = updateResopnseArray.lastIndex(where: {$0.cascade_option_id == "98" && $0.cascade_ques_id == "28" && $0.question_code == "C11"})!
                updateResopnseArray.remove(at: indexC)
            }
            
            let dupNonForce = updateResopnseArray.filter({$0.response == "Asked for consent to search property" && $0.question_code == "T7"})
            if dupNonForce.count > 0{
                let indexF = updateResopnseArray.lastIndex(where: {$0.response == "Asked for consent to search property" && $0.question_code == "T7"})!
                updateResopnseArray.remove(at: indexF)
            }
            
            if let indx = updateResopnseArray.firstIndex(where: {$0.question_code == "14" && $0.cascade_ques_id == "47"}) {
                updateResopnseArray.remove(at: indx)
            }
            
            if let indx = updateResopnseArray.firstIndex(where: {$0.question_code == "C20" && $0.question_id == "47" && $0.main_question_id == "14" && $0.physical_attribute == "1"}) {
                updateResopnseArray[indx].question = "Education Sub Code"
            }
        //   let arr1 = updateResopnseArray
            updateResopnseArray = updateResopnseArray.sorted(by: {Int($0.order_number) ?? 0 < Int($1.order_number) ?? 0 })
            updateResopnseArray = setOrderOfAllQuestions(createdArr: updateResopnseArray)
      //      let arr2 = updateResopnseArray
            let obj = RipaPerson(CreatedBy: String(userId!), person_name: "P"+String(i), key: AppConstants.key,date: AppConstants.date,time: AppConstants.time,duration: AppConstants.duration, ripa_response :  updateResopnseArray.sorted(by: {Int($0.order_number) ?? 0 < Int($1.order_number) ?? 0 }))
           
            ripaPersonsArray.append(obj)
            i += 1
//            let arr = ripaPersonsArray
//            print(arr)
        }
        ripaActivityDict(statusId: statusId)
    }
    

    
    func createUserSettingPersonsDict(personArray:[[String: Any]] ,ripaActivity:Ripaactivity ,statusId:String,ripaResponse : RipaResponse) {
       
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
                  
                }
                
                if question.question_code == "21" {
                   
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
                            if obj.question_code == "C25" && obj.question.capitalized == "Block" {
                                obj.response = AppConstants.block
                                obj.order_number = "1"
                            }
                            updateResopnseArray.append(obj)
                        }
                        
                        continue
                    }
                }
                
                if question.question_code == "23"{
                    var ripaRes : RipaResponse = ripaResponse
                    ripaRes.activity_id = AppConstants.activityID
                    ripaRes.order_number = "19"
                    ripaRes.question_id = "44"
                    ripaRes.main_question_id = "44"
                    ripaRes.question_code = question.question_code
                    if ripaRes.question.count == 0 {
                        let pAtt = UserDefaults.standard.string(forKey: "physical_attribute")
                        ripaRes.physical_attribute = pAtt ?? ""
                        ripaRes.question = "Type of Assignment of Officer"
                        ripaRes.option_id = UserDefaults.standard.string(forKey: "officeAssignmentId") ?? ""
                    }
                    updateResopnseArray.append(ripaRes)
                    continue
                }
            
                let isVisible = UserDefaults.standard.integer(forKey: "isVisible")
                
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
             
                if question.question_code == "T1"{
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
                       // ripaRes.order_number = dict["order_number"] as! String
                        ripaRes.order_number = "100"
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
                        
                        if obj.question_code == "C9" {
                            obj.cascade_ques_id = "26"
                        }
                        
                        if obj.question_code == "C9" && obj.question_id == "108" {
                            obj.question_id = "52"
                            obj.option_id = "114"
                          //  obj.cascade_option_id = "1226"
                        }
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                if question.question_code == "5"{
                    address.isSelected = true
                    address.main_question_id = question.id
                    address.ripa_id = question.id
                    var respovalue =  address.option_value
                    respovalue = respovalue.replacingOccurrences(of: "/", with: "&")
                    if AppConstants.LocTypeIndex == 6,let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
                        respovalue = String(format: "%@,%@", latString, longString)
                    }
                    else if viewType == "UseSaveRipa" && AppConstants.LocTypeIndex == 1 {
                        respovalue = String(format: "%@ BLK & %@", AppConstants.block, AppConstants.street)
                    }
                    
                    var obj = RipaResponse(question_id: question.id, response: respovalue, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: address.physical_attribute, key: AppConstants.key, personId: String(i) , description: address.optionDescription, question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "0", cascade_option_id: "0", main_question_id: question.id, supervisorId: supervisorId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, isSelected: "")
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
                        
                        if question.question_code == "C25" {
                            print(question.question_code)
                        }
                        
                        if question.order_number == "100" {
                            print(question.question_code)
                        }
                        
                        if updateResopnseArray.count > 35 {
                            
                        }
                        
                       
                        if opt.ripa_id == question.id || (question.question_code == "C6" && opt.cascade_ripa_id == question.id) || (question.question_code == "5" && opt.ripa_id == "118") || (question.question_code == "5" && opt.ripa_id == "122")||(question.question_code == "5" && opt.ripa_id == "26") || (question.question_code == "21" && opt.main_question_id == "39" && opt.isSelected == true) || (question.question_code == "C30" && opt.ripa_id == "67") && (question.question_code == "C5" && opt.mainQuestId == "14") || (question.question_code == "C1" && opt.mainQuestId == "15" && opt.option_id == "93") || (question.question_code == "17" && opt.ripa_id == "25") || (question.question_code == "T7" && opt.ripa_id == "32") || (question.question_code == "17" && opt.ripa_id == "84") || (question.question_code == "14" && opt.ripa_id == "46") || (question.question_code == "21" && opt.ripa_id == "50" && opt.isSelected == true) || question.question_code == "14" && opt.ripa_id == "70" || question.question_code == "14" && opt.ripa_id == "71" || (question.question_code == "14" && opt.ripa_id == "72") || (question.question_code == "C55" && opt.ripa_id == "21") || (question.question_code == "14" && opt.ripa_id == "17") || (question.question_code == "14" && opt.ripa_id == "28") || (question.question_code == "21" && opt.ripa_id == "75" && opt.mainQuestId == "39"){
                          
                       
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
                       
                            if obj?.question_code == "C9" {
                                print("Isperson")
                            }
                                
                            
                            if obj?.question_code == "C24"{
                                obj?.option_id = "1225"
                            }
                            
                            if obj?.main_question_id == "39" || obj?.question_id == "39"{
                              if obj?.question_code == "C40" || opt.ripa_id == "75"{
                                    obj?.question = "Verbal Warning"
                                    obj?.question_id = opt.ripa_id
                                    obj?.order_number = "17"
                                    obj?.main_question_id = "39"
                                }
                                else if obj?.question_code == "C41" || opt.ripa_id == "76" {
                                    obj?.question = "Written Warning"
                                    obj?.question_id = opt.ripa_id
                                    obj?.order_number = "17"
                                }
                                else if obj?.question_code == "C15" || opt.ripa_id == "40" {
                                    obj?.question = "Citation for infraction: Code"
                                    obj?.question_id = opt.ripa_id
                                    obj?.order_number = "17"
                                }
                                else if obj?.question_code == "C17" || opt.ripa_id == "40" {
                                    obj?.question = "Custodial arrest without warrant: Code/ordinance cited"
                                    obj?.question_id = opt.ripa_id
                                    obj?.physical_attribute = "6"
                                }
                                else if obj?.question_code == "C17" || opt.ripa_id == "42" {
                                    obj?.question = "Custodial arrest without warrant: Code"
                                    obj?.question_id = opt.ripa_id
                                   // obj?.question_code = "C17"
                                }
                                else if obj?.question_code == "C16" || opt.ripa_id == "51" {
                                    obj?.question = "In-field cite and release: Code/ordinance cited"
                                    obj?.response = "In-field cite and release: Code"
                                    obj?.question_id = opt.ripa_id
                                    obj?.physical_attribute = "4"
                                }
                                else if obj?.question_code == "C16" || opt.ripa_id == "41" {
                                    obj?.question = "In-field cite and release: Code"
                                    obj?.question_id = opt.ripa_id
                                    obj?.option_id = "225"
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
                                obj!.order_number = "2"
                            }
                            
                            
                            if obj?.isSelected == "" &&  obj?.question_code == "C10" &&  obj?.question_id == "27" {
                                continue
                            }
                            
                            if obj?.isSelected == "" &&  obj?.question_code == "C10" &&  obj?.cascade_ques_id == "27" && AppConstants.isSchoolSelected != "Yes"{
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
                                obj?.order_number = "2"
                            }
                            
                            if obj?.question_code == "C44"{
                                obj?.question_id = "79"
                                obj?.main_question_id = "79"
                                obj?.order_number = "2"
                            }
                            
                            if obj?.question_code == "C43"{
                                obj?.question_code = "T5"
                                obj?.order_number = "2"
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
                                    obj?.response = "\(latString),\(longString)"
                                    obj?.order_number = "1"
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
                                obj?.question_id = "123"
                                obj?.main_question_id = "21"
                                obj?.physical_attribute = ""
                                obj?.response = AppConstants.LocTypeDescription
                                obj?.order_number = "1"
                            }
                            
                            if obj?.question_code == "C53" && obj?.cascade_option_id == "1408" && question.id == "21"{
                                obj?.question = "Geographic Coordinates"
                                obj?.question_id = "119"
                               // obj?.cascade_ques_id = ""
                                obj?.physical_attribute = ""
                                obj?.cascade_option_id = ""
                                obj?.order_number = "1"
                                if let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
                                   
                                    obj?.response = "\(latString),\(longString)"
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
                            
                            if question.question_code == "14" && opt.ripa_id == "70" && opt.option_id == "1275"{
                                obj?.question = "Probable cause to arrest or search"
                                obj?.response = "Specific Code"
                                obj?.physical_attribute = "9"
                                obj?.question_id = "70"
                             }
                            else if question.question_code == "14" && opt.ripa_id == "70" && opt.option_id == "1276"{
                                obj?.question = "Probable cause to arrest or search"
                                obj?.response = "Basis"
                                obj?.physical_attribute = "9"
                                obj?.question_id = "70"
                             }
                            else if question.question_code == "14" && opt.ripa_id == "71"{
                                 obj?.question = "Specific Code"
                                 obj?.question_code = "C36"
                                 obj?.question_id = opt.ripa_id
                                 obj?.option_id = "1275"
                             }
                            else if question.question_code == "14" && opt.ripa_id == "72"{
                                 obj?.question = "Basis"
                                 obj?.question_code = "C37"
                                 obj?.question_id = opt.ripa_id
                             }
                            else if question.question_code == "14" && opt.ripa_id == "28"{
                                 obj?.question = "Specific Code"
                                 obj?.question_code = "C11"
                                 obj?.question_id = opt.ripa_id
                             }
                            else if obj?.question_id == "14" && obj?.question_code == "C4" && obj?.cascade_ques_id == "18"{
                                obj?.question_id = "17"
                                 obj?.question = "Reasonable suspicion that person was engaged in criminal activity"
                             }
                            else if obj?.question_id == "14" && obj?.question_code == "C11" && obj?.cascade_ques_id == "28"{
                                 obj?.question_id = "17"
                                 obj?.question = "Reasonable suspicion that person was engaged in criminal activity"
                             }
                            
                            if obj?.question_code == "C27" || obj?.question_id == "62"{
                                obj?.response = "Yes"
                                obj?.option_id = "1234"
                            }
                            
                            if obj!.question == "Location Type"{
                                obj!.question_code = "C52"
                                obj?.main_question_id = "21"
                                obj?.order_number = "1"
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
                            if obj!.question == "Closest Intersection" && AppConstants.LocTypeIndex != 2{
                                continue
                            }
                            
                            let containsInter = updateResopnseArray.contains(where: {
                                $0.response.capitalized == "Closest Intersection" && $0.question.capitalized == "Location"
                            })
                            
                            if obj!.response == "Closest Intersection" && obj!.question == "Location" && containsInter == true{
                                continue
                            }
                            if obj!.response == "Block Number and Street Name" && obj!.question == "Location"{
                                continue
                            }
                            if obj!.question == "Geographic Coordinates" && (obj!.cascade_ques_id != "0" || obj!.cascade_ques_id != "0"){
                             //   continue
                            }
                    
                            if obj?.question_code == "C6"{
                                obj?.cascade_ques_id = "22"
                            }
                            
                                if question.question_code == "C54" && question.question == "Block Number and Street Name" {
                                    obj?.order_number = "1"
                                    obj?.response = "Block"
                                    obj?.cascade_ques_id = "53"
                                    obj?.option_id = "1409"
                                    obj?.cascade_option_id = "1229"
                                    let streetObj = self.createBlockObject(data: obj!)
                                    let contains = updateResopnseArray.contains(where: {
                                        $0.question == "Block"
                                    })
                                    
                                    if contains == false {
                                        if AppConstants.LocTypeIndex != 1 {
                                            continue
                                        }
                                        updateResopnseArray.append(streetObj!)
                                    }
                                    else {
                                        obj?.response = "Block"
                                    }
                                    if AppConstants.LocTypeIndex != 1 {
                                        continue
                                    }
                                    updateResopnseArray.append(obj!)
                                }
                             else  if question.question_code == "C54" && question.question == "Block Number and Street Name" {
                                 obj?.order_number = "1"
                                let contains = updateResopnseArray.contains(where: {
                                    $0.response == "Block"
                                })
                                if contains == false {
                                    obj?.response = "Block"
                                 }
                                 obj?.option_id = "1409"
                                 obj?.cascade_option_id = "1229"
                                 let containsResponse = updateResopnseArray.contains(where: {
                                     $0.response == "Block"
                                 })
                                 if AppConstants.LocTypeIndex != 1 || containsResponse == true {
                                     continue
                                 }
                                 updateResopnseArray.append(obj!)
                               }
                            
                         
                             if question.question_code == "C54" && question.question == "Block Number and Street Name" {
                                  obj?.order_number = "1"
                                  obj?.cascade_ques_id = "23"
                                  obj?.option_id = "1409"
                                  obj?.cascade_option_id = "109"
                                  let streetObj = self.createStreetObject(data: obj!)
                                  let contains = updateResopnseArray.contains(where: {
                                      $0.question == "Street"
                                  })
                                  if contains == false {
                                      obj?.cascade_option_id = "109"
                                      if AppConstants.LocTypeIndex != 1 {
                                          continue
                                      }
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
                                 obj?.order_number = "1"
                                 obj?.option_id = "1409"
                                 obj?.cascade_option_id = "109"
                                 let containsStreet = updateResopnseArray.contains(where: {
                                     $0.response == "Street"
                                 })
                                 if AppConstants.LocTypeIndex != 1 || containsStreet == true {
                                     continue
                                 }
                                 updateResopnseArray.append(obj!)
                             }
                            
                            if question.question_code == "C55" && question.question == "Closest Intersection" && AppConstants.LocTypeIndex == 2 {
                                print(updateResopnseArray.count)
                                obj?.cascade_option_id = "1231"
                                obj?.cascade_ques_id = "54"
                                obj?.order_number = "1"
                                obj?.response = "First Intersection"
                                obj?.option_id = "1410"
                                obj?.question_code = question.question_code
                                 let interObj = self.createFirstIntersectionObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "First Intersection"
                                 })
                                 if contains == false && (opt.isSelected == true || AppConstants.LocTypeIndex == 2){
                                     if AppConstants.LocTypeIndex != 2 {
                                         continue
                                     }
                                     updateResopnseArray.append(interObj!)
                                 }
                                 else {
                                     obj?.response = "First Intersection"
                                 }
                               }
                            
                            if question.question_code == "C55" && question.question == "Closest Intersection" && AppConstants.LocTypeIndex == 2{
                                var interObj = self.createSecondIntersectionObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "Second Intersection"
                                 })
                                 if contains == false && (opt.isSelected == true || AppConstants.LocTypeIndex == 2) {
                                     if AppConstants.LocTypeIndex != 2 {
                                         continue
                                     }
                                     interObj?.order_number = "1"
                                     updateResopnseArray.append(interObj!)
                                 }
                                 else {
                                     obj?.cascade_option_id = "1404"
                                     obj?.cascade_ques_id = "115"
                                     obj?.option_id = "1410"
                                     obj?.response = "Second Intersection"
                                     obj?.order_number = "1"
                                     let containsRes = updateResopnseArray.contains(where: {
                                         $0.response == "Second Intersection"
                                     })
                                     if containsRes == true {
                                         continue
                                     }
                                 }
                               }
                            
                            if question.question_code == "C56" && question.question == "Highway and Closest Highway Exit" {
                                obj?.cascade_option_id = "1405"
                                obj?.cascade_ques_id = "116"
                                obj?.response = "Highway"
                                obj?.option_id = "1411"
                                obj?.order_number = "1"
                                let highwayObj = self.createHighwayObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "Highway"
                                 })
                                 if contains == false && opt.isSelected == true{
                                     if AppConstants.LocTypeIndex != 3 {
                                         continue
                                     }
                                     updateResopnseArray.append(highwayObj!)
                                 }
                                 else {
                                     obj?.response = "Highway"
                                 }
                               }
                            if question.question_code == "C56" && question.question == "Highway and Closest Highway Exit" {
                               //  obj?.cascade_ques_id = "23"
                                obj?.option_id = "1411"
                                obj?.order_number = "1"
                                var highwayObj = self.createClosetHighwayObject(data: obj!)
                                 let contains = updateResopnseArray.contains(where: {
                                     $0.question == "Closest Highway"
                                 })
                                 if contains == false && opt.isSelected == true {
                                     if AppConstants.LocTypeIndex != 3 {
                                         continue
                                     }
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
                                         if AppConstants.LocTypeIndex != 3 {
                                             continue
                                         }
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
                                         if AppConstants.LocTypeIndex != 3 {
                                             continue
                                         }
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
                                obj?.order_number = "4"
                            }
                            if obj?.question_code == "C46"{
                                obj?.option_id = "1356"
                                obj?.order_number = "4"
                            }
                            if obj?.question_code == "C29"{
                                obj?.option_id = "1248"
                                obj?.order_number = "3"
                            }
                            if obj?.question_code == "C30"{
                                obj?.option_id = "1241"
                                obj?.order_number = "3"
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
                            
                            if (obj?.question_id == "25" || obj?.main_question_id == "25") && (obj?.cascade_option_id == "1304" || obj?.cascade_option_id == "1305" || obj?.cascade_option_id == "1306") {
                                obj?.question = "Consent given"
                                obj?.question_code = "C47"
                                obj?.question_id = "84"
                                obj?.order_number = "13"
                                obj?.main_question_id = "25"
                                if options[0].question_code_for_cascading_id.count > 0 {
                                    obj?.question_code = options[0].question_code_for_cascading_id
                                }
                            }
                            
                            
                          //  print(objjj)
                            if exist == true && index != nil && obj?.question_code != "C52" && obj?.question_code != "C43" && obj?.question_code != "14" && obj?.main_question_id != "21" && obj?.question_code != "C32" && obj?.question_code != "C34" && obj?.main_question_id != "14" && obj?.question_code != "T8" && obj?.question_code != "T7" && obj?.question_code != "18"  && obj?.question_code != "21" && obj?.question_code != "17" && obj?.question_code != "19" && obj?.question_code != "20" && obj?.question_code != "C13" && obj?.question_code != "C14" && obj?.question_code != "C47" && obj?.question_code != "T4" {
                                
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
                                else if obj?.question_code == "C47" && updateResopnseArray[index!].question_code == "17" && obj?.question_id != "84"{
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
                                
                                if obj?.question_code == "15" || obj?.question_code == "T3"{
                                    obj?.order_number = "2"
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
                                    obj?.order_number = "2"
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
                                if checkExist == true && obj?.question_code != "C29" && obj?.question_code != "C30" && obj?.question_code != "C28" && obj?.question_code != "C33" && obj?.question_code != "C34" && obj?.question_code != "C32" && obj?.question_code != "C43" && obj?.question_code != "C5" && obj?.question_code != "C2"{
                                    continue
                                }
                                
                                let eduCodeExist = self.updateResopnseArray.contains(where: {
                                    $0.option_id == "222" && $0.question_code == "C19"
                                })
                                
                                if eduCodeExist == true && obj?.question_code == "C19" {
                                    continue
                                }
                                
                                if self.updateResopnseArray.contains(where: {$0.cascade_ques_id == "71" && $0.question_code == "C36" && $0.response.lowercased() == obj?.response.lowercased()}) {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C37" && $0.response.lowercased() == obj?.response.lowercased()}) && obj?.question_code != "T4" {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C36" && $0.response.lowercased() == obj?.response.lowercased() && obj?.question_code != "C17"}) {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C37" && $0.cascade_ques_id == "72" && $0.response.lowercased() == obj?.response.lowercased()}) {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C11" && $0.question_id == "28" && $0.response.lowercased() == obj?.response.lowercased() && obj?.question_code != "C17"}) {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C4" && $0.question_id == "14" && $0.response.lowercased() == obj?.response.lowercased()}) {
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C11" && $0.question_id == "14" && $0.cascade_ques_id == "14"}){
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C11" && $0.question_id == "14" && $0.cascade_ques_id == "14"}){
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C11" && $0.cascade_ques_id == "28" && $0.main_question_id == "14" && $0.response.lowercased() == obj?.response.lowercased()}){
                                    continue
                                }
                                else if self.updateResopnseArray.contains(where: {$0.question_code == "C24" && $0.cascade_ques_id == "52" && $0.main_question_id == "21" }){
                                   // continue
                                }
                                
                                if question.question_code == "C20" && obj?.question_code == "C20" && obj?.question.capitalized == "Education Code" {
                                    obj?.description = "EDU_sec_CD"
                                    if let responseStr = obj?.response.lowercased(),responseStr.contains("select subsection") {
                                        obj?.description = "EDU_subDiv_CD"
                                    }
                                }
                                if obj?.question_code == "C5" && obj?.cascade_ques_id == "20" {
                                    let checkContain = updateResopnseArray.contains(where: {$0.response.uppercased() == "TYPE OF VIOLATION"})
                                    if checkContain ==  false {
                                        updateResopnseArray.append(self.createViolationObject())
                                    }
                                }
                                if obj?.question.capitalized == "K-12 School?",obj?.question_code == "C24",opt.isSelected == false{
                                    continue
                                }
                                if obj?.question_code == "C43" || obj?.question_code == "C44" || obj?.question_code == "C45" || obj?.question_code == "15" || obj?.question_code == "T3"{
                                    obj?.order_number = "2"
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
            
          
            updateResopnseArray = self.removeZeroOptionIdFromAllQuestions(createdArr: updateResopnseArray)
            
            let arr1 = updateResopnseArray
            
            let isStu = updateResopnseArray.contains(where: {
                $0.question_code == "C27"
            })
            if isStu == false{
                updateResopnseArray.append(self.isPersonObject())
            }
            
            let isStreet = updateResopnseArray.contains(where: {
                 $0.question.capitalized == "Street"
            })
            if isStreet == false && AppConstants.LocTypeIndex == 1{
                updateResopnseArray.append(self.createStreetDataObject()!)
            }
            
            let isStreetObj = updateResopnseArray.contains(where: {
                 $0.question.capitalized == "Block Number and Street Name" && $0.response.capitalized == "Street"
            })
            if isStreetObj == false && AppConstants.LocTypeIndex == 1{
                updateResopnseArray.append(self.addStreetObject())
            }
            let isBlockObj = updateResopnseArray.contains(where: {
                 $0.question.capitalized == "Block Number and Street Name" && $0.response.capitalized == "Block"
            })
            if isBlockObj == false && AppConstants.LocTypeIndex == 1{
                updateResopnseArray.append(self.addBlockObject())
            }
            
            
            if AppConstants.LocTypeIndex == 2 {
                let contains = updateResopnseArray.contains(where: {
                    $0.response == "Second Intersection"
                })
                if contains == false {
                    updateResopnseArray.append(self.addSecondIntersectionObject())
                }
            }
            
            let dupArr = updateResopnseArray.filter({$0.question_code == "C24" && $0.cascade_ques_id == "52"})
            if dupArr.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C24" && $0.cascade_ques_id == "52"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            if let indexN = updateResopnseArray.firstIndex(where: {$0.question_code == "T7" && $0.cascade_option_id == "146" && $0.question_id == "106"}) {
                updateResopnseArray.remove(at: indexN)
            }
            
            let dupStreet = updateResopnseArray.filter({$0.question_code == "C54" && $0.cascade_ques_id == "23"})
            if dupStreet.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C54" && $0.cascade_ques_id == "23"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            if let indexS = updateResopnseArray.firstIndex(where: {$0.question_code == "C44" && $0.cascade_ques_id.count > 0}){
                updateResopnseArray.remove(at: indexS)
            }
            
            let dupBlk = updateResopnseArray.filter({$0.question_code == "C54" && $0.cascade_ques_id == "53"})
            if dupBlk.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C54" && $0.cascade_ques_id == "53"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            let dupProbable1 = updateResopnseArray.filter({$0.question_code == "C36" && $0.cascade_ques_id == "71"})
            if dupProbable1.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C36" && $0.cascade_ques_id == "71"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            let dupProbable2 = updateResopnseArray.filter({$0.question_code == "C37" && $0.cascade_ques_id == "72"})
            if dupProbable2.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C37" && $0.cascade_ques_id == "72"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            let dupVioType = updateResopnseArray.filter({$0.question_code == "C2" && $0.response == "Type Of Violation"})
            if dupVioType.count > 1{
                let indexD = updateResopnseArray.firstIndex(where: {$0.question_code == "C2" && $0.response == "Type Of Violation"})!
                updateResopnseArray.remove(at: indexD)
            }
            
            if  let indexVio = updateResopnseArray.firstIndex(where: {$0.question_code == "C2" && $0.response.capitalized == "Specific Code" && $0.cascade_ques_id == "16" && $0.main_question_id == "14"}) {
                updateResopnseArray.remove(at: indexVio)
            }
         
            
            let dupConsent = updateResopnseArray.filter({$0.question_code == "C47" && $0.main_question_id == "25" && $0.question.capitalized == "Consent Given"})
            if dupConsent.count > 1{
                let indexC = updateResopnseArray.lastIndex(where: {$0.question_code == "C47" && $0.main_question_id == "25" && $0.question.capitalized == "Consent Given"})!
                updateResopnseArray.remove(at: indexC)
            }
            
          
            if let indexL = updateResopnseArray.lastIndex(where: {$0.question_code == "C55" && $0.main_question_id == "108" && $0.question.capitalized == "Location"}){
                updateResopnseArray.remove(at: indexL)
            }
            
            if let indexL = updateResopnseArray.lastIndex(where: {$0.question_code == "C55" && $0.main_question_id == "21" && $0.question.capitalized == "Location"}){
                updateResopnseArray.remove(at: indexL)
            }
            
            let dupReaso = updateResopnseArray.filter({$0.cascade_option_id == "98" && $0.cascade_ques_id == "28" && $0.question_code == "C11"})
           
            if dupReaso.count > 1{
                let indexC = updateResopnseArray.lastIndex(where: {$0.cascade_option_id == "98" && $0.cascade_ques_id == "28" && $0.question_code == "C11"})!
                updateResopnseArray.remove(at: indexC)
            }
            
            let dupNonForce = updateResopnseArray.filter({$0.response == "Asked for consent to search property" && $0.question_code == "T7"})
            if dupNonForce.count > 0{
                let indexF = updateResopnseArray.lastIndex(where: {$0.response == "Asked for consent to search property" && $0.question_code == "T7"})!
                updateResopnseArray.remove(at: indexF)
            }
            
            if let indx = updateResopnseArray.firstIndex(where: {$0.question_code == "14" && $0.cascade_ques_id == "47"}) {
                updateResopnseArray.remove(at: indx)
            }
            
            if let indx = updateResopnseArray.firstIndex(where: {$0.question_code == "C20" && $0.question_id == "47" && $0.main_question_id == "14" && $0.physical_attribute == "1"}) {
                updateResopnseArray[indx].question = "Education Sub Code"
            }
        //   let arr1 = updateResopnseArray
            updateResopnseArray = updateResopnseArray.sorted(by: {Int($0.order_number) ?? 0 < Int($1.order_number) ?? 0 })
            updateResopnseArray = setOrderOfAllQuestions(createdArr: updateResopnseArray)
      //      let arr2 = updateResopnseArray
            let obj = RipaPerson(CreatedBy: String(userId!), person_name: "P"+String(i), key: AppConstants.key,date: AppConstants.date,time: AppConstants.time,duration: AppConstants.duration, ripa_response :  updateResopnseArray.sorted(by: {Int($0.order_number) ?? 0 < Int($1.order_number) ?? 0 }))
           
            ripaPersonsArray.append(obj)
            i += 1
//            let arr = ripaPersonsArray
//            print(arr)
        }
        ripaActivityDict(statusId: statusId)
    }
    
    func removeZeroOptionIdFromAllQuestions (createdArr : [RipaResponse]) -> [RipaResponse] {
        var objArr = createdArr
        for i in (0 ..< objArr.count) {
            if objArr[i].cascade_ques_id == "0" {
                objArr[i].cascade_ques_id = ""
            }
            if objArr[i].cascade_option_id == "0" {
                objArr[i].cascade_option_id = ""
            }
            if objArr[i].option_id == "0" {
                objArr[i].option_id = ""
            }
        }
        return objArr
    }
  
    func setOrderOfAllQuestions (createdArr : [RipaResponse]) -> [RipaResponse] {
        var objArr = [RipaResponse]()
        for i in (0 ..< 30) {
            var filtrArr = createdArr.filter({$0.order_number == String(i)})
            if i == 10{
                if filtrArr.count > 0 {
                    if filtrArr[0].cascade_ques_id == "0" {
                        filtrArr[0].cascade_ques_id = ""
                    }
                    objArr.append(filtrArr[0])
                    let subArr = filtrArr.filter({$0.cascade_ques_id == filtrArr[0].cascade_ques_id})
                    for var obj in subArr {
                        let containS = objArr.contains(where: {$0.response == obj.response})
                        if containS == false {
                            if obj.cascade_ques_id == "0" {
                                obj.cascade_ques_id = ""
                            }
                            objArr.append(obj)
                        }
                        let casArr = filtrArr.filter({$0.question_id == obj.cascade_ques_id })
                        for var casObj in casArr {
                            let contain = objArr.contains(where: {$0.response == casObj.response})
                            if contain == false {
                                if casObj.cascade_ques_id == "0" {
                                    casObj.cascade_ques_id = ""
                                }
                                objArr.append(casObj)
                            }
                            let casCadeArr = filtrArr.filter({$0.question_id == casObj.cascade_ques_id})
                            for var casSubObj in casCadeArr {
                                let contains = objArr.contains(where: {$0.response == casSubObj.response})
                                if contains == false {
                                    if casSubObj.cascade_ques_id == "0" {
                                        casSubObj.cascade_ques_id = ""
                                    }
                                    objArr.append(casSubObj)
                                }
                            }
                        }
                    }
               }
               let descA = createdArr.filter({$0.order_number == String(i) && ($0.description == "StReas_N" || $0.description == "BasSearch_N")})
               for var obj in descA {
                   let contains = objArr.contains(where: {$0.response == obj.response})
                   if contains == false {
                       if obj.cascade_ques_id == "0" {
                           obj.cascade_ques_id = ""
                       }
                       objArr.append(obj)
                   }
               }
            }
            else {
                for var obj in filtrArr {
                    if obj.cascade_ques_id == "0" {
                        obj.cascade_ques_id = ""
                    }
                    objArr.append(obj)
                }
            }
        }
        let filtrArr = createdArr.filter({$0.order_number == String(100)})
        for var obj in filtrArr {
            if obj.cascade_ques_id == "0" {
                obj.cascade_ques_id = ""
            }
            objArr.append(obj)
        }
        
        return objArr
    }
   
    
    func checkQuestionIsExist(questionCode : String) -> Bool {
        let isExistIng = updateResopnseArray.contains(where: {
            $0.question_code == questionCode
        })
       return isExistIng
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
        obj?.option_id = "1405"
        obj?.order_number = "1"
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
        obj?.option_id = "1406"
        obj?.order_number = "1"
        return obj
    }
    
    func isPersonObject() -> RipaResponse {
        let obj = RipaResponse(question_id: "62", response: "No", internal: "0", userid: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, question: "Is person a student?", CreatedBy: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, physical_attribute: "", key: "", personId: "", description: "", question_code: "C27", cascade_ques_id: "0", order_number: "3", option_id: "1234", cascade_option_id: "1246", main_question_id: "61", supervisorId: "", other_assignment_value: "", activity_id: "", ripa_activity: "", os_version: "", is_trainee: "", isSelected: "Yes")
        return obj
    }
    
    func createViolationObject() -> RipaResponse {
        let obj = RipaResponse(question_id: "15", response: "Specific Code", internal: "0", userid: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, question: "Traffic violation", CreatedBy: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, physical_attribute: "1", key: "", personId: "", description: "", question_code: "C2", cascade_ques_id: "16", order_number: "10", option_id: "92", cascade_option_id: "92", main_question_id: "14", supervisorId: "", other_assignment_value: "", activity_id: "", ripa_activity: "", os_version: "", is_trainee: "", isSelected: "Yes")
        return obj
    }
    
    
    func createFirstIntersectionObject(data : RipaResponse) -> RipaResponse? {
        var obj:RipaResponse?
        obj = data
        obj?.question = "First Intersection"
        obj?.response = AppConstants.firstIntersection
        obj?.question_code = "C26"
        obj?.question_id = "54"
        obj?.option_id = "1231"
        obj?.cascade_option_id = ""
        obj?.cascade_ques_id = ""
        obj?.order_number = "1"
        return obj
    }
    
    func createSecondIntersectionObject(data : RipaResponse) -> RipaResponse? {
        var obj:RipaResponse?
        obj = data
        obj?.question = "Second Intersection"
        obj?.response = AppConstants.secondIntersection
        obj?.question_code = "C49"
        obj?.question_id = "115"
        obj?.option_id = "1404"
        obj?.cascade_option_id = ""
        obj?.cascade_ques_id = ""
        obj?.order_number = "1"
        return obj
    }
    
    func addSecondIntersectionObject() -> RipaResponse {
        let obj = RipaResponse(question_id: "121", response: "Second Intersection", internal: "0", userid: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, question: "Closest Intersection", CreatedBy: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, physical_attribute: "", key: "", personId: "", description: "", question_code: "C55", cascade_ques_id: "115", order_number: "1", option_id: "1410", cascade_option_id: "1404", main_question_id: "21", supervisorId: "", other_assignment_value: "", activity_id: "", ripa_activity: "", os_version: "", is_trainee: "", isSelected: "Yes")
        return obj
    }
    
    func addBlockObject() -> RipaResponse {
        let obj = RipaResponse(question_id: "120", response: "Block", internal: "0", userid: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, question: "Block Number and Street Name", CreatedBy: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, physical_attribute: "", key: "", personId: "", description: "", question_code: "C54", cascade_ques_id: "53", order_number: "1", option_id: "1409", cascade_option_id: "1229", main_question_id: "21", supervisorId: "", other_assignment_value: "", activity_id: "", ripa_activity: "", os_version: "", is_trainee: "", isSelected: "Yes")
        return obj
    }
    
    func addStreetObject() -> RipaResponse {
        let obj = RipaResponse(question_id: "120", response: "Street", internal: "0", userid: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, question: "Block Number and Street Name", CreatedBy: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, physical_attribute: "", key: "", personId: "", description: "", question_code: "C54", cascade_ques_id: "23", order_number: "1", option_id: "1409", cascade_option_id: "109", main_question_id: "21", supervisorId: "", other_assignment_value: "", activity_id: "", ripa_activity: "", os_version: "", is_trainee: "", isSelected: "Yes")
        return obj
    }
    
    func createBlockObject(data : RipaResponse) -> RipaResponse? {
        var obj:RipaResponse?
        obj = data
        obj?.question = "Block"
        obj?.response = AppConstants.block
        obj?.question_code = "C25"
        obj?.cascade_option_id = ""
        obj?.option_id = "1229"
        obj?.question_id = "53"
        obj?.cascade_ques_id = ""
        obj?.order_number = "1"
        return obj
    }
   
    func createStreetObject(data : RipaResponse) -> RipaResponse? {
        var obj:RipaResponse?
        obj = data
        obj?.question = "Street"
        obj?.cascade_option_id = ""
        obj?.response = AppConstants.street
        obj?.question_code = "C7"
        obj?.option_id = "109"
        obj?.question_id = "23"
        obj?.cascade_ques_id = ""
        obj?.order_number = "1"
        return obj
    }
    
    func createStreetDataObject() -> RipaResponse? {
        let obj = RipaResponse(question_id: "109", response: AppConstants.street, internal: "", userid: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, question: "Street", CreatedBy: (AppManager.getLastSavedLoginDetails()?.result?.userid)!, physical_attribute: "", key: "", personId: "", description: "", question_code: "C7", cascade_ques_id: "", order_number: "1", option_id: "109", cascade_option_id: "", main_question_id: "53", supervisorId: "", other_assignment_value: "", activity_id: "", ripa_activity: "", os_version: "", is_trainee: "", isSelected: "Yes")
        return obj
    }
    
    
    func ripaActivityDict(statusId:String){
        ripaActivityArray.removeAll()
        strIPAddress = self.getIPAddress()
        print("IPAddress :: \(String(describing: strIPAddress))")
        
        ripaActivity?.end_date = getCurrentTime()
        ripaActivity?.City = AppConstants.city
        ripaActivity?.ip_address = strIPAddress
        ripaActivity?.ripaPersons = self.ripaPersonsArray
        ripaActivity?.stop_date = AppConstants.date
        //+ " "+ AppConstants.time
        ripaActivity?.stop_time = AppConstants.time
        ripaActivity?.stop_duration = AppConstants.duration
        
        if AppConstants.LocTypeIndex == 6,let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
            ripaActivity?.Location = String(format: "%@,%@", latString, longString)
        }
        else  if AppConstants.LocTypeIndex == 1 && AppConstants.street.count > 0 {
            ripaActivity?.Location = String(format: " %@ BLK & %@",AppConstants.block , AppConstants.street)
        }
        else  if AppConstants.LocTypeIndex == 1 {
            ripaActivity?.Location = String(format: " %@ & %@",AppConstants.block , AppConstants.street)
        }
        else  if AppConstants.LocTypeIndex == 2 {
            ripaActivity?.Location = String(format: "%@ & %@", AppConstants.firstIntersection, AppConstants.secondIntersection)
        }
        else  if AppConstants.LocTypeIndex == 3 {
            ripaActivity?.Location = String(format: "%@ & %@", AppConstants.highway, AppConstants.closestHighway)
        }
        else {
            ripaActivity?.Location = AppConstants.LocTypeDescription
        }
        
       
        ripaActivity?.key = AppConstants.key
        ripaActivity?.activity_status_id = AppConstants.activityStatusId
        ripaActivity?.latitude = AppConstants.lati
        ripaActivity?.longitude = AppConstants.longi
        if AppConstants.lati.count < 5,let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
            ripaActivity?.latitude = latString
            ripaActivity?.longitude = longString
        }
        
        ripaActivity?.activity_id = AppConstants.activityID
        ripaActivity?.time_duration_enable = AppConstants.ripaTimeDuration
        ripaActivity?.Notes = AppConstants.notes
        if AppConstants.ripaTimeDuration == "Y"{
            ripaActivity?.timetaken = getTimeTaken()
        }
        else{
            let timeTaken =  Date().calculateTime(from_date: ripaActivity?.start_date ?? getCurrentTime() , to_date: getCurrentTime())
            ripaActivity?.timetaken = timeTaken
        }
        
        ripaActivity?.is_K_12_Student = AppConstants.isStudent
        ripaActivity?.citation_number = ""
        ripaActivity?.deviceid = 0
        
        if AppConstants.status == "Created"{
            ripaActivity?.citation_number = AppConstants.citation
            ripaActivity?.deviceid = Int(AppConstants.deviceid) ?? 0
        }
        
        if viewType == "UseSaveRipa" && AppConstants.trafficId != ""{
            print(AppConstants.trafficId)
            ripaActivity?.traffic_id = AppConstants.trafficId
        }
       
        ripaActivityArray.append(ripaActivity!)
    }
    
    func getTimeTaken()-> String{
        let timetaken =  Double(AppConstants.applicationtime)!/60
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
                    
                    // wifi = ["en0"]
                    // wired = ["en2", "en3", "en4"]
                    // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
                    
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
    
    
    func setKey(){
        let key : String? = String(Date().millisecondsSince1970)
        AppConstants.key = key!
    }
    
    
    func checkRequiredQuestion(questArray:[QuestionResult1]?, cascadeQuestArray:[QuestionResult1]?, selectedOpt:[[Questionoptions1]])->((Array<Any>),(Array<Any>)){
        var i = 0
        var newarray = [Any]()
        var questionIdArray = [Any]()
       
        for quest in questArray!{
            if quest.question_code == "T1"{
                print(quest.question_code)
            }
            if quest.question_code == "5"{
                if AppConstants.date == "" || AppConstants.duration == "" || AppConstants.time == "" || AppConstants.city == "" {
                    newarray.append(quest.question)
                    questionIdArray.append(i)
                }
                if checkLocationIsEmpty() {
                    newarray.append(quest.question)
                    questionIdArray.append(i)
                }
                i += 1
            }
            
            else if quest.question_code == "25" {
                var check = true
                for optn in quest.questionoptions!{
                    if check == true{
                        let cascadeQuest =  getCascadeQuestionUsingId(cascadeQuestArray: cascadeQuestArray, questionID: Int(optn.cascade_ripa_id)!)
                        if cascadeQuest.is_required == "1" && optn.isSelected == false && cascadeQuest.question_code != "C33" && cascadeQuest.question_code != "C27"{
                            let arrayOfStrings: [String] = newarray.compactMap { String(describing: $0) }
                            if arrayOfStrings.contains(where: {$0 != quest.question}) || arrayOfStrings.count == 0{
                                newarray.append(quest.question)
                                questionIdArray.append(i)
                                check = false
                                continue
                            }
                        }
                        if cascadeQuest.is_required == "1"{
                            newRipaViewModel.cascadeQuestionArray = cascadeQuestArray
                            let question = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode:optn.question_code_for_cascading_id)
                            if question.questionoptions?.count == 0 || (question.questionoptions?.first?.option_value.count == 0) {
                                let arrayOfStrings: [String] = newarray.compactMap { String(describing: $0) }
                                if arrayOfStrings.contains(where: {$0 != quest.question}) || arrayOfStrings.count == 0 {
                                    newarray.append(quest.question)
                                    questionIdArray.append(i)
                                    check = false
                                    continue
                                }
                            }
                        }
                    }
                }
                i += 1
            }
            else{
                if quest.is_required == "1"{
                    var check = true
                    
                    if quest.question_code == "21"{
                        print(quest.question)
                        print(selectedOpt[i].count)
                        print(quest.isDescription_Required)
                
                    }
                    
                    if  selectedOpt[i].count < 1 || (quest.isDescription_Required == "1" && selectedOpt[i].count < 2){
                        newarray.append(quest.question)
                        questionIdArray.append(i)
                        check = false
                    }
                    
                    if quest.question_code == "21" && check == true{
                        
                    }
                
                    if quest.isDescription_Required == "1" && check == true{
                        for optn in quest.questionoptions!{
                            if optn.tag == "Description"  && (optn.option_value == "" || optn.isSelected == false) {
                                newarray.append(quest.question)
                                questionIdArray.append(i)
                                check = false
                            }
                          
                            
                            if quest.question_code == "14" && check == true{
                                var j = 0
                                if optn.physical_attribute == "1" && optn.isSelected == true{
                                    let cascadeQuest =  getCascadeQuestionUsingId(cascadeQuestArray: cascadeQuestArray, questionID: Int(optn.cascade_ripa_id)!)
                                    let objj = cascadeQuest.questionoptions?.filter({
                                        $0.isSelected == true
                                    })
                                    if objj?.count == 0 {
                                        j = 1
                                        check = false
                                    }
                                }
                                if optn.physical_attribute == "2" && optn.isSelected == true{
                                    let cascadeQuest =  getCascadeQuestionUsingId(cascadeQuestArray: cascadeQuestArray, questionID: Int(optn.cascade_ripa_id)!)
                                    let cd = optn.cascade_ripa_id
                                    if (cd == "17" || cd == "15") {
                                        continue
                                    }
                                    if cascadeQuest.questionoptions?.count ?? 0 > 1 && cascadeQuest.questionoptions![1].isSelected == false{
                                        j = 1
                                        check = false
                                    }
                                }
                                if j == 1{
                                    newarray.append(quest.question)
                                    questionIdArray.append(i)
                                    check = false
                                }
                            }
                            
                            
                        }
                    }
                }
                i += 1
            }
        }
        return (newarray,questionIdArray)
    }
    
    func checkLocationIsEmpty() -> Bool {
        print(AppConstants.firstIntersection)
        print(AppConstants.lati)
        print(AppConstants.longi)
        print(AppConstants.street)
        print(AppConstants.firstIntersection)
        print(AppConstants.highway)
        print(AppConstants.LocTypeDescription)
        print(AppConstants.LocTypeIndex)
        var letString : String = ""
        var longString : String = ""
        if let latStr = UserDefaults.standard.string(forKey: "latitude"),let longStr = UserDefaults.standard.string(forKey: "longitude") {
            letString = latStr
            longString = longStr
        }
        if AppConstants.LocTypeIndex == 0{
            return true
        }
        else if AppConstants.LocTypeIndex == 6 && letString == "" && longString == "" {
            return true
        }
        else if AppConstants.LocTypeIndex == 1 && AppConstants.street == ""{
            return true
        }
        else if AppConstants.LocTypeIndex == 2 && AppConstants.firstIntersection == ""{
            return true
        }
        else if AppConstants.LocTypeIndex == 3 && AppConstants.highway == ""{
            return true
        }
        else if AppConstants.LocTypeIndex == 4 && AppConstants.LocTypeDescription == ""{
            return true
        }
        return false
    }
    
    
    func getCascadeQuestionUsingQuestionCode(questionCode:String) -> QuestionResult1{
        var quest:QuestionResult1?
        for question in cascadeQuestionArray{
            if question.question_code == questionCode{
                quest = question
            }
        }
        return quest!
    }
    
    
    func checkPreviewRequiredQuestion(questArray:[QuestionResult1]?, cascadeQuestArray:[QuestionResult1]?, selectedOpt:[[Questionoptions1]])->((Array<Any>),(Array<Any>)){
        var i = 0
        var newarray = [Any]()
        var questionIdArray = [Any]()
        
        for quest in questArray!{
            if quest.question_code == "5"{
                if AppConstants.date == "" || AppConstants.duration == "" || AppConstants.time == "" || AppConstants.city == "" {
                    newarray.append(quest.question)
                    questionIdArray.append(i)
                }
                if checkLocationIsEmpty() {
                    newarray.append(quest.question)
                    questionIdArray.append(i)
                }
                i += 1
            }
            else if quest.question_code == "25" {
                var check = true
               
                for optn in quest.questionoptions!{
                    print(optn.option_value)
                    print(quest.question)
                    if check == true{
                        let cascadeQuest =  getCascadeQuestionUsingId(cascadeQuestArray: cascadeQuestArray, questionID: Int(optn.cascade_ripa_id)!)
                        if cascadeQuest.is_required == "1" && optn.isSelected == false && cascadeQuest.question_code != "C33" && cascadeQuest.question_code != "C27"{
                            let arrayOfStrings: [String] = newarray.compactMap { String(describing: $0) }
                            if arrayOfStrings.contains(where: {$0 != quest.question}) || arrayOfStrings.count == 0{
                                newarray.append(quest.question)
                                questionIdArray.append(i)
                                check = false
                                continue
                            }
                        }
                        
                        if cascadeQuest.is_required == "1"{
                            newRipaViewModel.cascadeQuestionArray = cascadeQuestArray
                            let question = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode:optn.question_code_for_cascading_id)
                            if question.questionoptions?.count == 0 || (question.questionoptions?.first?.option_value.count == 0) {
                                let arrayOfStrings: [String] = newarray.compactMap { String(describing: $0) }
                                if arrayOfStrings.contains(where: {$0 != quest.question}) || arrayOfStrings.count == 0{
                                    newarray.append(quest.question)
                                    questionIdArray.append(i)
                                    check = false
                                    continue
                                }
                            }
                        }
                    }
                }
                i += 1
            }
            else{
                if quest.is_required == "1"{
                    var check = true
                    
                    if quest.question_code == "14"{
                        print(quest.question)
                    }
                    
                    if  selectedOpt[i].count < 1 || (quest.isDescription_Required == "1" && selectedOpt[i].count < 2){
                        newarray.append(quest.question)
                        questionIdArray.append(i)
                        check = false
                    }
                   else if  quest.is_required == "1" && quest.question_code == "17" && selectedOpt[i].count < 2 {
                        newarray.append(quest.question)
                        questionIdArray.append(i)
                        check = false
                      }
                    
                    
                    if quest.isDescription_Required == "1" && check == true{
                        for optn in quest.questionoptions!{
                            if optn.tag == "Description"  && optn.option_value == "" {
                                newarray.append(quest.question)
                                questionIdArray.append(i)
                                check = false
                            }
                            
                            if quest.question_code == "14" && check == true{
                                var j = 0
                                if optn.physical_attribute == "1" && optn.isSelected == true{
                                    let cascadeQuest =  getCascadeQuestionUsingId(cascadeQuestArray: cascadeQuestArray, questionID: Int(optn.cascade_ripa_id)!)
                                    let objj = cascadeQuest.questionoptions?.filter({
                                        $0.isSelected == true
                                    })
                                    if objj?.count == 0 {
                                        j = 1
                                        check = false
                                    }
                                }
                                if optn.physical_attribute == "2" && optn.isSelected == true{
                                    let cascadeQuest =  getCascadeQuestionUsingId(cascadeQuestArray: cascadeQuestArray, questionID: Int(optn.cascade_ripa_id)!)
                                    if cascadeQuest.questionoptions?.count ?? 0 > 1, cascadeQuest.questionoptions![1].isSelected == false{
                                        j = 1
                                        check = false
                                    }
                                }
                                if j == 1{
                                    newarray.append(quest.question)
                                    questionIdArray.append(i)
                                    check = false
                                }
                            }
                        }
                    }
                }
                i += 1
            }
        }
        return (newarray,questionIdArray)
    }
    
    func getDefaultCityByCustId () {
        var custId : String = ""
        if let idUser = AppManager.getLastSavedLoginDetails()?.result?.custid{
            custId = idUser
        }
        var countiId : String = ""
        if let cId = AppManager.getLastSavedLoginDetails()?.result?.county_id{
            countiId = cId
        }
        
        let id = AppManager.getLastSavedLoginDetails()?.id
        let param:[String : Any] = ["county_id":countiId as Any,"custid":custId]
        let params:[String : Any] =  ["id":id!, "method":"defaultCitiesByCustId", "params":param ,"jsonrpc": "2.0"]
         print(param)
        getDefaultCitiesRipa(params: params)
    }

    func getDefaultCitiesRipa(params: [String:Any]){
        AppUtility.showProgress(nil, title: nil)
        var URL:String?
       
         URL = AppConstants.Api.questions
         print(params)
        if Reachability.isConnectedToNetwork(){
            ApiManager.getDefaultCityByCustId(params: params, methodTyPe: .post, url: URL!, completion: { (success,message) in
                AppUtility.hideProgress(nil)
                 if message == "Success"{
                    print(success)
                     if let json = try? JSON(data: success as! Data),let objectDictionary = json.dictionaryObject,let result = objectDictionary["result"] as? [[String : Any]],let object = DefaultCityModel.formattedArray(data: result)  {
                        print(objectDictionary)
                        self.saveDelegate?.getDefaultCityFromServer(data: object)
                    }
                  }
                else{
                    if success as! String != "" {
                       // AppUtility.showAlertWithProperty("Alert", messageString:success as! String )
                    }
                   else{
                        AppUtility.showAlertWithProperty("Alert", messageString:"Something went wrong" )}
                }
                
            })
            { (error, code, message) in
                AppUtility.hideProgress(nil)
                
                AppUtility.showAlertWithProperty("Alert", messageString: error!.localizedDescription)
                if let errorMessage = message {
                    AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
                }
            }
        }
        
        else{
            print("Internet Connection not Available!")
            AppUtility.hideProgress(nil)
           // AppUtility.showAlertWithProperty("Alert", messageString: "Internet connection not available.")
             
        }
      }
        
    
    
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    /// Returns the amount of hours from another date
    func calculateTime(from_date: String, to_date: String) -> String {
        var min = ""
        if from_date != "" && to_date != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            let date = dateFormatter.date(from: from_date)
            let to = dateFormatter.date(from: to_date)
            
            
            // let hour = String(Calendar.current.dateComponents([.hour], from: date!, to: to!).hour ?? 0)
            min = String(Calendar.current.dateComponents([.minute], from: date!, to: to!).minute ?? 0)
            
            if min == "0"{
                min = "1"
                //"0." + String(Calendar.current.dateComponents([.second], from: date!, to: to!).second ?? 0)
            }
            // let time = hour + ":" + min + ":" + sec
        }
        return min
    }
    //     /// Returns the amount of minutes from another date
    //     func minutes(from date: Date) -> Int {
    //         return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    //     }
    //     /// Returns the amount of seconds from another date
    //     func seconds(from date: Date) -> Int {
    //         return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    //     }
    
    
}



