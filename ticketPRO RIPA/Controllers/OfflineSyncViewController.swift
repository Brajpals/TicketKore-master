//
//  OfflineSyncViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 6/15/21.
//

import UIKit
import SwiftyJSON


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
        
        ripaActivity = Ripaactivity(key: ripamaster!.key , custid: ripamaster!.custid , City: ripamaster!.city, date_time:  dateInFormat, userid:ripamaster!.userid , username:ripamaster!.username, Notes:ripamaster!.note, latitude:ripamaster!.lat, longitude:ripamaster!.long, start_date:ripamaster!.startDate, end_date:ripamaster!.endDate, deviceid:Int(ripamaster!.deviceid) ?? 0, Location:ripamaster!.location, officer_experience: previewModel.calculateYearOfExp(), is_K_12_Student:ripamaster!.is_K_12_Student, CreatedBy:ripamaster!.CreatedBy, ip_address:previewModel.strIPAddress, stop_date:ripamaster!.stopDate , stop_time:ripamaster!.stopTime, stop_duration:ripamaster!.stopDuration, app_version:previewModel.appVersion!, platform:"ios", traffic_id:ripamaster!.skeletonID, activity_status_id: "1", access_token: AppManager.getLastSavedLoginDetails()?.result?.access_token ?? "", timetaken:ripamaster!.timeTaken, citation_number: ripamaster!.citationNumber, county_id: ripamaster!.countyId, activity_id: ripamaster?.activityId ?? "", time_duration_enable: AppConstants.ripaTimeDuration, call_number: ripamaster!.callNumber, onscene_time: ripamaster!.onsceneTime , clear_time_of_the_Offrcer: ripamaster!.clearTimeOfOfficer, overall_call_clear_time: ripamaster!.overallCallClearTime, call_type: ripamaster!.callType, unitId: ripamaster!.unitId, zone: ripamaster!.zone, ripaPersons:[], supervisorId: "", ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini)
        
        if ripamaster!.status == "Created"{
            ripaActivity?.activity_status_id = "7"
        }
        
        print("Hello, \(personArray)!")
        
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
            
            let address = previewModel.createObj(mainQuestId: "21" , ripaID: "21", optionValue: ripaActivity.Location, physical_attribute: "")
            address.isSelected = true
            
            
            for question in questArray{
                
//                if question.question_code == "C6"{
//                    print(question.question)
//                }
                
                if question.question_code == "25"{
                    continue
                }
                
                if question.question_code == "2"{
                    let obj = RipaResponse(question_id: question.id, response: ripaActivity.timetaken, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: "", key: ripaActivity.key , personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "", cascade_option_id: "0", main_question_id: question.id, supervisorId: "", other_assignment_value: "", activity_id: AppConstants.activity_id, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini)
                    updateResopnseArray.append(obj)
                }
                
                
              
                // FOR NON SELECTED OPTIONALS
                if question.is_required == "0" && question.visible_question == "1"{
                    let selectedOptionalArray =  question.questionoptions!.filter { $0.isSelected }
                    if selectedOptionalArray.count < 1{
                        var obj = RipaResponse(question_id: question.id, response: "", internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: "", key:AppConstants.key , personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: question.id, order_number: question.order_number, option_id: "0", cascade_option_id: "0", main_question_id: question.id, supervisorId: "", other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini)
                        obj.activity_id = AppConstants.activityID
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                if question.question_code == "23"{
                    var ripaRes : RipaResponse = ripaResponse
                    ripaRes.activity_id = AppConstants.activityID
                    updateResopnseArray.append(ripaRes)
                    continue
                }
                
                if question.question_code == "22"{
                    let exp = previewModel.calculateYearOfExp()
                    var obj = RipaResponse(question_id: question.id, response: exp, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: "", key:AppConstants.key, personId: String(i) , description: "", question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "0", cascade_option_id: "0", main_question_id: question.id, supervisorId: "", other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini)
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
                        
                       // let orderNo = option!.order_number
                        var obj = RipaResponse(question_id: option!.ripa_id, response: option!.option_value, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: address.physical_attribute, key: AppConstants.key, personId: String(i) , description: "", question_code: option!.question_code_for_cascading_id, cascade_ques_id: option!.cascade_ripa_id, order_number: option!.order_number, option_id: optionId, cascade_option_id: "0", main_question_id: address.main_question_id, supervisorId: "", other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini)
                        obj.activity_id = AppConstants.activityID
                        updateResopnseArray.append(obj)
                        continue
                    }
                }
                
                
                if question.question_code == "5"{
                    address.isSelected = true
                    address.main_question_id = question.id
                    address.ripa_id = question.id
                    
                    var obj = RipaResponse(question_id: question.id, response: address.option_value, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: address.physical_attribute, key: AppConstants.key, personId: String(i) , description: address.optionDescription, question_code: question.question_code, cascade_ques_id: "0", order_number: question.order_number, option_id: "0", cascade_option_id: "0", main_question_id: question.id, supervisorId: "", other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini)
                    obj.activity_id = AppConstants.activityID
                    updateResopnseArray.append(obj)
                    //continue
                }
                
                for options in selectedOptionsArray{
                    for opt in options{
                        if  opt.ripa_id == question.id {
                            var obj:RipaResponse?
                            
                            var optionId : String = "0"
                             let opId = opt.option_id
                            if opId.count > 0 {
                                optionId = opId
                            }
                            
                            if question.question_code == "C6" || question.question_code == "C7" || question.question_code == "C26" || question.question_code == "C25"{
                                obj = RipaResponse(question_id: opt.mainQuestId, response: opt.option_value, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: opt.physical_attribute, key: AppConstants.key, personId: String(i) , description: opt.optionDescription, question_code: question.question_code, cascade_ques_id: opt.ripa_id, order_number: opt.mainQuestOrder , option_id: optionId, cascade_option_id: opt.option_id, main_question_id: opt.main_question_id, supervisorId: "", other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini)
                            }
                            else{
                                obj = RipaResponse(question_id: question.id, response: opt.option_value, internal: question.internal, userid: String(ripaActivity.userid), question: question.question, CreatedBy: String(ripaActivity.userid), physical_attribute: opt.physical_attribute, key: AppConstants.key, personId: String(i) , description: opt.optionDescription, question_code: opt.question_code_for_cascading_id, cascade_ques_id: opt.cascade_ripa_id, order_number:  opt.mainQuestOrder , option_id: optionId, cascade_option_id: opt.option_id, main_question_id: opt.main_question_id, supervisorId: "", other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini)
                                
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
                            
                            if obj?.question_code == "" || obj?.question_code == "0"{
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
                            obj?.activity_id = AppConstants.activityID
                            updateResopnseArray.append(obj!)
                        }
                    }
                }
            }
            
            
            let obj = RipaPerson(CreatedBy: String(ripaActivity.userid), person_name: "P"+String(i), key: AppConstants.key,date: AppConstants.date,time: AppConstants.time,duration: AppConstants.duration, ripa_response :  updateResopnseArray.sorted(by: {Int($0.order_number)! < Int($1.order_number)! }))
           
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
        
        let ripaRes = RipaResponse(question_id: questionId, response: rep, internal: inter, userid: idUser, question: questn, CreatedBy: cDate, physical_attribute: attri, key: keyS, personId: pId, description: "", question_code: qCode, cascade_ques_id: "0", order_number: orderN, option_id: opId, cascade_option_id: "0", main_question_id: mId, supervisorId: supId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version : os.getFullVersion(), is_trainee: traini)
        
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
