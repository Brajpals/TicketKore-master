//
//  PreviewViewModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 03/04/21.
//

import UIKit
import SwiftyJSON
import Foundation

protocol PreviewModelDelegate: class {
    func setPreviewDelegate(success:String,message:String)
}

protocol SaveDelegate: class {
    func moveToPrevScreen(move:Bool)
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
        let option:Questionoptions1 = Questionoptions1(mainQuestId: mainQuestId!, mainQuestOrder:"" ,option_id: "", ripa_id:ripaID!, custid: "", option_value: optionValue!, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "", tag: "", physical_attribute: physical_attribute!, default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: mainQuestId!, isExpanded: false, questionoptions: [])
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
        let ripaTemp = RipaTempMaster(key: AppConstants.key, skeletonID: "", activityId: "", custid: activity.custid, userid: activity.userid, username: activity.username, rmsid: rmsid ?? "", phoneNumber: phone ?? "", location: activity.Location, city: activity.City, street: "", block: "", intersectionStreet: "", note: AppConstants.notes, activity_notes: "", CreatedBy: activity.CreatedBy, ticketDate: "", declarationDate: activity.end_date, violation: "", violationCode: "", violationType: "", violationID: "", offenceCode: "", email: result?.email_address ?? "" , createdOn: activity.stop_date, updatedBy: result?.UpdatedBy ?? "", updatedOn: result?.UpdatedOn ?? "", citationNumber: activity.citation_number, status: AppConstants.status, mainStatus: "0", statusChnageDate: "", ripaTempId: "", tempType: "", stopDate: activity.stop_date + " " + AppConstants.time , stopTime:AppConstants.time  ,stopDuration: AppConstants.duration, rejectedURL: "", syncStatus: "", startDate:activity.start_date, endDate:activity.end_date, is_K_12_Student:AppConstants.isStudent, lat:activity.latitude, long: activity.longitude, timeTaken: activity.timetaken, countyId: (AppManager.getLastSavedLoginDetails()?.result!.county_id)!, deviceid: String(ripaActivity!.deviceid), callNumber: AppConstants.call_number, callTime: "", onsceneTime: AppConstants.onscene_time, clearTimeOfOfficer: AppConstants.clear_time_of_the_Offrcer, overallCallClearTime: AppConstants.overall_call_clear_time, callType: AppConstants.call_type, unitId: AppConstants.unitId, zone: AppConstants.zone)
        
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
        
        AppUtility.showProgress(nil, title:nil)
        var URL:String?
        
        URL = AppConstants.Api.updateRipa
        ApiManager.updateRipa(params: params, methodTyPe: .post, url: URL!, completion: { [self]  (success,message) in
            
            if message == "Success"{
                // saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "")
                
                if let json = try? JSON(data: success as! Data){
                    print(json)
                    let errorMsg = json["result"]["serviceError"].stringValue
                    
                    if  errorMsg == ""{
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
                }
                else{
                    self.saveDelegate?.moveToPrevScreen(move: true)
                }
            }
            else{
                
            }
            AppUtility.hideProgress(nil)
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            if let errorMessage = message {
                if showAlertForSave == true{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Unable to save on server. Something went wrong")
                }
                else{
                    self.saveDelegate?.moveToPrevScreen(move: true)
                }
                
            }
        }
    }
    
    
    
    func submitAnswers(params:[String:Any]) {
        
         AppUtility.showProgress(nil, title:nil)
        var URL:String?
        
 //                     saveToDB(updateRipa : updateRipaParam() , isUpdate: true, syncSccessful: "0")
//               previewModelDelegate?.setPreviewDelegate(success: ""  ,message:"Success")
         
         URL = AppConstants.Api.updateRipa
        ApiManager.updateRipa(params: params, methodTyPe: .post, url: URL!, completion: { [self] (success,message) in

            if message == "Success"{
                if let json = try? JSON(data: success as! Data){
                    print(json)
                    let errorMsg = json["result"]["serviceError"].stringValue

                    if  errorMsg == ""{
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
    
    
    func createPersonsDict(personArray:[[String: Any]] ,ripaActivity:Ripaactivity ,statusId:String) {
        //setKey()
        // resetArray()
        self.personArray.removeAll()
        self.ripaPersonsArray.removeAll()
        
        self.ripaActivity = ripaActivity
        
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
                
                if question.question_code == "C6"{
                    print(question.question)
                }
                
                if question.question_code == "25"{
                    continue
                }
                
                if question.question_code == "2"{
                    let timeTaken:String?
                    if AppConstants.ripaTimeDuration == "N"{
                        timeTaken = Date().calculateTime(from_date: ripaActivity.start_date , to_date: getCurrentTime())
                    }else{
                        timeTaken = getTimeTaken()
                    }
                    
                    let obj = RipaResponse(question_id: question.id, response: timeTaken, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: "", key:AppConstants.key , personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id, supervisorId: "")
                    updateResopnseArray.append(obj)
                    continue
                }
                
                
                
                // FOR NON SELECTED OPTIONALS
                if question.is_required == "0" && question.visible_question == "1"{
                    let selectedOptionalArray =  question.questionoptions!.filter { $0.isSelected }
                    if selectedOptionalArray.count < 1{
                        let obj = RipaResponse(question_id: question.id, response: "", internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: "", key:AppConstants.key , personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: question.id, order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id, supervisorId: "")
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                if question.question_code == "22"{
                    let exp = calculateYearOfExp()
                    let obj = RipaResponse(question_id: question.id, response: exp, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: "", key:AppConstants.key, personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "", order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id, supervisorId: "")
                    updateResopnseArray.append(obj)
                    continue
                }
                
                
                
                if question.question_code == "C24"{
                    if AppConstants.isSchoolSelected == "Yes" {
                        let option = question.questionoptions!.first
                       // let orderNo = option!.order_number
                        let obj = RipaResponse(question_id: option!.ripa_id, response: option?.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: address.physical_attribute, key: AppConstants.key, personId: String(i) , description: "", question_code: option!.question_code_for_cascading_id, cascade_ques_id: option!.cascade_ripa_id, order_number: option!.order_number, option_id: option!.option_id, cascade_option_id: "", main_question_id: address.main_question_id, supervisorId: "")
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                
                if question.question_code == "5"{
                    address.isSelected = true
                    address.main_question_id = question.id
                    address.ripa_id = question.id
                    
                    let obj = RipaResponse(question_id: question.id, response: address.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: address.physical_attribute, key: AppConstants.key, personId: String(i) , description: address.optionDescription, question_code: question.question_code, cascade_ques_id: "", order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id, supervisorId: "")
                    
                    updateResopnseArray.append(obj)
                    //continue
                }
                
                for options in selectedOptionsArray{
                    for opt in options{
                        if  opt.ripa_id == question.id {
                            var obj:RipaResponse?
                            
                            if question.question_code == "C6" || question.question_code == "C7" || question.question_code == "C26" || question.question_code == "C25"{
                                obj = RipaResponse(question_id: opt.mainQuestId, response: opt.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: opt.physical_attribute, key: AppConstants.key, personId: String(i) , description: opt.optionDescription, question_code: question.question_code, cascade_ques_id: opt.ripa_id, order_number: opt.mainQuestOrder , option_id: opt.option_id, cascade_option_id: opt.option_id, main_question_id: opt.main_question_id, supervisorId: "")
                            }
                            else{
                                obj = RipaResponse(question_id: question.id, response: opt.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: opt.physical_attribute, key: AppConstants.key, personId: String(i) , description: opt.optionDescription, question_code: opt.question_code_for_cascading_id, cascade_ques_id: opt.cascade_ripa_id, order_number:  opt.mainQuestOrder , option_id: opt.option_id, cascade_option_id: opt.option_id, main_question_id: opt.main_question_id, supervisorId: "")
                                
                                if opt.main_question_id == ""{
                                    print(opt.mainQuestId)
                                }
                                
                                if   question.question_code == "C9"{
                                    obj?.question_id = question.id
                                }
                            }
                            
                            if opt.mainQuestId == ""{
                                obj?.order_number = question.order_number
                                obj?.question_id = question.id
                            }
                            
                            if obj?.question_code == ""{
                                obj?.question_code = question.question_code
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
                            
                            updateResopnseArray.append(obj!)
                        }
                    }
                }
            }
            
            
            let obj = RipaPerson(CreatedBy: String(userId!), person_name: "P"+String(i), key: AppConstants.key,date: AppConstants.date,time: AppConstants.time,duration: AppConstants.duration, ripa_response :  updateResopnseArray.sorted(by: {Int($0.order_number)! < Int($1.order_number)! }))
            
            ripaPersonsArray.append(obj)
            i += 1
            
        }
        ripaActivityDict(statusId: statusId)
    }
    
    
    
    func createUserSettingPersonsDict(personArray:[[String: Any]] ,ripaActivity:Ripaactivity ,statusId:String,ripaResponse : RipaResponse) {
        //setKey()
        // resetArray()
        self.personArray.removeAll()
        self.ripaPersonsArray.removeAll()
        
        self.ripaActivity = ripaActivity
        
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
                
                if question.question_code == "C6"{
                    print(question.question)
                }
                
                if question.question_code == "25"{
                    continue
                }
                
                if question.question_code == "2"{
                    let timeTaken:String?
                    if AppConstants.ripaTimeDuration == "N"{
                        timeTaken = Date().calculateTime(from_date: ripaActivity.start_date , to_date: getCurrentTime())
                    }else{
                        timeTaken = getTimeTaken()
                    }
                    
                    let obj = RipaResponse(question_id: question.id, response: timeTaken, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: "", key:AppConstants.key , personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id, supervisorId: "")
                    updateResopnseArray.append(obj)
                    continue
                }
                
                
                
                // FOR NON SELECTED OPTIONALS
                if question.is_required == "0" && question.visible_question == "1"{
                    let selectedOptionalArray =  question.questionoptions!.filter { $0.isSelected }
                    if selectedOptionalArray.count < 1{
                        let obj = RipaResponse(question_id: question.id, response: "", internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: "", key:AppConstants.key , personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: question.id, order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id, supervisorId: "")
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                if question.question_code == "23"{
                    updateResopnseArray.append(ripaResponse)
                    continue
                }
                
                if question.question_code == "22"{
                    let exp = calculateYearOfExp()
                    let obj = RipaResponse(question_id: question.id, response: exp, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: "", key:AppConstants.key, personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "", order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id, supervisorId: "")
                    updateResopnseArray.append(obj)
                    continue
                }
                
                
                
                if question.question_code == "C24"{
                    if AppConstants.isSchoolSelected == "Yes" {
                        let option = question.questionoptions!.first
                       // let orderNo = option!.order_number
                        let obj = RipaResponse(question_id: option!.ripa_id, response: option?.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: address.physical_attribute, key: AppConstants.key, personId: String(i) , description: "", question_code: option!.question_code_for_cascading_id, cascade_ques_id: option!.cascade_ripa_id, order_number: option!.order_number, option_id: option!.option_id, cascade_option_id: "", main_question_id: address.main_question_id, supervisorId: "")
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                
                if question.question_code == "5"{
                    address.isSelected = true
                    address.main_question_id = question.id
                    address.ripa_id = question.id
                    
                    let obj = RipaResponse(question_id: question.id, response: address.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: address.physical_attribute, key: AppConstants.key, personId: String(i) , description: address.optionDescription, question_code: question.question_code, cascade_ques_id: "", order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id, supervisorId: "")
                    
                    updateResopnseArray.append(obj)
                    //continue
                }
                
                for options in selectedOptionsArray{
                    for opt in options{
                        if  opt.ripa_id == question.id {
                            var obj:RipaResponse?
                            
                            if question.question_code == "C6" || question.question_code == "C7" || question.question_code == "C26" || question.question_code == "C25"{
                                obj = RipaResponse(question_id: opt.mainQuestId, response: opt.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: opt.physical_attribute, key: AppConstants.key, personId: String(i) , description: opt.optionDescription, question_code: question.question_code, cascade_ques_id: opt.ripa_id, order_number: opt.mainQuestOrder , option_id: opt.option_id, cascade_option_id: opt.option_id, main_question_id: opt.main_question_id, supervisorId: "")
                            }
                            else{
                                obj = RipaResponse(question_id: question.id, response: opt.option_value, internal: question.internal, userid: String(userId!), question: question.question, CreatedBy: String(userId!), physical_attribute: opt.physical_attribute, key: AppConstants.key, personId: String(i) , description: opt.optionDescription, question_code: opt.question_code_for_cascading_id, cascade_ques_id: opt.cascade_ripa_id, order_number:  opt.mainQuestOrder , option_id: opt.option_id, cascade_option_id: opt.option_id, main_question_id: opt.main_question_id, supervisorId: "")
                                
                                if opt.main_question_id == ""{
                                    print(opt.mainQuestId)
                                }
                                
                                if   question.question_code == "C9"{
                                    obj?.question_id = question.id
                                }
                            }
                            
                            if opt.mainQuestId == ""{
                                obj?.order_number = question.order_number
                                obj?.question_id = question.id
                            }
                            
                            if obj?.question_code == ""{
                                obj?.question_code = question.question_code
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
                            
                            updateResopnseArray.append(obj!)
                        }
                    }
                }
            }
            
            
            let obj = RipaPerson(CreatedBy: String(userId!), person_name: "P"+String(i), key: AppConstants.key,date: AppConstants.date,time: AppConstants.time,duration: AppConstants.duration, ripa_response :  updateResopnseArray.sorted(by: {Int($0.order_number)! < Int($1.order_number)! }))
            
            ripaPersonsArray.append(obj)
            i += 1
            
        }
        ripaActivityDict(statusId: statusId)
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
        ripaActivity?.Location = AppConstants.address
        ripaActivity?.key = AppConstants.key
        ripaActivity?.activity_status_id = statusId
        ripaActivity?.latitude = AppConstants.lati
        ripaActivity?.longitude = AppConstants.longi
        ripaActivity?.time_duration_enable = AppConstants.ripaTimeDuration
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
            if quest.question_code == "5"{
                if AppConstants.date == "" || AppConstants.duration == "" || AppConstants.time == "" || AppConstants.address == "" || AppConstants.city == "" {
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
                        if cascadeQuest.is_required == "1" && optn.isSelected == false{
                            newarray.append(quest.question)
                            questionIdArray.append(i)
                            
                            check = false
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
                                    for options in cascadeQuest.questionoptions!{
                                        if options.isSelected == false{
                                            j = 1
                                            check = false
                                        }
                                    }
                                }
                                if optn.physical_attribute == "2" && optn.isSelected == true{
                                    let cascadeQuest =  getCascadeQuestionUsingId(cascadeQuestArray: cascadeQuestArray, questionID: Int(optn.cascade_ripa_id)!)
                                    if cascadeQuest.questionoptions![1].isSelected == false{
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



