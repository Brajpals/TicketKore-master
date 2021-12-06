//
//  OfflineSyncViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 6/15/21.
//

import UIKit
import SwiftyJSON


class OfflineSyncViewController: PreviewModelDelegate {
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
    
    let db = SqliteDbStore()
    var newRipa = ""
    var ripamaster:RipaTempMaster?
    var strIPAddress = ""
    
    // var ripamaster = [RipaTempMaster]()
    
    func updateActvityOffline(){
        
        let userDefaults = UserDefaults.standard
        let isUpdate = userDefaults.string(forKey: "isOffline")
        
        if isUpdate != "0" {
            return
        }
        db.openDatabase()
        
        //  let countForLastRipa = Int(db.checkEmptyTable(insertTableString: "ripaTempMasterTable WHERE syncStatus is 1 \(userId) order by declarationDate DESC"))
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
        
        // let timeTaken =  Date().calculateTime(from_date: ripamaster!.startDate, to_date:ripamaster!.endDate )
        
        ripaActivity = Ripaactivity(key: ripamaster!.key , custid: ripamaster!.custid , City:ripamaster!.city, date_time: ripamaster!.stopTime , userid:ripamaster!.userid , username:ripamaster!.username, Notes:ripamaster!.note, latitude:ripamaster!.lat, longitude:ripamaster!.long, start_date:ripamaster!.startDate, end_date:ripamaster!.endDate, deviceid:Int(ripamaster!.deviceid) ?? 0, Location:ripamaster!.location, officer_experience: previewModel.calculateYearOfExp(), is_K_12_Student:ripamaster!.is_K_12_Student, CreatedBy:ripamaster!.CreatedBy, ip_address:previewModel.strIPAddress, stop_date:ripamaster!.stopDate , stop_time:ripamaster!.stopTime, stop_duration:ripamaster!.stopDuration, app_version:previewModel.appVersion!, platform:"ios", traffic_id:ripamaster!.skeletonID, activity_status_id: "1", access_token: AppManager.getLastSavedLoginDetails()?.result?.access_token ?? "", timetaken:ripamaster!.timeTaken, citation_number: ripamaster!.citationNumber, county_id: ripamaster!.countyId, time_duration_enable: AppConstants.ripaTimeDuration, call_number: ripamaster!.callNumber, onscene_time: ripamaster!.onsceneTime , clear_time_of_the_Offrcer: ripamaster!.clearTimeOfOfficer, overall_call_clear_time: ripamaster!.overallCallClearTime, call_type: ripamaster!.callType, unitId: ripamaster!.unitId, zone: ripamaster!.zone, ripaPersons:[])
        
        if ripamaster!.status == "Created"{
            ripaActivity?.activity_status_id = "7"
        }
        
        print("Hello, \(personArray)!")
        
        createPersonsDict(personArray: personArray, ripaActivity: ripaActivity!, statusId: ripaActivity?.activity_status_id ?? "1")
        let updateRipa:UpdateRipa =  updateRipaParam()
        submitParam(params: updateRipa, toSave: false)
        
    }
    
    
    
    var updateResopnseArray = [RipaResponse]()
    
    func createPersonsDict(personArray:[[String: Any]] ,ripaActivity:Ripaactivity ,statusId:String) {
        var isSchoolSelected = ""
        
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
            
            let address = previewModel.createObj(mainQuestId: "21" , ripaID: "21", optionValue: ripaActivity.Location, physical_attribute: "")
            address.isSelected = true
            
            for question in questArray{
                
                if question.question_code == "C6"{
                    print(question.question)
                }
                
                if question.question_code == "25"{
                    continue
                }
                
                if question.question_code == "2"{
                    
                    // let timeTaken = Date().calculateTime(from_date: ripaActivity.start_date , to_date: ripaActivity.end_date )
                    let obj = RipaResponse(question_id: question.id, response: ripaActivity.timetaken, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: "", key: ripaActivity.key , personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id)
                    updateResopnseArray.append(obj)
                    continue
                }
                
                
                
                // FOR NON SELECTED OPTIONALS
                if question.is_required == "0" && question.visible_question == "1"{
                    let selectedOptionalArray =  question.questionoptions!.filter { $0.isSelected }
                    if selectedOptionalArray.count < 1{
                        let obj = RipaResponse(question_id: question.id, response: "", internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: "", key: ripaActivity.key , personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: question.id, order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id)
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                
                if question.question_code == "22"{
                    let exp = previewModel.calculateYearOfExp()
                    let obj = RipaResponse(question_id: question.id, response: exp, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: "", key: ripaActivity.key, personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "", order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id)
                    updateResopnseArray.append(obj)
                    continue
                }
                
                
                
                if question.question_code == "C24"{
                   // if isSchoolSelected == "Yes" || ripaActivity.is_K_12_Student == "1" {
                    if isSchoolSelected == "Yes" {
                        let option = question.questionoptions!.first
                        let orderNo = option!.order_number
                        let obj = RipaResponse(question_id: option!.ripa_id, response: option?.option_value, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: address.physical_attribute, key: ripaActivity.key, personId: String(i) , description: "", question_code: option!.question_code_for_cascading_id, cascade_ques_id: option!.cascade_ripa_id, order_number: option!.order_number, option_id: option!.option_id, cascade_option_id: "", main_question_id: address.main_question_id)
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                
                if question.question_code == "5"{
                    
                    address.isSelected = true
                    address.main_question_id = question.id
                    address.ripa_id = question.id
                    
                    let obj = RipaResponse(question_id: question.id, response: address.option_value, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: address.physical_attribute, key: ripaActivity.key, personId: String(i) , description: address.optionDescription, question_code: question.question_code, cascade_ques_id: "", order_number: question.order_number, option_id: "", cascade_option_id: "", main_question_id: question.id)
                    
                    updateResopnseArray.append(obj)
                    //continue
                }
                
                for options in selectedOptionsArray{
                    for opt in options{
                        if  opt.ripa_id == question.id {
                            var obj:RipaResponse?
                            
                            if opt.option_id == "227"{
                                isSchoolSelected = "Yes"
                            }
                            
                            if question.question_code == "C6" || question.question_code == "C7" || question.question_code == "C26" || question.question_code == "C25"{
                                obj = RipaResponse(question_id: opt.mainQuestId, response: opt.option_value, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: opt.physical_attribute, key: ripaActivity.key, personId: String(i) , description: opt.optionDescription, question_code: question.question_code, cascade_ques_id: opt.ripa_id, order_number: opt.mainQuestOrder , option_id: opt.option_id, cascade_option_id: opt.option_id, main_question_id: opt.main_question_id)
                            }
                            else{
                                obj = RipaResponse(question_id: question.id, response: opt.option_value, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: opt.physical_attribute, key: ripaActivity.key, personId: String(i) , description: opt.optionDescription, question_code: opt.question_code_for_cascading_id, cascade_ques_id: opt.cascade_ripa_id, order_number:  opt.mainQuestOrder , option_id: opt.option_id, cascade_option_id: opt.option_id, main_question_id: opt.main_question_id)
                                
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
            
            
            let obj = RipaPerson(CreatedBy: String(ripaActivity.userid), person_name: "P"+String(i), key: ripaActivity.key,date: ripaActivity.stop_date,time: ripaActivity.stop_time, duration: ripaActivity.stop_duration, ripa_response :  updateResopnseArray.sorted(by: {Int($0.order_number)! < Int($1.order_number)! }))
            
            ripaPersonsArray.append(obj)
            i += 1
            
        }
        ripaActivityDict(statusId: statusId)
    }
    
    
    
    
    func ripaActivityDict(statusId:String){
        ripaActivityArray.append(ripaActivity!)
    }
    
    
    
    
    func submitParam(params:UpdateRipa , toSave:Bool){
        let encodedData = try! JSONEncoder().encode(params)
        let jsonString = String(data: encodedData,
                                encoding: .utf8)
        print(jsonString!)
        let dict = previewModel.convertStringToDictionary(text: jsonString!)
        // saveToDB(updateRipa :ripaActivity , isUpdate: true, syncSccessful: "")
        
        submitAnswers(params: dict!)
    }
    
    
    
    func submitAnswers(params:[String:Any]) {
        
        // AppUtility.showProgress(nil, title:nil)
        var URL:String?
        
        
        URL = AppConstants.Api.updateRipa
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
        var wer:String = ripaActivity!.key
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
