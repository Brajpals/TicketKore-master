//
//  MicViewModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 5/11/21.
//

import Foundation
import SwiftyJSON
 

 protocol SavedListModelDelegate: class {
    func  proceedToRejectedView(applicationData:RejectedApplication?)
     func  proceedToPreviewScreen(previewPram:[RipaPerson], forTemplate:Bool?)
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
        
        if Reachability.isConnectedToNetwork(){
            ApiManager.getrejectedApplicationWithUID(params: params, methodTyPe: .post, url: URL!, completion: { (success,message) in
                AppUtility.hideProgress(nil)
                 if message == "Success"{
                    
                    var ripaResponseArr = [RipaResponse]()
                    var personArray = [RipaPerson]()
                    
                    if let json = try? JSON(data: success as! Data) {
                     let error = json["result"][0]["serviceError"].stringValue
                     
                        if  error == ""{
                             var i = 0
                            for person in json["result"][0]["ripaPersons"].arrayValue{
                                if personArray.count > 0 && self.forTemplate == true{
                                 continue
                                }
                                 var person = RipaPerson(CreatedBy: "", person_name: person["person_name"].stringValue, key: "", date: person["CreatedOn"].stringValue, time: person["CreatedOn"].stringValue, duration:"", ripa_response: [])
                                
                                ripaResponseArr.removeAll()
                                
                            for response in json["result"][0]["ripaPersons"][i]["ripa_response"].arrayValue{
                             
                                let ripaResponse = RipaResponse(question_id: response["question_id"].stringValue, response: response["response"].stringValue, internal: response["internal"].stringValue, userid:"", question: response["question"].stringValue, CreatedBy: "", physical_attribute: response["physical_attribute"].stringValue, key: "", personId: "", description: response["Description"].stringValue, question_code: response["question_code"].stringValue, cascade_ques_id: response["cascade_ques_id"].stringValue, order_number: response["order_number"].stringValue , option_id: response["option_id"].stringValue, cascade_option_id: response["cascade_option_id"].stringValue, main_question_id: response["main_question_id"].stringValue, supervisorId: "")
                                
                                 ripaResponseArr.append(ripaResponse)
                                
//                                if ripaResponse.question.contains("Name of school") && ripaResponse.question_code == "C9"{
//                                    AppConstants.schoolName = ripaResponse.response!
//                                    AppConstants.isSchoolSelected = "Yes"
//                                  }
//
                             }
                                 person.ripa_response = ripaResponseArr
                                  personArray.append(person)
                                i += 1
                            }
                             
                            self.savedListModelDelegate?.proceedToPreviewScreen(previewPram:personArray, forTemplate: self.forTemplate)
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
    
    
    var questionsArray : [QuestionResult1]?
    var cascadeQuestionsArray : [QuestionResult1]?
    var personDict:[String:Any]?
    var personArray: [[String: Any]] = []
    
    
    
    func createPersonDict(personarray:[RipaPerson])-> [[String: Any]]{
        db.openDatabase()
        
        personDict?.removeAll()
        personArray.removeAll()
        questionsArray?.removeAll()
        cascadeQuestionsArray?.removeAll()
        
        for person in personarray{
            questionsArray =  newripaViewModel.resetQuestion()
             cascadeQuestionsArray = newripaViewModel.resetCascadeQuestion()
            questionsArray?.append(contentsOf: cascadeQuestionsArray!)
 
            let groupQuest = getQuestionUsingQuestionCode(questionCode: "25", question_Id: "", questArray: questionsArray)
            for options in groupQuest.questionoptions!{
                options.isSelected = true
            }
            
            for response in person.ripa_response{
                var question : QuestionResult1?
                
                if response.response == "" || response.question_code == "C10" || (response.question).lowercased() == "location"{
                    continue
                }
 
                if response.question_id == "21" && response.question_code != "C24" && response.question_id != "52"{
                     question = getQuestionUsingQuestionCode(questionCode: response.question_code, question_Id: response.question_id , questArray: questionsArray)
                   }
                else{
                    question = getQuestionUsingQuestionId(question_Id: response.question_id, questionCode: response.question_code, questArray: questionsArray)
                }
                
                 // Start
                 if response.cascade_option_id == "" || response.cascade_option_id == "0"{
                    let option = newripaViewModel.createObj(mainQuestId: response.main_question_id, ripaID: question?.id, optionValue: response.response, physical_attribute: response.physical_attribute, description: response.description, isSelected: true, mainQuestOrder: String(response.order_number))
                    
                    if response.question_code == "17"{
                        print("")
                    }
                    
//                    if response.question_code == "C9" && response.question.contains("Name of school"){
//                        AppConstants.schoolName = response.response!
//                    }
                     
                     if response.question_code == "C9"{
                         AppConstants.schoolName = response.response!
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
                     if option.option_id == response.cascade_option_id{
                        option.isSelected = true
                     }
                    if option.isSelected == true{
                        i += 1
                    }
                }
                
                if i > 1 && hasdefault == true{
                    defaultOption?.isSelected = false
                }
                
            }
                
                if response.question_code == "C24" && (response.response)?.lowercased() == "yes"{
                    AppConstants.isSchoolSelected = "Yes"
                    question = getQuestionUsingQuestionCode(questionCode: "5", question_Id: response.question_id, questArray: questionsArray)
                    for option in question!.questionoptions!{
                        if option.physical_attribute == "K12"{
                            option.isSelected = true
                        }
                    }
                  }
               
            }
            
            
            var questarr = [QuestionResult1]()
            var cascadeQuestArr = [QuestionResult1]()
            
            
//            if AppConstants.status == "Saved"{
//                for quest in questionsArray!{
 //            }
            
         //   if AppConstants.status != "Saved"{
            for quest in questionsArray!{
                if !quest.question_code.contains("C") && quest.visible_question == "1"{
                // let questionArr = quest.copy()
                    questarr.append(quest)
            }
             else{
               // let cascadeQuest = quest.copy()
                cascadeQuestArr.append(quest)
            }
    //        }
            }
            
            newripaViewModel.questionsArray = questarr
            newripaViewModel.cascadeQuestionArray = cascadeQuestArr
             let selectedOptionsArray = newripaViewModel.makeSelectedOptionList()
            
          personDict = ["PersonType":person.person_name,"SelectedOption":selectedOptionsArray,"QuestionArray":questarr,"CascadeQuestionArray":cascadeQuestArr]
            personArray.append(personDict!)
            
        }
        return personArray
    }
    
    

    
    func getQuestionUsingQuestionId(question_Id:String, questionCode:String, questArray:[QuestionResult1]?)->QuestionResult1{
        var quest:QuestionResult1?
         for question in questArray!{
             if  question.id == question_Id{
                quest = question
                return quest!
            }
        }
        if quest == nil{
            quest = getQuestionUsingQuestionCode(questionCode: questionCode, question_Id: question_Id, questArray: questArray)
        }
          return quest!
    }
    
    
    func getQuestionUsingQuestionCode(questionCode:String,question_Id:String, questArray:[QuestionResult1]?)->QuestionResult1{
        var quest:QuestionResult1?
         for question in questArray!{
             if  question.question_code == questionCode{
                quest = question
                return quest!
            }
        }
        if quest == nil{
            quest = getQuestionUsingQuestionId(question_Id: question_Id, questionCode: questionCode, questArray: questionsArray)
        }
          return quest!
    }
    
    
    
    
    
    
//    //(containsSwearWord(text: response.question_code , codeList: listOfCode))
//
//
//        let listOfCode = ["C6", "C7", "C9"]
//
//
//        func containsSwearWord(text: String, codeList: [String]) -> Bool {
//            for word in codeList{
//                if word == text{
//                    return true
//                }
//            }
//    //    return swearWords
//    //        .reduce(false) { $0 || text == ($1.lowercased()) }
//            return false
//        }
        
    
    
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

                                location = RejectedApplicationLocation(block: loc["Block"]!.stringValue, street: loc["Street"]!.stringValue, intersection: loc["Intersection"]!.stringValue)
 
                               
                                for item in json["result"]["response"].arrayValue {
                                    let  response = Response(recID: item["rec_id"].stringValue, activityID: item["activity_id"].stringValue, ripaPersonID: item["ripa_person_id"].stringValue, userid: item["userid"].stringValue, questionID: item["question_id"].stringValue, question: item["question"].stringValue, questionCode: item["question_code"].stringValue, cascadeQuesID: item["cascade_ques_id"].stringValue, optionID: item["option_id"].stringValue, response: item["response"].stringValue, physicalAttribute: item["physical_attribute"].stringValue, responseInternal: item["internal"].stringValue, responseDescription: item["Description"].stringValue, devicesUniqueNo: item["devices_unique_no"].stringValue, orderNumber: item["order_number"].stringValue, createdBy: item["CreatedBy"].stringValue, createdOn: item["CreatedOn"].stringValue, updatedBy: item["UpdatedBy"].stringValue, updatedOn: item["UpdatedOn"].stringValue, personName: item["person_name"].stringValue)
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

