 
 
 import Foundation
 import SwiftyJSON
 import CoreLocation
 import MapKit
 
 
 
 protocol QuestionsDelegate: class {
    func proceedToNextScreen(questionArray:[QuestionResult1])
    func proceedToSavedListScreen()
    func setStatusCount(countArray:[CountResult])
    // func errorLogout(message:String,status:Int)
 }
 
 protocol GetListDelegate: class {
    func getList(success:String)
 }
 
 
 class DashboardViewModel {
    
    weak var questiondelegate : QuestionsDelegate?
    weak var getListDelegate : GetListDelegate?
    
    var forListRefresh = false
    
    let db = SqliteDbStore()
    
    let custId = AppManager.getLastSavedLoginDetails()?.result?.custid
    let userId = AppManager.getLastSavedLoginDetails()?.result?.userid
    let countyId = AppManager.getLastSavedLoginDetails()?.result?.county_id
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    //Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    let id = AppManager.getLastSavedLoginDetails()?.id
    
    
    
    
    
    func getParam(cityId:String,method:String )->[String:Any]{
        let token = AppManager.getLastSavedLoginDetails()?.result?.access_token
        var param:[String : Any] = ["custid":custId! ,"city_id":cityId, "county_id":countyId!,"access_token": token ?? ""]
        if method == "ripaLocations"{
            param = ["custid":"" ,"city_id":"", "countyId":"","access_token": token ?? ""]
        }
        else if method == "RipaSchools"{
            param = ["custid":"" ,"city_id":"", "countyid":"","access_token": token ?? ""]
        }
        else if method == "ripaCities"{
            param = ["custid":"", "county_id":"","access_token": token ?? ""]
        }
        else if  method == "ripaEducation"{
            param = ["access_token": token ?? ""]
        }
        let params:[String : Any] = ["id":id!, "method":method, "params": param, "jsonrpc": "2.0"]
        return params
    }
    
    
    func setCityParam() {
        db.openDatabase()
        db.UpdateDatabase()
        db.createTable(insertTableString: db.createCityTable)
        if forListRefresh == true{
            db.deleteAllfrom(table: "cityTable")
        }
        let count = Int(db.checkEmptyTable(insertTableString: "cityTable"))
        if count == 0 {
            let params = getParam(cityId:"", method: "ripaCities")
            getData(params: params, method: "Cities")
            return
        }
        if forListRefresh == false{
            setLocationParam()
        }
    }
    
    
    func setLocationParam() {
        db.openDatabase()
        db.createTable(insertTableString: db.createLocationTable)
        if forListRefresh == true{
            db.deleteAllfrom(table: "locationTable")
        }
        let count = Int(db.checkEmptyTable(insertTableString: "locationTable"))
        if count == 0 {
            let params = getParam(cityId: "", method: "ripaLocations")
            getData(params: params, method: "Location")
            print(params)
            return
        }
        if forListRefresh == false{
            setViolationsParam()
        }
    }
    
    
    func setViolationsParam() {
        db.openDatabase()
        db.createTable(insertTableString: db.createViolationTable)
        if forListRefresh == true{
            db.deleteAllfrom(table: "violationTable")
        }
        let count = Int(db.checkEmptyTable(insertTableString: "violationTable"))
        if count == 0 {
            let params = getParam(cityId: "", method: "ripaNewViolationsCode")
            getData(params: params, method: "Violations")
            print(params)
            return
        }
        if forListRefresh == false{
            setSchoolParam()
        }
    }
    
    
    func setSchoolParam(){
        db.openDatabase()
        db.createTable(insertTableString: db.createSchoolTable)
        if forListRefresh == true{
            db.deleteAllfrom(table: "schoolTable")
        }
        let count = Int(db.checkEmptyTable(insertTableString: "schoolTable"))
        if count == 0 {
            let params = getParam(cityId: "", method: "RipaSchools")
            getData(params: params, method: "School")
            print(params)
            return
        }
        if forListRefresh == false{
            setEducationParam()
        }
    }
    
    
    func setEducationParam(){
        db.openDatabase()
        db.createTable(insertTableString: db.createEducationCodeTable)
        if forListRefresh == true{
            db.deleteAllfrom(table: "educationCodeTable")
        }
        let count = Int(db.checkEmptyTable(insertTableString: "educationCodeTable"))
        if count == 0 {
            let params = getParam(cityId: "", method: "ripaEducation")
            getData(params: params, method: "Education")
            print(params)
            return
        }
    }
    
    
    func getData(params: [String:Any],method:String) {
        //  AppUtility.showProgress(nil, title: "Getting" + method)
        var URL:String?
        
        URL = AppConstants.Api.otpRequest
        
        ApiManager.getRipaData(params: params, method: method, methodTyPe: .post, url: URL!, completion: { json,successmsg   in
            AppUtility.hideProgress(nil)
            
            if self.forListRefresh == false{
                if method == "Cities"{
                    self.setLocationParam()
                }
                if method == "Location"{
                    self.setViolationsParam()
                }
                if method == "Violations"{
                    self.setSchoolParam()
                }
                if method == "School"{
                    self.setEducationParam()
                }
            }
            self.getListDelegate?.getList(success:successmsg)
        })
        { (error, code, message) in
            // AppUtility.hideProgress(nil)
            if let errorMessage = message {
                //AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
            }
        }
    }
    
    
    
    func getNewRipa(){
        let param:[String : Any] = ["custid": custId!,"access_token": AppManager.getLastSavedLoginDetails()?.result?.access_token ?? ""]
        let params:[String : Any] =  ["id":id!, "method":"ripaQuestion", "params":param ,"jsonrpc": "2.0"]
        //let params = EnrollmentUser.newRipaQuestionsData(newenroll:enrolluser)
        print(params)
        getQuestionsData(params: params)
    }
    
    
    
    
    
    
    func getQuestionsData(params: [String:Any]) {
        AppUtility.showProgress(nil, title: nil)
        var URL:String?
        
        URL = AppConstants.Api.questions
        
        if Reachability.isConnectedToNetwork(){
            ApiManager.getRipaQuestions(params: params, methodTyPe: .post, url: URL!, completion: { [self] (success,message) in
                AppUtility.hideProgress(nil)
                
                if message == "Success"{
                    let data =  DataManager.shared.newRipaQuestion
                    let errorMsg = data?.result![0].serviceError
                    
                    if data?.result != nil && data?.result![0].serviceError == ""{
                        let questArray:[QuestionResult] = (data?.result)!
                        
                        
                        db.deleteAllfrom(table: db.AllQues)
                        db.deleteAllfrom(table: db.AllOptions)
                        
                        db.createTable(insertTableString: db.createQuestionsTable)
                        db.createTable(insertTableString: db.createOptionsTable)
                        
                        for questions in questArray{
                            let quest = QuestionResult1(id: questions.id, custid: questions.custid, question: questions.question, question_info: questions.question_info,question_key: questions.question_key,question_code:questions.question_code, questionTypeId: questions.questionTypeId, inputTypeId: questions.inputTypeId, is_add_value: questions.is_add_value, internal: questions.`internal`, is_required: questions.is_required, isAddtion: questions.isAddtion, isCascade_Question: questions.isCascade_Question, ripa_group_id: questions.ripa_group_id, isDescription_Required: questions.isDescription_Required, common_question: questions.common_question, editable_question: questions.editable_question, visible_question: questions.visible_question, order_number: questions.order_number, is_active: questions.is_active, CreatedBy: questions.createdBy, CreatedOn: questions.createdOn, UpdatedBy:questions.updatedBy,UpdatedOn:questions.updatedOn, inputTypeCode:questions.inputTypeCode, questionTypeCode:questions.questionTypeCode, groupName:questions.groupName, questionoptions: [])
                            
                            db.insertQuestion(question :quest, tableName:db.AllQues)
                            
                            for options in questions.questionoptions!{
                                let opt = Questionoptions1(mainQuestId: questions.id, mainQuestOrder: questions.order_number , option_id: options.option_id, ripa_id: options.ripa_id, custid: options.custid, option_value: options.option_value, cascade_ripa_id: options.cascade_ripa_id,isK_12School: options.isK_12School, isHideQuesText: options.isHideQuesText, order_number: options.order_number, createdBy: options.createdBy, createdOn: options.createdOn, updatedBy: options.updatedBy, updatedOn: options.updatedOn , isSelected:false, isAddtion : options.isAddtion,isDescription_Required : options.isDescription_Required,inputTypeCode : options.inputTypeCode,questionTypeCode : options.questionTypeCode,tag:options.tag, physical_attribute:options.physical_attribute, default_value: options.default_value, optionDescription: options.description, question_code_for_cascading_id: options.question_code_for_cascading_id, isQuestionMandatory: options.isQuestionMandatory, isQuestionDescriptionReq: options.isQuestionDescriptionReq, main_question_id: options.main_question_id, isExpanded: false, questionoptions: [])
                                if opt.default_value == "1" || opt.option_id == "170"{
                                    opt.isSelected = true
                                }
                                db.insertOptions(options: opt, tableName: db.AllOptions, personID: "", key: "")
                                
                            }
                        }
                        getNewRipaFromDB()
                    }
                    else{
                        let code = (data?.result![0].errorStatusCode)!
                        DashboardViewModel.showAlertWithProperty("Alert", messageString: errorMsg!, code: code)
                        //AppUtility.showAlertWithProperty("Alert", messageString: "Unauthorised Login")
                    }
                }
            })
            { (error, code, message) in
                AppUtility.hideProgress(nil)
                self.getNewRipaFromDB()
                AppUtility.showAlertWithProperty("Alert", messageString: error!.localizedDescription)
                if let errorMessage = message {
                    AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
                }
            }
        }
        
        else{
            print("Internet Connection not Available!")
            AppUtility.hideProgress(nil)
            AppUtility.showAlertWithProperty("Alert", messageString: "Internet connection not available.")
            getNewRipaFromDB()
        }
        
    }
    
    
    
    func getCount(){
        let param:[String : Any] = ["userId": userId!,"access_token": AppManager.getLastSavedLoginDetails()?.result?.access_token ?? ""]
        let params:[String : Any] =  ["id":id!, "method":"allStatusCountInRipaActivity", "params":param ,"jsonrpc": "2.0"]
        //let params = EnrollmentUser.newRipaQuestionsData(newenroll:enrolluser)
        print(params)
        getCountData(params: params)
    }
    
    
    func getCountData(params: [String:Any]) {
        //  AppUtility.showProgress(nil, title: "Getting" + method)
        var URL:String?
        
        URL = AppConstants.Api.otpRequest
        
        ApiManager.getCount(params: params, methodTyPe: .post, url: URL!, completion: { json,successmsg   in
            AppUtility.hideProgress(nil)
            if successmsg == "Success"{
                if let json = try? JSON(data: json as! Data) {
                    let errorMsg = json["result"][0]["serviceError"].stringValue
                    var countArr = [CountResult]()
                    if  errorMsg == ""{
                        for item in json["result"].arrayValue {
                            let countObj = CountResult(total: item["Total"].stringValue, statusID: item["status_id"].stringValue, statusCode: item["status_code"].stringValue, ripaActivityStatusName: item["ripa_activity_status_Name"].stringValue)
                            countArr.append(countObj)
                        }
                        self.questiondelegate?.setStatusCount(countArray:countArr)
                    }
                    else{
                        let code = json["result"][0]["status"].intValue
                        DashboardViewModel.showAlertWithProperty("Alert", messageString: errorMsg, code:code )
                        // self.questiondelegate?.errorLogout(message:error,status:code)
                    }
                }
            }
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            
        }
        
    }
    
    
    func getCountyList() {
        //  AppUtility.showProgress(nil, title: "Getting" + method)
        var URL:String?
        
        URL = AppConstants.BaseURL.URL
        db.createTable(insertTableString: db.createCountyTable)
        ApiManager.getCountyList(methodTyPe: .post, url: URL!, completion: { [self] json,successmsg   in
            AppUtility.hideProgress(nil)
            if successmsg == "Success"{
                if let json = try? JSON(data: json as! Data) {
                    let errorMsg = json["result"][0]["serviceError"].stringValue
                     if  errorMsg == ""{
                        db.deleteAllfrom(table: "countyTable")
                        for item in json["result"].arrayValue {
                         // var countyList = [CountyResult]()
                            
                            let county = CountyResult(countyID: item["county_id"].stringValue, countyName: (item["county_name"].stringValue).uppercased(), courtHolidays: item["courtHolidays"].stringValue, webAddress: item["webAddress"].stringValue, isSelected: false)
                             //countyList.append(county)
                             
                             db.insertCounty(county: county)
                          }
                     }
                    else{
                       // let code = json["result"][0]["status"].intValue
                       // DashboardViewModel.showAlertWithProperty("Alert", messageString: errorMsg, code:code )
                     }
                }
              }
            getFeaturesList()
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            self.getFeaturesList()
         }
     }
    
    
    
    
    func getFeaturesList() {
        var URL:String?
        URL = AppConstants.BaseURL.URL
        db.createTable(insertTableString: db.createFeatureTable)
        
        ApiManager.getFeaturesList(methodTyPe: .post, url: URL!, completion: { [self] json,successmsg   in
            AppUtility.hideProgress(nil)
            if successmsg == "Success"{
                if let json = try? JSON(data: json as! Data) {
                    let errorMsg = json["result"][0]["serviceError"].stringValue
                     if  errorMsg == ""{
                        db.deleteAllfrom(table: "featureTable")
                        for item in json["result"].arrayValue {
                         // var countyList = [CountyResult]()
                            
                            let feature = FeaturesResult(featureID: item["feature_id"].stringValue, custid: item["custid"].stringValue, feature: item["feature"].stringValue, admin: item["admin"].stringValue, officer: item["officer"].stringValue, value: item["value"].stringValue, isActive: item["is_active"].stringValue, orderNumber: item["order_number"].stringValue, moduleName: item["module_name"].stringValue, module: item["module"].stringValue)
                              
                             db.insertFeature(feature : feature)
                          }
                     }
                    else{
                       // let code = json["result"][0]["status"].intValue
                       // DashboardViewModel.showAlertWithProperty("Alert", messageString: errorMsg, code:code )
                     }
                }
             }
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
         }
        
        
        
    }
    
    
    
    
    
    class func showAlertWithProperty(_ title: String, messageString: String, code:Int) -> Void {
        let alertController = UIAlertController.init(title: title, message: messageString, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            if code == 0{
                AppManager.logout()
                UserDefaults.standard.set(false , forKey: "BiometricSet")
                AppConstants.bioLogin = "0"
                let story = UIStoryboard(name: "Main", bundle:nil)
                let vc = story.instantiateViewController(withIdentifier: "EnrollementViewController") as! EnrollementViewController
                UIApplication.shared.windows.first?.rootViewController = vc
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        })
        )
        DispatchQueue.main.async{
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    func getNewRipaFromDB()  {
        let allQuests = db.getQuestions(tableName: "QuestionTable", getcascadeQuest: 0)
        if (allQuests != nil){
            let allQuestionWithOptions = db.getQuestionOptions(tableName: "OptionTable", optionFor: "", person_name: "", key: "")
            self.questiondelegate?.proceedToNextScreen(questionArray: allQuestionWithOptions!)
        }
    }
    
    
    //    func getNewRipaFromSavedOptionDB()->[QuestionResult1]  {
    //        var allQuestionWithOptions = [QuestionResult1]()
    //        let allQuests = db.getQuestions(tableName: "QuestionTable", getcascadeQuest: 0)
    //        if (allQuests != nil){
    //            allQuestionWithOptions = db.getQuestionOptions(tableName: "OptionTable", optionFor: "", person_name: "", key: "")!
    //         }
    //        return allQuestionWithOptions
    //    }
    
    
    func setKey(){
        let key : String? = String(Date().millisecondsSince1970)
        AppConstants.key = key!
    }
    
    
    func removeThisRipa(){
        db.deleteAllfrom(table: "ripaTempMasterTable WHERE key = \(AppConstants.key)")
        db.deleteAllfrom(table: "saveRipaPersonTable WHERE key = \(AppConstants.key)")
        db.deleteAllfrom(table: "useSaveRipaOptionsTable WHERE key = \(AppConstants.key)")
    }
    
    
    func getUseSavedRipa(key:String)->[[String: Any]]  {
        db.openDatabase()
        var personArray: [[String: Any]] = []
        var personDict:[String:Any]?
        var selectedOptionsArray=[[Questionoptions1]]()
        db.createTable(insertTableString: db.createSaveRipaPersonTable)
        let count = Int(db.checkEmptyTable(insertTableString: "saveRipaPersonTable"))
        if count! > 0 {
            let persons = db.getRipaPerson(tableName: "saveRipaPersonTable WHERE key = \(key)" )!
            
            for person in persons{
                personDict?.removeAll()
                selectedOptionsArray.removeAll()
                
                AppConstants.date = person.date
                AppConstants.time = person.time
                AppConstants.duration = person.duration
                AppConstants.key = person.key
                
                db.getQuestions(tableName: "QuestionTable", getcascadeQuest: 0)
                let questionWithOptionArray = db.getQuestionOptions(tableName: "useSaveRipaOptionsTable", optionFor: "UseSaveRipa", person_name: "\"\(person.person_name)\"", key: "\"\(person.key)\"")
                
                
                
                db.getQuestions(tableName: "QuestionTable", getcascadeQuest: 1)
                let cascadeQuestionWithOptionArray = db.getQuestionOptions(tableName: "useSaveRipaOptionsTable", optionFor: "UseSaveRipa", person_name: "\"\(person.person_name)\"", key: "\"\(person.key)\"" )
                
                
                let queryString = "SELECT * FROM useSaveRipaOptionsTable WHERE person_name = \"\(person.person_name)\" AND isSelected = \"true\" AND key = \"\(person.key)\" "
                
                
                let selectedOptions:[Questionoptions1] = db.getOptions(queryString: queryString)!
                selectedOptionsArray.append(selectedOptions)
                
                
                personDict = ["PersonType":"","SelectedOption":selectedOptionsArray,"QuestionArray":questionWithOptionArray!,"CascadeQuestionArray":cascadeQuestionWithOptionArray!]
                
                
                personArray.append(personDict!)
                
                if AppConstants.status == "LastRipa" || AppConstants.status == "Template"{
                    break
                }
            }
        }
        return personArray
        
    }
    
    
    func deleteRipa() {
        
    }
    
    
    //"4031"
    func getTrafficPram(){
        let param:[String : Any] = ["userid": userId!]
        let params:[String : Any] =  ["id":id!, "method":"ripaTrafficSkeletonData", "params":param ,"jsonrpc": "2.0"]
        //let params = EnrollmentUser.newRipaQuestionsData(newenroll:enrolluser)
        print(params)
        getTarfficData(params: params)
    }
    
    
    
    func getDatefromStopTime(date: String){
        if date != ""{
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            let showDate = inputFormatter.date(from: date)
            inputFormatter.dateFormat = "MM/dd/yyyy"
            var resultString = inputFormatter.string(from: showDate!)
            AppConstants.date = resultString
            
            inputFormatter.dateFormat = "HH:mm"
            resultString = inputFormatter.string(from: showDate!)
            AppConstants.time = resultString
        }
    }
    
    
    func convertDateFormater(date: String)->String{
        var resultString = ""
        let date = date.components(separatedBy: ("."))[0]
        if date != ""{
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let showDate = inputFormatter.date(from: date)
            inputFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            resultString = inputFormatter.string(from: showDate!)
        }
        return resultString
    }
    
    func getTime(date: String)->String{
        var timeString = ""
        let date = date.components(separatedBy: ("."))[0]
        if date != ""{
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let showDate = inputFormatter.date(from: date)
            inputFormatter.dateFormat = "HH:mm"
            timeString = inputFormatter.string(from: showDate!)
        }
        return timeString
    }
    
    
    
    func getTarfficData(params: [String:Any]) {
        AppUtility.showProgress(nil, title: nil)
        var URL:String?
        
        URL = AppConstants.Api.questions
        
        if Reachability.isConnectedToNetwork(){
            db.openDatabase()
            ApiManager.getSkeletonData(params: params, methodTyPe: .post, url: URL!, completion: { [self](jsonObj,message) in
                AppUtility.hideProgress(nil)
                db.createTable(insertTableString: db.createRipaTempMasterTable)
                if message == "Success"{
                    
                    if let json = try? JSON(data: jsonObj as! Data) {
                        let errorMsg = json["result"][0]["serviceError"].stringValue
                        
                        if  errorMsg == ""{
                            let string = "\"\("Created")\""
                            
                            db.deleteAllfrom(table: "ripaTempMasterTable WHERE status = \(string)")
                            for item in json["result"].arrayValue {
                                
                                var key = String(Date().millisecondsSince1970)
                                
                                key = key + random(digits: 4)
                                
                                let duration = Date().calculateTime(from_date: convertDateFormater(date: item["ticket_date"].stringValue), to_date: (convertDateFormater(date: item["declaration_date"].stringValue)))
                                
                                let ripas = RipaTempMaster(key:key,
                                                           skeletonID: item["skeleton_id"].stringValue, activityId: "",
                                                           custid: item["custid"].stringValue,
                                                           userid: item["userid"].stringValue,
                                                           username: item["username"].stringValue,
                                                           rmsid: item["rmsid"].stringValue,
                                                           phoneNumber: item["phone_number"].stringValue,
                                                           location: item["location"].stringValue,
                                                           city: item["city"].stringValue,
                                                           street: item["location"].stringValue,
                                                           block: "",
                                                           intersectionStreet:"",
                                                           note: item["notes"].stringValue,
                                                           activity_notes: "",
                                                           CreatedBy: item["CreatedBy"].stringValue,
                                                           ticketDate: convertDateFormater(date: item["ticket_date"].stringValue) ,
                                                           declarationDate: convertDateFormater(date: item["declaration_date"].stringValue),
                                                           violation: item["violation"].stringValue,
                                                           violationCode: item["violation_code"].stringValue,
                                                           violationType: "",
                                                           violationID: item["violation_id"].stringValue,
                                                           offenceCode: item["offence_code"].stringValue,
                                                           email: item["email"].stringValue,
                                                           createdOn: item["CreatedOn"].stringValue,
                                                           updatedBy: item["UpdatedBy"].stringValue,
                                                           updatedOn: item["UpdatedOn"].stringValue,
                                                           citationNumber: item["citation_number"].stringValue,
                                                           status: "Created",
                                                           mainStatus: item["status"].stringValue,
                                                           statusChnageDate: convertDateFormater(date: item["status_chnage_date"].stringValue) ,
                                                           ripaTempId: "",
                                                           tempType: "",
                                                           stopDate: convertDateFormater(date: item["ticket_date"].stringValue) ,
                                                           stopTime: getTime(date: item["ticket_date"].stringValue),
                                                           stopDuration: duration,
                                                           rejectedURL:"", syncStatus: "",startDate:"",endDate:"",is_K_12_Student:"", lat:"" ,long: "", timeTaken: "0", countyId: "", deviceid: item["device_id"].stringValue,
                                                           
                                                           callNumber: item["call_number"].stringValue, callTime: "", onsceneTime: item["onscene_time"].stringValue, clearTimeOfOfficer: item["clear_time_of_the_Offrcer"].stringValue, overallCallClearTime: item["overall_call_clear_time"].stringValue, callType: item["call_type"].stringValue, unitId: item["unitId"].stringValue, zone: item["zone"].stringValue )
                                
                                db.insertRipaTempMaster(ripaResponse: ripas, tableName: db.ripaTempMaster)
                            }
                             
                        }
                        else{
                            let code = json["result"][0]["status"].intValue
                            if code == 0{
                                DashboardViewModel.showAlertWithProperty("Alert", messageString: errorMsg, code:code )
                                return
                            }
                        }
                    }
                    getallRipaWith_CE_ER_Pram()
                    return
                    //   self.questiondelegate?.proceedToSavedListScreen()
                }
                else{
                    getallRipaWith_CE_ER_Pram()
                    return
                    //   self.questiondelegate?.proceedToSavedListScreen()
                }
                
            })
            { (error, code, message) in
                AppUtility.hideProgress(nil)
                self.getallRipaWith_CE_ER_Pram()
                return
//                if let errorMessage = message {
//                  //  AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
//                }
//                else if code == 200{
//                    AppUtility.showAlertWithProperty("Alert", messageString: "Server Error. Try again.")
//                }
//                else{
//                    AppUtility.showAlertWithProperty("Alert", messageString: "Something went wrong.Please Try Again")
//                }
            }
        }
        
        else{
            print("Internet Connection not Available!")
            AppUtility.hideProgress(nil)
            AppUtility.showAlertWithProperty("Alert", messageString: "Internet connection not available.")
            
        }
        
    }
    
    
    //"4031"
    func getallRipaWith_CE_ER_Pram(){
        let param:[String : Any] = ["userid": userId!]
        let params:[String : Any] =  ["id":id!, "method":"allRipaWith_CE_ER", "params":param ,"jsonrpc": "2.0"]
        //let params = EnrollmentUser.newRipaQuestionsData(newenroll:enrolluser)
        print(params)
        getallRipaWith_CE_ER(params: params)
    }
    
    func getonlyTime(date: String)->String{
        var resultString = ""
        let date = date.components(separatedBy: ("."))[0]
        if date != ""{
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "HH:mm:ss"
            let showDate = inputFormatter.date(from: date)
            inputFormatter.dateFormat = "HH:mm"
            resultString = inputFormatter.string(from: showDate!)
        }
        return resultString
    }
    
    func getallRipaWith_CE_ER(params: [String:Any]) {
        AppUtility.showProgress(nil, title: nil)
        var URL:String?
        
        
        URL = AppConstants.Api.questions
        
        if Reachability.isConnectedToNetwork(){
            db.openDatabase()
            ApiManager.getAllRipaWith_CE_ER(params: params, methodTyPe: .post, url: URL!, completion: { [self](success,message) in
                AppUtility.hideProgress(nil)
                db.createTable(insertTableString: db.createRipaTempMasterTable)
                if message == "Success"{
                    
                    if let json = try? JSON(data: success as! Data) {
                        let errorMsg = json["result"]["serviceError"].stringValue
                            //json["result"][0]["serviceError"].stringValue
                        
                        if  errorMsg == ""{
                            let statusEdit = "\"Edit Required\""
                            let statusSaved = "\"Saved\""
                            let pendingReview = "\"Pending Review\""
                            let approved = "\"Approved\""
 
                            db.deleteAllfrom(table: "ripaTempMasterTable WHERE status = \(statusEdit)")
                            db.deleteAllfrom(table: "ripaTempMasterTable WHERE status = \(statusSaved)")
                            db.deleteAllfrom(table: "ripaTempMasterTable WHERE status = \(pendingReview)")
                            db.deleteAllfrom(table: "ripaTempMasterTable WHERE status = \(approved)")
                            
                            for item in json["result"]["activity"].arrayValue {
                                
                                let key = "\"\(item["devices_unique_no"].stringValue)\""
                                let statusResume = "\"Resume\""
                                
                                //                                if item["ripa_activity_status_Name"].stringValue == "Saved"{
                                //                                    continue
                                //                                }
                                
                                
                                let countForLastRipa = Int(db.checkEmptyTable(insertTableString: "ripaTempMasterTable WHERE status = \(statusResume) AND key = \(key)"))
                                
                                if countForLastRipa! > 0 && item["ripa_activity_status_Name"].stringValue == "Saved"{
                                    db.deleteAllfrom(table: "ripaTempMasterTable WHERE key = \(key)")
                                    db.deleteAllfrom(table: "saveRipaPersonTable WHERE key = \(key)")
                                    db.deleteAllfrom(table: "useSaveRipaOptionsTable WHERE key = \(key)")
                                    // continue
                                }
                                
                                
                                //  let status = "\"\(item["ripa_activity_status_Name"].stringValue)\""
                                
                                
                                let ripas = RipaTempMaster(key:item["devices_unique_no"].stringValue,
                                                           skeletonID: "",
                                                           activityId: item["activity_id"].stringValue,
                                                           custid: item["custid"].stringValue,
                                                           userid: item["userid"].stringValue,
                                                           username: item["username"].stringValue,
                                                           rmsid: "",
                                                           phoneNumber: item["phoneNumber"].stringValue,
                                                           location: item["Location"].stringValue,
                                                           city: item["City"].stringValue,
                                                           street: "",
                                                           block: "",
                                                           intersectionStreet:"",
                                                           note: item["Notes"].stringValue,
                                                           activity_notes: item["activity_notes"].stringValue,
                                                           CreatedBy: item["CreatedBy"].stringValue,
                                                           ticketDate: "",
                                                           declarationDate: "" ,
                                                           violation: "",
                                                           violationCode: "",
                                                           violationType: "",
                                                           violationID: "",
                                                           offenceCode:"",
                                                           email: "",
                                                           createdOn: item["CreatedOn"].stringValue,
                                                           updatedBy: item["UpdatedBy"].stringValue,
                                                           updatedOn: item["UpdatedOn"].stringValue,
                                                           citationNumber: "",
                                                           status: item["ripa_activity_status_Name"].stringValue ,
                                                           mainStatus: item["ripa_activity_status_Id"].stringValue,
                                                           statusChnageDate: "" ,
                                                           ripaTempId: "",
                                                           tempType: item["activity_uid"].stringValue,
                                                           stopDate: convertDateFormater(date: item["stop_date"].stringValue) ,
                                                           stopTime: getonlyTime(date:item["stop_time"].stringValue) ,
                                                           stopDuration:  item["stop_duration"].stringValue ,
                                                           rejectedURL:"", syncStatus: "",startDate: "",endDate: "",is_K_12_Student:"",lat: "",long: "", timeTaken: item["timetaken"].stringValue, countyId: item["county_id"].stringValue, deviceid: "0" ,
                                                           
                                                           callNumber: item["call_number"].stringValue, callTime: "", onsceneTime: item["onscene_time"].stringValue, clearTimeOfOfficer: item["clear_time_of_the_Offrcer"].stringValue, overallCallClearTime: item["overall_call_clear_time"].stringValue, callType: item["call_type"].stringValue, unitId: item["unitId"].stringValue, zone: item["zone"].stringValue)
                                
                                
                                db.insertRipaTempMaster(ripaResponse: ripas, tableName: db.ripaTempMaster)
                            }
                            
                            
                            
                            
                            
                            for item in json["result"]["pendingApproved"].arrayValue {
                                
                                let ripas = RipaTempMaster(key:item["devices_unique_no"].stringValue,
                                                           skeletonID: "",
                                                           activityId: item["activity_id"].stringValue,
                                                           custid: item["custid"].stringValue,
                                                           userid: item["userid"].stringValue,
                                                           username: item["username"].stringValue,
                                                           rmsid: "",
                                                           phoneNumber: item["phoneNumber"].stringValue,
                                                           location: item["Location"].stringValue,
                                                           city: item["City"].stringValue,
                                                           street: "",
                                                           block: "",
                                                           intersectionStreet:"",
                                                           note: item["Notes"].stringValue,
                                                           activity_notes: item["activity_notes"].stringValue,
                                                           CreatedBy: item["CreatedBy"].stringValue,
                                                           ticketDate: "",
                                                           declarationDate: "" ,
                                                           violation: "",
                                                           violationCode: "",
                                                           violationType: "",
                                                           violationID: "",
                                                           offenceCode:"",
                                                           email: "",
                                                           createdOn: item["CreatedOn"].stringValue,
                                                           updatedBy: item["UpdatedBy"].stringValue,
                                                           updatedOn: item["UpdatedOn"].stringValue,
                                                           citationNumber: "",
                                                           status: item["ripa_activity_status_Name"].stringValue ,
                                                           mainStatus: item["ripa_activity_status_Id"].stringValue,
                                                           statusChnageDate: "" ,
                                                           ripaTempId: "",
                                                           tempType: item["activity_uid"].stringValue,
                                                           stopDate: convertDateFormater(date: item["stop_date"].stringValue) ,
                                                           stopTime: getonlyTime(date:item["stop_time"].stringValue) ,
                                                           stopDuration:  item["stop_duration"].stringValue ,
                                                           rejectedURL:"", syncStatus: "",startDate: "",endDate: "",is_K_12_Student:"",lat: "",long: "", timeTaken: item["timetaken"].stringValue, countyId: item["county_id"].stringValue, deviceid: "0",
                                                           
                                                           callNumber: item["call_number"].stringValue, callTime: "", onsceneTime: item["onscene_time"].stringValue, clearTimeOfOfficer: item["clear_time_of_the_Offrcer"].stringValue, overallCallClearTime: item["overall_call_clear_time"].stringValue, callType: item["call_type"].stringValue, unitId: item["unitId"].stringValue, zone: item["zone"].stringValue)
                                
                                if ripas.status == "Pending Review"{
                                    ripas.mainStatus = "10"
                                }
                                db.insertRipaTempMaster(ripaResponse: ripas, tableName: db.ripaTempMaster)
                            }
                        }
                        else{
                            let code = json["result"]["status"].intValue
                                //json["result"][0]["status"].intValue
                            if code == 0{
                                DashboardViewModel.showAlertWithProperty("Alert", messageString: errorMsg, code:code )
                                return
                            }
                        }
                    }
                    self.questiondelegate?.proceedToSavedListScreen()
                    return
                }
                else{
                    self.questiondelegate?.proceedToSavedListScreen()
                    return
                }
            })
            { (error, code, message) in
                AppUtility.hideProgress(nil)
             //   self.questiondelegate?.proceedToSavedListScreen()
                if let errorMessage = message {
           //         AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
                }
                else if code == 200{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Server Error. Try again.")
                }
                else{
                //    AppUtility.showAlertWithProperty("Alert", messageString: error!.localizedDescription)
                }
            }
        }
         else{
            print("Internet Connection not Available!")
            AppUtility.hideProgress(nil)
            AppUtility.showAlertWithProperty("Alert", messageString: "Internet connection not available.")
         }
        
    }
    
    
    
    
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
            number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
    
    
    
 }
 
 
 
