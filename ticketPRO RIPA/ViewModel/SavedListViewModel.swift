//
//  MicViewModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 5/11/21.
//

import Foundation
import SwiftyJSON
 

protocol SavedListModelDelegate: AnyObject {
    func  proceedToRejectedView(applicationData:RejectedApplication?)
     func  proceedToPreviewScreen(previewPram:[RipaPerson], forTemplate:Bool?, locationOptionArray : [Questionoptions1])
}

class SavedListViewModel {
    
    let db = SqliteDbStore()
    
    let userId = AppManager.getLastSavedLoginDetails()?.result?.userid
    let id = AppManager.getLastSavedLoginDetails()?.id

    
    var  savedListModelDelegate : SavedListModelDelegate?
     var rejectedApplication:RejectedApplication?
    
    var newripaViewModel = NewRipaViewModel()
    var forTemplate:Bool?
    
    func getApprovedOrPendingPram(activityId:String){
        let param:[String : Any] = ["activityid":activityId]
        let params:[String : Any] =  ["id":id!, "method":"getActivityByActivityId", "params":param ,"jsonrpc": "2.0"]
         print(params)
        getApprovedOrPendingRipa(params: params)
    }
    
    
    func getApprovedOrPendingRipa(params: [String:Any]) {
        AppUtility.showProgress(nil, title: nil)
        var URL:String?
        
         URL = AppConstants.Api.questions
        
        var traini : String = "0"
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
            traini = "1"
        }
        
        let os = ProcessInfo().operatingSystemVersion
        
        if Reachability.isConnectedToNetwork(){
            ApiManager.getrejectedApplicationWithUID(params: params, methodTyPe: .post, url: URL!, completion: { (success,message) in
                AppUtility.hideProgress(nil)
                 if message == "Success"{
                    
                    var ripaResponseArr = [RipaResponse]()
                    var personArray = [RipaPerson]()
                    var personInfoArr = NSMutableArray()
                    if let json = try? JSON(data: success as! Data) {
                     let error = json["result"][0]["serviceError"].stringValue
                      print(json)
                        
                        if  error == ""{
                             var i = 0
                            
                            for person in json["result"][0]["ripaPersons"].arrayValue{
                                if personArray.count > 0 && self.forTemplate == true{
                                 continue
                                }
                                 var person = RipaPerson(CreatedBy: "", person_name: person["person_name"].stringValue, key: "", date: person["CreatedOn"].stringValue, time: person["CreatedOn"].stringValue, duration:"", ripa_response: [])
                                
                                 ripaResponseArr.removeAll()
                                
                            for response in json["result"][0]["ripaPersons"][i]["ripa_response"].arrayValue{
                             
                                var option_id : String = "0"
                                let opId = response["option_id"].string
                                if let checkId = opId {
                                    option_id = checkId
                                }
                                var firstLoc : String = ""
                                var secondLoc : String = ""
                                
//                                print(response["question"].stringValue)
//                                print(response["response"].stringValue)
                                
                                if response["question"].stringValue == "Location Type" {
                                    self.setLocationType(dict: response.rawValue as! NSDictionary)
                                }
                                if response["question"].stringValue == "Location" {
                                    let responseStr = response["response"].stringValue
                                    let token = responseStr.components(separatedBy: "&")
                                    AppConstants.LocTypeDescription = responseStr
                                    if token.count > 1 {
                                        AppConstants.secondIntersection = token[1]
                                        firstLoc = token[0]
                                        secondLoc = token[1]
                                        AppConstants.block = firstLoc
                                        AppConstants.street = secondLoc
                                        AppConstants.firstIntersection = firstLoc
                                        AppConstants.secondIntersection = secondLoc
                                        AppConstants.highway = firstLoc
                                        AppConstants.closestHighway = secondLoc
                                    }
                                    
                                }
                                if response["main_question_id"].stringValue == "61" {
                                   let dictt = NSMutableDictionary()
                                    dictt["cascade_ques_id"] = response["cascade_ques_id"].stringValue
                                    dictt["CreatedBy"] = response["CreatedBy"].stringValue
                                    dictt["rec_id"] = response["rec_id"].stringValue
                                    dictt["option_id"] = response["option_id"].stringValue
                                    dictt["question"] = response["question"].stringValue
                                    dictt["activity_id"] = response["activity_id"].stringValue
                                    dictt["response"] = response["response"].stringValue
                                    dictt["internal"] = response["internal"].stringValue
                                    dictt["main_question_id"] = response["main_question_id"].stringValue
                                    dictt["physical_attribute"] = response["physical_attribute"].stringValue
                                    dictt["order_number"] = response["order_number"].stringValue
                                    dictt["question_code"] = response["question_code"].stringValue
                                    dictt["question_id"] = response["question_id"].stringValue
                                    dictt["cascade_option_id"] = response["cascade_option_id"].stringValue
                                    dictt["Description"] = response["Description"].stringValue
                                    personInfoArr.add(dictt)
                                    
                                }
                                if response["question"].stringValue == "City or Unincorporated Area" {
                                    AppConstants.city = response["response"].stringValue
                                }
                                if response["question"].stringValue == "Street"{
                                    AppConstants.LocTypeIndex = 1
                                    AppConstants.street = response["response"].stringValue
                                }
                                else if response["question"].stringValue.uppercased() == "BLOCK"{
                                    AppConstants.LocTypeIndex = 1
                                    AppConstants.block = response["response"].stringValue
                                }
                                else if response["question"].stringValue == "First Intersection"{
                                    AppConstants.LocTypeIndex = 2
                                    AppConstants.firstIntersection = response["response"].stringValue
                                }
                                else if response["question"].stringValue == "Second Intersection"{
                                    AppConstants.LocTypeIndex = 2
                                    AppConstants.secondIntersection = response["response"].stringValue
                                }
                                else if response["question"].stringValue == "Highway"{
                                    AppConstants.LocTypeIndex = 3
                                    AppConstants.highway = response["response"].stringValue
                                }
                                else if response["question"].stringValue == "Closest Highway"{
                                    AppConstants.LocTypeIndex = 3
                                    AppConstants.closestHighway = response["response"].stringValue
                                }
                                else if response["question"].stringValue == "Closest Highway Exit"{
                                    AppConstants.LocTypeIndex = 3
                                    AppConstants.closestHighway = response["response"].stringValue
                                }
                                else if response["question"].stringValue == "Other"{
                                    AppConstants.LocTypeIndex = 4
                                    AppConstants.LocTypeDescription = response["response"].stringValue
                                }
                              
                               
                                
                                if response["question"].stringValue == "Geographic Coordinates"{
                                    let respose = response["response"].stringValue
                                    AppConstants.LocTypeIndex = 6
                                    let arr = respose.components(separatedBy: ",")
                                    if arr.count > 1 {
                                        let latStr : String = arr[0].trimmingCharacters(in: .whitespaces)
                                        let longStr : String = arr[1].trimmingCharacters(in: .whitespaces)
                                        let latflt =  Float(latStr)
                                        let longflt =  Float(longStr)
//                                         UserDefaults.standard.set(String(format: "%.3f", latflt!), forKey: "latitude")
//                                         UserDefaults.standard.set(String(format: "%.3f", longflt!), forKey: "longitude")
                                         AppConstants.lati = String(format: "%.3f", latflt!)
                                         AppConstants.longi = String(format: "%.3f", longflt!)
                                     }
                                    else if arr.count > 0 {
                                        let repValue = String(format: "%@", respose)
                                        let splits = repValue.components(separatedBy: "&")
                                        let latStr : String = splits[0].trimmingCharacters(in: .whitespaces)
                                        let longStr : String = splits[1].trimmingCharacters(in: .whitespaces)
                                        let latflt =  Float(latStr)
                                        let longflt =  Float(longStr)
                                         UserDefaults.standard.set(String(format: "%.3f", latflt!), forKey: "latitude")
                                         UserDefaults.standard.set(String(format: "%.3f", longflt!), forKey: "longitude")
                                        AppConstants.lati = String(format: "%.3f", latflt!)
                                        AppConstants.longi = String(format: "%.3f", latflt!)
                                    }
                                }

                                let ripaResponse = RipaResponse(question_id: response["question_id"].stringValue, response: response["response"].stringValue, internal: response["internal"].stringValue, userid:"", question: response["question"].stringValue, CreatedBy: response["CreatedBy"].stringValue, physical_attribute: response["physical_attribute"].stringValue, key: "", personId: "", description: response["Description"].stringValue, question_code: response["question_code"].stringValue, cascade_ques_id: response["cascade_ques_id"].stringValue, order_number: response["order_number"].stringValue , option_id: option_id, cascade_option_id: response["cascade_option_id"].stringValue, main_question_id: response["main_question_id"].stringValue, supervisorId: "", other_assignment_value: "", activity_id: AppConstants.activity_id, ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini,isSelected :response["response"].stringValue )
                                
                                   ripaResponseArr.append(ripaResponse)
                                
                             }
                                 person.ripa_response = ripaResponseArr
                                  personArray.append(person)
                                i += 1
                            }
                            
                            UserDefaults.standard.setValue(personInfoArr, forKey: "personInfo")
                           
                            self.savedListModelDelegate?.proceedToPreviewScreen(previewPram:personArray, forTemplate: self.forTemplate,locationOptionArray : self.createOptionArray())
                            
                        }
                        else{
                        ///AppUtility.showAlertWithProperty("Alert", messageString:error )
                            let code = json["result"][0]["status"].intValue
                            DashboardViewModel.showAlertWithProperty("Alert", messageString: error, code: code)
                        }
                        
                    }
                
                  }
                else{
                    if success as! String != "" {
                        AppUtility.showAlertWithProperty("Alert", messageString:success as! String )}
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
            AppUtility.showAlertWithProperty("Alert", messageString: "Internet connection not available.")
             
        }
        
    }
    
    func createOptionArray() -> [Questionoptions1] {
        var questOption = [Questionoptions1]()
        let geographicObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1408", ripa_id: "118", custid: "1", option_value: "Geographic Coordinate", cascade_ripa_id: "119", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "AN", questionTypeCode: "SC", tag: "", physical_attribute: "1", default_value: "", optionDescription: "", question_code_for_cascading_id: "C53", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        if AppConstants.LocTypeIndex == 6 {
            geographicObj.isSelected = true
        }
        questOption.append(geographicObj)
        
        let blockObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1409", ripa_id: "118", custid: "1", option_value: "Block Number and Street Name", cascade_ripa_id: "120", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A", questionTypeCode: "MC", tag: "", physical_attribute: "2", default_value: "", optionDescription: "", question_code_for_cascading_id: "C54", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        if AppConstants.LocTypeIndex == 1 {
            blockObj.isSelected = true
        }
        questOption.append(blockObj)
        
        let IntObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1410", ripa_id: "118", custid: "1", option_value: "Closest Intersection", cascade_ripa_id: "121", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A", questionTypeCode: "MC", tag: "", physical_attribute: "3", default_value: "", optionDescription: "", question_code_for_cascading_id: "C55", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        if AppConstants.LocTypeIndex == 2 {
            IntObj.isSelected = true
        }
        questOption.append(IntObj)
        
        let highObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1411", ripa_id: "118", custid: "1", option_value: "Highway and Closest Highway Exit", cascade_ripa_id: "122", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A", questionTypeCode: "MC", tag: "", physical_attribute: "4", default_value: "", optionDescription: "", question_code_for_cascading_id: "C56", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        if AppConstants.LocTypeIndex == 3 {
            highObj.isSelected = true
        }
        questOption.append(highObj)
        
        let otherObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1412", ripa_id: "118", custid: "1", option_value: "Other", cascade_ripa_id: "123", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "AN", questionTypeCode: "ML", tag: "", physical_attribute: "5", default_value: "", optionDescription: "", question_code_for_cascading_id: "C57", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        if AppConstants.LocTypeIndex == 4 {
            otherObj.isSelected = true
        }
        questOption.append(otherObj)
        
        return questOption
        
    }
    
    
    func setEditConstant () {
        UserDefaults.standard.set("", forKey: "latitude")
        UserDefaults.standard.set("", forKey: "longitude")
        AppConstants.block = ""
        AppConstants.street = ""
        AppConstants.highway = ""
        AppConstants.closestHighway = ""
        AppConstants.LocTypeDescription = ""
        AppConstants.LocTypeIndex = 0
        AppConstants.firstIntersection = ""
        AppConstants.secondIntersection = ""
      
    }
    
   
    func setLocationType(dict : NSDictionary) {
        var type = dict["response"] as! String
        if type == "Geographic Coordinates" {
            AppConstants.LocTypeIndex =  6
        }
        else if type == "Block Number and Street Name" {
            AppConstants.LocTypeIndex =  1
        }
        else if type == "Closest Intersection" {
            AppConstants.LocTypeIndex =  2
        }
        else if type == "Highway and Closest Highway Exit" {
            AppConstants.LocTypeIndex =  3
        }
        else {
            AppConstants.LocTypeIndex =  4
        }
    }
    
    
    var questionsArray : [QuestionResult1]?
    var cascadeQuestionsArray : [QuestionResult1]?
    var personDict:[String:Any]?
    var personArray: [[String: Any]] = []
    
    
    
    func createPersonDict(personarray:[RipaPerson],locArr : [Questionoptions1])-> [[String: Any]]{
        db.openDatabase()
        
        personDict?.removeAll()
        personArray.removeAll()
        questionsArray?.removeAll()
        cascadeQuestionsArray?.removeAll()
        
        for person in personarray{
            questionsArray =  newripaViewModel.resetQuestion()
             cascadeQuestionsArray = newripaViewModel.resetCascadeQuestion()
            questionsArray?.append(contentsOf: cascadeQuestionsArray!)
            var isStopMade : Bool = false
            let groupQuest = getQuestionUsingQuestionCode(questionCode: "25", question_Id: "", questArray: questionsArray)
            
            var isStudent : Bool = false
            for options in groupQuest.questionoptions!{
                if options.option_id.count == 0 {
                    options.option_id = "0"
                }
                if options.option_value == "Is person a student?" && options.isSelected == true{
                    isStudent = true
                }
                options.isSelected = true
            }

            for response in person.ripa_response{
                var question : QuestionResult1?
                
                if response.response == "" || response.question_code == "C10" || response.question_code == "5"{
                    continue
                }
                
                
                print(response.question)
                print(response.response)
                print(response.question_id)
                if response.question_code == "25" {
                    
                }
 
                if response.question_id == "21" && response.question_code != "C24" && response.question_id != "52"{
                     question = getQuestionUsingQuestionCode(questionCode: response.question_code, question_Id: response.question_id , questArray: questionsArray)
                  //  question = getQuestionUsingQuestionId(question_Id: response.question_id, questionCode: response.question_code, questArray: questionsArray)
                    if question?.questionoptions?.count == 0 {
                       // question?.questionoptions = locArr
                    }
                   }
                else{
                    question = getQuestionUsingQuestionId(question_Id: response.question_id, questionCode: response.question_code, questArray: questionsArray)
                    if response.main_question_id == "108" && response.response == "Yes" && response.isSelected == "Yes"{
                        for i in (0..<(question?.questionoptions?.count ?? 0))
                        {
                            if question?.questionoptions?[i].option_value == "Yes" {
                                question?.questionoptions?[i].isSelected = true
                            }
                        }
                    }
                }
                
            
                
                if response.question_code == "C29"{
                   // question = getQuestionUsingQuestionId(question_Id: response.question_id, questionCode: response.question_code, questArray: questionsArray)
                     question = getQuestionUsingQuestionCode(questionCode: response.question_code, question_Id: response.question_id , questArray: questionsArray)
                }
               else if response.question_code == "C30"{
                    print(response.response)
                    question = getQuestionUsingQuestionId(question_Id: response.question_id, questionCode: response.question_code, questArray: questionsArray)
                }
               else if response.question_code == "C32"{
                    print(response.response)
                    question = getQuestionUsingQuestionId(question_Id: response.question_id, questionCode: response.question_code, questArray: questionsArray)
                }
               else if response.question_code == "C42"{
                    print(response.response)
                    question = getQuestionUsingQuestionId(question_Id: response.question_id, questionCode: response.question_code, questArray: questionsArray)
                }
                else if response.question_code == "C24"{
                    if  response.response == "Yes" {
                        question?.questionoptions?[0].isSelected = true
                        isStudent = true
                    }
                    else {
                        question?.questionoptions?[1].isSelected = true
                    }
                 }
                
             if response.cascade_option_id == "" || response.cascade_option_id == "0"{
                 let option = newripaViewModel.createObj(mainQuestId: response.main_question_id, ripaID: question?.id, optionValue: response.response, physical_attribute: response.physical_attribute, description: response.description, isSelected: true, mainQuestOrder: String(response.order_number), isNewAdded: false, mainId: "")
                    
                    if response.question_code == "17"{
                        print("")
                    }
                     
                     if response.question_code == "C9"{
                         AppConstants.schoolName = response.response
                     }
                    
                    if response.description == "StReas_N" || response.description == "BasSearch_N"{
                        option.tag = "Description"
                    }
                 
                question?.questionoptions?.append(option)
            }
            else{
                var defaultOption  : Questionoptions1?
                var hasdefault = false
                var i = 0
                for option in question!.questionoptions!{
                    option.order_number = String(response.order_number)
                    option.mainQuestOrder = String(response.order_number)
                  
                    if option.default_value == "1"{
                        defaultOption = option
                        hasdefault = true
                    }
                    
                    if option.mainQuestId == "108" {
                        let objj = person.ripa_response.filter({
                            $0.main_question_id == "108"
                        })
                        if objj.count > 0 {
                            for minObj in objj {
                                if  minObj.question_id == option.cascade_ripa_id && minObj.response.capitalized == "Yes" {
                                    option.isSelected = true
                                    if option.cascade_ripa_id == "35" {
                                        isStopMade = true
                                    }
                                }
                            }
                        }
                    }
                    else if option.option_id == response.cascade_option_id{
                        option.isSelected = true
                     }
                    if option.option_id.count == 0 {
                        option.option_id = "0"
                    }
                    
                    if option.isSelected == true{
                        i += 1
                    }
                }
                
                if i > 1 && hasdefault == true{
                    defaultOption?.isSelected = false
                }
                
            }
                
                if response.question_code == "C24" && (response.response).lowercased() == "yes"{
                    AppConstants.isSchoolSelected = "Yes"
                   // question = getQuestionUsingQuestionId(question_Id: response.question_id, questionCode: response.question_code, questArray: questionsArray)
                    question = getQuestionUsingQuestionCode(questionCode: "5", question_Id: response.question_id, questArray: questionsArray)
                    for option in question!.questionoptions!{
                        if option.option_id.count == 0 {
                            option.option_id = "0"
                        }
                        if option.physical_attribute == "K12"{
                            option.isSelected = true
                        }
                    }
                  }
               
            }
            
            
            var questarr = [QuestionResult1]()
            var cascadeQuestArr = [QuestionResult1]()
            
            for quest in questionsArray!{
                if !quest.question_code.contains("C") && quest.visible_question == "1"{
                    if quest.question_code == "25" {
                        if isStudent == true {
                            questarr.append(quest)
                        }
                        else {
                           /* if let firstIndex = quest.questionoptions?.firstIndex(where: {
                                $0.option_value == "Is person a student?"
                            }) {
                                quest.questionoptions?.remove(at: firstIndex)
                                questarr.append(quest)
                            }
                            else {
                                questarr.append(quest)
                            }  */
                            questarr.append(quest)
                        }
                    }
                    else {
                        questarr.append(quest)
                    }
            }
            else if quest.question_code.contains("C"){
                cascadeQuestArr.append(quest)
             }
             else{
               // let cascadeQuest = quest.copy()
                cascadeQuestArr.append(quest)
            }
        }
            
            newripaViewModel.questionsArray = questarr
            newripaViewModel.cascadeQuestionArray = cascadeQuestArr
            let selectedOptionsArray = newripaViewModel.makeSelectedOptionList(isSaved: false)
                if selectedOptionsArray[0][2].questionoptions?.count == 0 {
                    selectedOptionsArray[0][2].questionoptions = locArr
                }
            
            if selectedOptionsArray.count > 1, selectedOptionsArray[1].count > 2 , isStopMade == false{
                for i in (0..<selectedOptionsArray[1].count)
                {
                    if selectedOptionsArray[1][i].mainQuestId == "35" && selectedOptionsArray[1][i].mainQuestId == "35" {
                        selectedOptionsArray[1][i].option_value = "No"
                    }
                }
            }
            
          personDict = ["PersonType":person.person_name,"SelectedOption":selectedOptionsArray,"QuestionArray":questarr,"CascadeQuestionArray":cascadeQuestArr]
            personArray.append(personDict!)
            
        }
        return personArray
    }
    
    
    func getQuestionUsingQuestionId(question_Id:String, questionCode:String, questArray:[QuestionResult1]?)->QuestionResult1{
        var quest:QuestionResult1?
         for question in questArray!{
             if  question.id == question_Id || question.question_code == questionCode {
                quest = question
                return quest!
            }
        }
        let questObj = QuestionResult1(id: "", custid: "", question: "", question_info: "", question_key: "", question_code: "", questionTypeId: "", inputTypeId: "", is_add_value: "", internal: "", is_required: "", isAddtion: "", isCascade_Question: "", ripa_group_id: "", isDescription_Required: "", common_question: "", editable_question: "", visible_question: "", order_number: "", is_active: "", CreatedBy: "", CreatedOn: "", UpdatedBy: "", UpdatedOn: "", inputTypeCode: "", questionTypeCode: "", groupName: "", questionoptions: [])
          return questObj
    }
    
    func getQuestionUsingQuestionCode(questionCode:String,question_Id:String, questArray:[QuestionResult1]?)->QuestionResult1{
        var quest:QuestionResult1?
        if let qArray = questArray {
            for i in (0..<qArray.count)
            {
                if qArray[i].question_code == questionCode {
                    quest = qArray[i]
                    return quest!
                }
            }
        }
        
        if quest == nil{
            quest = getQuestionUsingQuestionId(question_Id: question_Id, questionCode: questionCode, questArray: questionsArray)
        }
          return quest!
    }
     
    
    func getRejectedRipaPram(uid:String){
        let param:[String : Any] = ["uid":uid]
        let params:[String : Any] = ["id":id!, "method":"ripaGetActivityData", "params":param ,"jsonrpc": "2.0"]
        //let params = EnrollmentUser.newRipaQuestionsData(newenroll:enrolluser)
        print(params)
        getRejectedRipa(params: params)
    }
  
    func getRejectedRipa(params: [String:Any]) {
        AppUtility.showProgress(nil, title: nil)
        var URL:String?
       
         URL = AppConstants.Api.questions
        
        if Reachability.isConnectedToNetwork(){
            ApiManager.getrejectedApplicationWithUID(params: params, methodTyPe: .post, url: URL!, completion: { [self](success,message) in
                AppUtility.hideProgress(nil)
                 if message == "Success"{
                   
                    var responseArr = [Response]()
                    var ativity:Ativity?
                    var location : RejectedApplicationLocation?
 
                           if let json = try? JSON(data: success as! Data) {
                            let error = json["result"]["serviceError"].stringValue
                            
                            if  error == ""{
                                print(json)
                                print("old Token " + (AppManager.getLastSavedLoginDetails()?.result?.access_token)!)
                                
                                 let token = json["result"]["logindata"]["access_token"].stringValue
                                AppManager.getLastSavedLoginDetails()?.result?.access_token = token
                                AppManager.saveLoginDetails()
                                print("New Token " + (AppManager.getLastSavedLoginDetails()?.result?.access_token)!)
  
                                let activity: Dictionary<String, JSON> = json["result"]["ativity"].dictionaryValue
                                 
                                ativity = Ativity(activityID: activity["activity_id"]!.stringValue, activityNotes:  activity["activity_notes"]!.stringValue, officerExperience:  activity["officer_experience"]!.stringValue, city:  activity["City"]!.stringValue, location: activity["Location"]!.stringValue, activityCreationDate:  activity["activity_creation_date"]!.stringValue, username:  activity["username"]!.stringValue, stopDate:  activity["stop_date"]!.stringValue, stopTime:  activity["stop_time"]!.stringValue, stopDuration:  activity["stop_duration"]!.stringValue, activityCheckedBy:  activity["activity_checkedBy"]!.stringValue, timetaken: activity["timetaken"]!.stringValue)
                                
                                AppConstants.applicationtime = String((Int(activity["timetaken"]!.stringValue) ?? 1) * 60)
                                print(AppConstants.applicationtime)
 
                                let loc: Dictionary<String, JSON> = json["result"]["location"].dictionaryValue

                                location = RejectedApplicationLocation(block: loc["Block"]?.stringValue ?? "", street: loc["Street"]?.stringValue ?? "", intersection: loc["First Intersection"]?.stringValue ?? "", locationType: loc["Location Type"]?.stringValue ?? "", location: loc["Location"]?.stringValue ?? "", firstIntersection: loc["First Intersection"]?.stringValue ?? "", secondIntersection: loc["Second Intersection"]?.stringValue ?? "", closestHighwayExit: loc["Closest Highway Exit"]?.stringValue ?? "", others: loc["Others"]?.stringValue ?? "", Highway: loc["Highway"]?.stringValue ?? "", geographicCoordinates: loc["Geographic Coordinates"]?.stringValue ?? "")
                               
                                for item in json["result"]["response"].arrayValue {
                                    print(item["cascade_ques_id"].stringValue)
                                    let  response = Response(recID: item["rec_id"].stringValue, activityID: item["activity_id"].stringValue, ripaPersonID: item["ripa_person_id"].stringValue, userid: item["userid"].stringValue, questionID: item["question_id"].stringValue, question: item["question"].stringValue, questionCode: item["question_code"].stringValue, cascadeQuesID: item["cascade_ques_id"].stringValue, optionID: item["option_id"].stringValue, response: item["response"].stringValue, physicalAttribute: item["physical_attribute"].stringValue, responseInternal: item["internal"].stringValue, responseDescription: item["Description"].stringValue, devicesUniqueNo: item["devices_unique_no"].stringValue, orderNumber: item["order_number"].stringValue, createdBy: item["CreatedBy"].stringValue, createdOn: item["CreatedOn"].stringValue, updatedBy: item["UpdatedBy"].stringValue, updatedOn: item["UpdatedOn"].stringValue, personName: item["person_name"].stringValue, main_question_id: item["main_question_id"].stringValue)
                                    responseArr.append(response)
                                }
                                
                                let rejectedRipa = RejectedApplication(ativity: ativity!, response: responseArr, location: location!)
                                 self.savedListModelDelegate?.proceedToRejectedView(applicationData: rejectedRipa)
                                
                              }
                            else{
                                let statusCode = json["result"]["status"].intValue
                                DashboardViewModel.showAlertWithProperty("Alert", messageString: error, code: statusCode)
                           // AppUtility.showAlertWithProperty("Alert", messageString:error )
                            }
                      }
                  }
                else{
                    if success as! String != "" {
                        AppUtility.showAlertWithProperty("Alert", messageString:success as! String )}
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
            AppUtility.showAlertWithProperty("Alert", messageString: "Internet connection not available.")
             
        }
        
    }
    
}

 

struct FilterList {
    var statusName = ""
    var isSelected = false
 }

