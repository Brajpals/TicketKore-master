//
//  NewRipaViewModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 17/02/21.
//

import Foundation
import SwiftyJSON




class NewRipaViewModel {
    
    var question : QuestionResult?
    var questionNumber : Int?
    
    var options : [String]?
    
    //var questionsArray : [QuestionResult]?
    var questionsArray : [QuestionResult1]?
    var selectedOptionsArray=[[Questionoptions1]]()
    var cascadeQuestionArray : [QuestionResult1]?
    
    var savedRipaList = [RipaTempMaster]()
    
    
    let db = SqliteDbStore()
    
    
    
    
    func splitViolatons(code:String,violation:String) ->([[String]]?,[String]?) {
         let offenceArray = splitOffenceCode(str:code)
        let violArray = splitViolationCode(str:violation)
         return (offenceArray,violArray)
    }
    
    
    
    
    func setFeature(){
       db.openDatabase()
        let featureList = db.getFeature() ?? []
        AppConstants.ripaGPS = "N"
        AppConstants.ripaCounty = "N"
        AppConstants.ripaTimeDuration = "N"
        
          for feature in featureList{
             if feature.feature == "RipaCounty"  &&  feature.isActive == "Y"{
                AppConstants.ripaCounty = "Y"
           }
            if feature.feature == "RipaGps"  &&  feature.isActive == "Y"{
               AppConstants.ripaGPS = "Y"
          }
            if feature.feature == "RipaTimeDuration"  &&  feature.isActive == "Y"{
               AppConstants.ripaTimeDuration = "Y"
          }
       }
   }
    
    
    
    
    func clearPersonData(){
        for question in questionsArray!{
            if question.question_code == "25"{
                for option in question.questionoptions!{
                    option.isSelected = false
                    let cascadeQuest =  getCascadeQuestionUsingId(questionID: Int(option.cascade_ripa_id)!)
                    for opt in cascadeQuest.questionoptions!{
                        opt.isSelected = false
                        if opt.option_value == "None"{
                            opt.isSelected = true
                        }
                        if opt.option_id == ""{
                            cascadeQuest.questionoptions! = []
                        }
                    }
                }
            }
        }
    }
    
    
 
    
    
    
    func splitOffenceCode(str:String)->[[String]]?{
        var offCodeStrArray=[[String]]()
         let components = str.components(separatedBy: ":")
         for comp in components{
            let serperatedCode = comp.components(separatedBy: ",")
            offCodeStrArray.append(serperatedCode)
        }
         return offCodeStrArray
    }
    
    
    func splitViolationCode(str:String)->[String]?{
              let serperatedCode = str.components(separatedBy: ",")
          return serperatedCode
    }
    
    
    
    func getCities()->[CityResult]{
        db.openDatabase()
                var cities = [CityResult]()
                let jsonString = db.getCity(tableName: "cityTable")
                if let data = jsonString!.data(using: .utf8) {
                    if let json = try? JSON(data: data) {
                        for item in json["result"].arrayValue {
                            let city = CityResult(city_id: item["city_id"].stringValue, custid: item["custid"].stringValue, city_name: item["city_name"].stringValue, county_id: item["county_id"].stringValue, order_number: item["order_number"].stringValue, isSelected: false)
 
                            if city.county_id ==  AppManager.getLastSavedLoginDetails()?.result?.county_id{
                            cities.append(city)
                            }
                        }
                      }
                }
        return cities
    }
    
  
    
    func getLocation(cityID:String)->([LocationResult],Location){
        db.openDatabase()
                var locations = [LocationResult]()
                var filteredLocation = [LocationResult]()

                 let jsonString = db.getCity(tableName: "locationTable")
        if jsonString != nil{
                if let data = jsonString!.data(using: .utf8) {
                    if let json = try? JSON(data: data) {
                        for item in json["result"].arrayValue {
                          
                            let location = LocationResult(location_id: item["location_id"].stringValue, custid: item["custid"].stringValue, location: item["location"].stringValue, zone_id: item["zone_id"].stringValue, order_number: item["order_number"].stringValue, is_active: item["is_active"].stringValue, county_id: item["county_id"].stringValue, city_id: item["city_id"].stringValue, isSelected: false)
                            
                            locations.append(location)
                              if cityID == location.city_id{
                            filteredLocation.append(location)
                                }
                          }
                      }
                }
        }
        let locationObj = Location()
        locationObj.id = ""
        locationObj.jsonrpc = ""
        locationObj.result = locations
        
      //  let filteredLocation = locations.filter({ (cityID).contains($0.city_id)})
             return (filteredLocation,locationObj)
    }
    
    
    
    
    func getSchool(cityID:String)->([SchoolResult]){
        db.openDatabase()
                var schools = [SchoolResult]()
                let jsonString = db.getCity(tableName: "schoolTable")
        if jsonString != nil{
                if let data = jsonString!.data(using: .utf8) {
                    if let json = try? JSON(data: data) {
                        for item in json["result"].arrayValue {
                            let school = SchoolResult(schoolsID: item["schools_Id"].stringValue, custid: item["custid"].stringValue, cdsCode: item["CDSCode"].stringValue, ncesDist: item["NCESDist"].stringValue, ncesSchool: item["NCESSchool"].stringValue, statusType: item["StatusType"].stringValue, countyid: item["countyid"].stringValue, county: item["County"].stringValue, district: item["District"].stringValue, school: item["School"].stringValue, street: item["Street"].stringValue, streetABR: item["StreetAbr"].stringValue, cityid: item["cityid"].stringValue, city: item["City"].stringValue, zip: item["Zip"].stringValue, state: item["State"].stringValue, phone: item["Phone"].stringValue, ext: item["Ext"].stringValue, faxNumber: item["FaxNumber"].stringValue, email: item["Email"].stringValue, webSite: item["WebSite"].stringValue, doc: item["DOC"].stringValue, docType: item["DOCType"].stringValue, soc: item["SOC"].stringValue, socType: item["SOCType"].stringValue, edOpsCode: item["EdOpsCode"].stringValue, edOpsName: item["EdOpsName"].stringValue, eilCode: item["EILCode"].stringValue, eilName: item["EILName"].stringValue, gSoffered: item["GSoffered"].stringValue, gSserved: item["GSserved"].stringValue, latitude: item["Latitude"].stringValue, longitude: item["Longitude"].stringValue, isK12School: item["isK_12School"].stringValue, isActive: item["isActive"].stringValue, orderNumber: item["order_number"].stringValue, createdBy: item["CreatedBy"].stringValue, createdOn: item["CreatedOn"].stringValue, updatedBy: item["UpdatedBy"].stringValue, updatedOn: item["UpdatedOn"].stringValue, isSelected: false)
 
                            
                            if cityID == school.cityid{
                                schools.append(school)
                              }
                         }
                      }
                }
                }
       
        return (schools)
     }
    
    
    
    func getViolations()->[ViolationsResult]{
        db.openDatabase()
        var violations = [ViolationsResult]()
       
                let jsonString = db.getCity(tableName: "violationTable")
        if  jsonString != nil{
                if let data = jsonString!.data(using: .utf8) {
                    if let json = try? JSON(data: data) {
                        for item in json["result"].arrayValue {
                            let violation = ViolationsResult(violationID: item["violation_id"].stringValue, custid: item["custid"].stringValue, violation: item["violation"].stringValue, code: item["code"].stringValue, orderNumber: item["order_number"].stringValue, violationDisplay: item["violation_display"].stringValue, isActive: item["is_active"].stringValue, violationType: item["violation_type"].stringValue, violationGroup: item["violation_group"].stringValue, offense_code: item["offense_code"].stringValue , isSelected: false)
                            violations.append(violation.copy() as! ViolationsResult)
                         }
                      }
                }}
        return violations
    }
    
    
    
    
    
    func getEducationCode()->([EducationCodeSection],[EducationCodeSubsection]){
        db.openDatabase()
        var educationCodeSection = [EducationCodeSection]()
        var educationCodeSubsection = [EducationCodeSubsection]()
                let jsonString = db.getCity(tableName: "educationCodeTable")
                if let data = jsonString!.data(using: .utf8) {
                    if let json = try? JSON(data: data) {
                        for item in json["result"]["educationCodeSection"].arrayValue {
                            let edCode = EducationCodeSection(educationCodeSectionID: item["education_code_section_id"].stringValue, educationCode: item["education_code"].stringValue, educationCodeDesc: item["education_code_desc"].stringValue, physicalAttribute: item["physical_attribute"].stringValue, orderNumber: item["order_number"].stringValue, isActive: item["is_active"].stringValue, createdBy: item["CreatedBy"].stringValue, createdOn: item["CreatedOn"].stringValue, updatedBy: item["UpdatedBy"].stringValue, updatedOn: item["UpdatedOn"].stringValue, isSelected: false)
                            educationCodeSection.append(edCode)
                         }
                        
                        
                        for item in json["result"]["educationCodeSubsection"].arrayValue {
                            let edSubCode = EducationCodeSubsection(educationCodeSubsectionID: item["education_code_subsection_id"].stringValue, educationCodeSectionID: item["education_code_section_id"].stringValue, educationCodeSubsection: item["education_code_subsection"].stringValue, educationCodeSubsectionDesc: item["education_code_subsection_desc"].stringValue, physicalAttribute: item["physical_attribute"].stringValue, orderNumber: item["order_number"].stringValue, isActive: item["is_active"].stringValue, createdBy: item["CreatedBy"].stringValue, createdOn: item["CreatedOn"].stringValue, updatedBy: item["UpdatedBy"].stringValue, updatedOn: item["UpdatedOn"].stringValue, isSelected: false)
                            educationCodeSubsection.append(edSubCode)
                         }
                       }
                }
        
        
        return (educationCodeSection,educationCodeSubsection)
    }
    
     
    
    
    func resetQuestion()->[QuestionResult1]{
        db.openDatabase()
     _ = db.getQuestions(tableName: "QuestionTable", getcascadeQuest: 0)
        let questionArray = db.getQuestionOptions(tableName: "OptionTable", optionFor: "", person_name: "", key: "")
        self.questionsArray = questionArray
        return questionArray!
    }
    
    func resetCascadeQuestion()->[QuestionResult1]{
     _ = db.getQuestions(tableName: "QuestionTable", getcascadeQuest: 1)
        let cascadeQuestionArray = db.getQuestionOptions(tableName: "OptionTable", optionFor: "", person_name: "", key: "")
        self.cascadeQuestionArray = cascadeQuestionArray
        return(cascadeQuestionArray!)
    }
    
    

    
    func createObj(mainQuestId:String?,ripaID:String?,optionValue:String?,physical_attribute:String?, description:String?,isSelected:Bool,mainQuestOrder:String)->Questionoptions1{
        let option:Questionoptions1 = Questionoptions1(mainQuestId: mainQuestId!, mainQuestOrder:mainQuestOrder ,option_id: "", ripa_id:ripaID!, custid: "", option_value: optionValue!, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: mainQuestOrder, createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: isSelected, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "", tag: "", physical_attribute: physical_attribute!, default_value: "", optionDescription: description!, question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: mainQuestId!, isExpanded: false, questionoptions: [])
        return option
    }
    
  
    
    func makeSelectedOptionList()->[[Questionoptions1]]{
        var  selectedOptions=[Questionoptions1]()
         selectedOptionsArray.removeAll()
        for quest in questionsArray!{
            selectedOptions.removeAll()
 
            for  option in quest.questionoptions!{
                
                option.mainQuestOrder = quest.order_number
                option.order_number = quest.order_number
                option.main_question_id = quest.id
 
                var cascadeQuestionID = (option).cascade_ripa_id
                if (option).isSelected && cascadeQuestionID == ""{
                    selectedOptions.append(option )
                }
                  if  cascadeQuestionID != ""{
                    if (option).isSelected{
                        selectedOptions.append(option )
                    }
                    let cascadeQuest = getCascadeQuestionUsingId(questionID: Int(cascadeQuestionID)!)
                    
                    for  option in cascadeQuest.questionoptions!{
                        
                        option.mainQuestOrder = quest.order_number
                        option.order_number = quest.order_number
                        option.main_question_id = quest.id
                            
                        cascadeQuestionID = (option ).cascade_ripa_id
                        if (option ).isSelected && cascadeQuestionID == ""{
                            selectedOptions.append(option )
                        }
                          if cascadeQuestionID != ""{
                            if (option ).isSelected{
                                selectedOptions.append(option )
                            }
                            let cascadeQuest = getCascadeQuestionUsingId(questionID: Int(cascadeQuestionID)!)
                            for  option in cascadeQuest.questionoptions!{
                                
                                option.mainQuestOrder = quest.order_number
                                option.order_number = quest.order_number
                                option.main_question_id = quest.id
                                
                                if (option ).isSelected && (option ).cascade_ripa_id == ""{
                                    selectedOptions.append(option )
                                }
//                                  if cascadeQuestionID != ""{
//                                    if (option as! Questionoptions1).isSelected{
//                                        selectedOptions.append(option as! Questionoptions1)
//                                    }
//                                   }
                            }
                        }
                    }
                }
            }
            selectedOptionsArray.append(selectedOptions)
        }
        return selectedOptionsArray
     }
    
    
    
    func setOptionOrder(option:Questionoptions1){
    //    option.
    }
    
    
    func checkConsent(){
        let personSearch =  getCascadeQuestionUsingQuestionCode(questionCode: "C13")
        let propertySearch =  getCascadeQuestionUsingQuestionCode(questionCode: "C14")
        let quest = getQuestionUsingQuestionCode(question_code: 17).questionoptions!
        var select = false
        if personSearch.questionoptions![0].isSelected || propertySearch.questionoptions![0].isSelected{
            select = true
          }
                      for opt in quest{
                       if opt.physical_attribute == "1"{
                           opt.isSelected = select
                             continue
                       }
                   }
    }
    
    
    func setOrderId( questCode:String , orderId : String){
        let personSearch = getCascadeQuestionUsingQuestionCode(questionCode: questCode)
        
        personSearch.order_number = orderId
     
    }
    
    
    func moveSelectedToTop(Array:[Questionoptions1] , questionCode:String)->[Questionoptions1]{
        var i = 0
        var optnArray = Array

        if questionCode != "5" && questionCode != "25"{
        for option in Array{
            if option.isSelected && option.tag != "Description"{
                let element = optnArray.remove(at: i)
                optnArray.insert(element, at: 0)
            }
            i += 1
        }
        }
        return optnArray
       }
  
    
    
    func getCascadeQuestionUsingQuestionCode(questionCode:String) -> QuestionResult1{
        var quest:QuestionResult1?
        for question in cascadeQuestionArray!{
            if question.question_code == questionCode{
                quest = question
            }
        }
        return quest!
    }
    
    
    func getCascadeQuestionUsingId(questionID:Int) -> QuestionResult1{
        var quest:QuestionResult1?
        for question in cascadeQuestionArray!{
            if Int(question.id) == questionID{
                quest = question
                print(quest?.questionoptions)
            }
        }
        if questionID == 35{
            quest = getQuestionUsingQuestionCode(question_code: 15)
        }
        return quest!
    }
    
    
    func getQuestionUsingId(questionID:Int) -> QuestionResult1{
        var quest:QuestionResult1?
        for question in questionsArray!{
            if Int(question.id) == questionID{
                quest = question
            }
        }
         return quest!
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
    
    func removeThisRipa(){
        db.deleteAllfrom(table: "ripaTempMasterTable WHERE key = \(AppConstants.key)")
        db.deleteAllfrom(table: "saveRipaPersonTable WHERE key = \(AppConstants.key)")
        db.deleteAllfrom(table: "useSaveRipaOptionsTable WHERE key = \(AppConstants.key)")
    }
    
    
    func removeSavedData(){
        db.deleteAllfrom(table: "saveRipaPersonTable WHERE key = \(AppConstants.key)")
        db.deleteAllfrom(table: "useSaveRipaOptionsTable WHERE key = \(AppConstants.key)")
    }
    
    func showConcateLocation()->String{
        var city = ""
        var street = ""
        var block = ""
        var intesection = ""
        
        for quest in cascadeQuestionArray!{
            if quest.question_code == "C6"{
                if quest.questionoptions!.count > 0{
                    city = (quest.questionoptions![0]).option_value
                  }
            }
             if quest.question_code == "C7"{
                if quest.questionoptions!.count > 0{
                    street = (quest.questionoptions![0]).option_value
                    AppConstants.address  = street
                 }
            }
             if quest.question_code == "C25"{
                if quest.questionoptions!.count > 0{
                    block = (quest.questionoptions![0]).option_value
                 }
            }
             if quest.question_code == "C26"{
                if quest.questionoptions!.count > 0{
                    intesection = (quest.questionoptions![0]).option_value
                 }
            }
          }
        var  loc = ""
        if city != "" && (block != "" || intesection != "") {
            loc = street
            
                if block != "" {
                     loc = block + " BLK" + " " + loc
                 }
            if intesection != ""{
                     loc = loc + " & " + intesection
              }
            AppConstants.address =  loc
           }
        if city == "" {
            loc = ""
        }
       
        return loc
    }
    
    
    
    func deleteRipaPram(activityId:String){
        let id = AppManager.getLastSavedLoginDetails()?.id
        let param:[String : Any] = ["activityId": activityId, "access_token": AppManager.getLastSavedLoginDetails()?.result?.access_token ?? ""]
        let params:[String : Any] =  ["id": id!, "method":"ripaActivityDeletion", "params":param ,"jsonrpc": "2.0"]
        //let params = EnrollmentUser.newRipaQuestionsData(newenroll:enrolluser)
        print(params)
        deleteRipa(params: params)
    }
    
    func deleteRipa(params: [String:Any]){
        var URL:String?
        
        URL = AppConstants.Api.otpRequest
        
        ApiManager.deleteRipa(params: params, methodTyPe: .post, url: URL!, completion: { json,successmsg   in
            AppUtility.hideProgress(nil)
            if successmsg == "Success"{
                if let json = try? JSON(data: json as! Data) {
                    let errorMsg = json["result"][0]["serviceError"].stringValue
                     if  errorMsg == ""{
                        //self.saveDelegate?.moveToPrevScreen(move: true)
                       // self.questiondelegate?.setStatusCount(countArray:countArr)
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
    
    
   }



extension NewRipaViewController{
    
    
    func addCascadeOptions() {
         for option in optionsArray!{
             option.order_number = orderId!
            option.mainQuestOrder = orderId!
            
            option.isQuestionMandatory = questionArray![questNumber!].isDescription_Required
            option.isQuestionDescriptionReq = questionArray![questNumber!].is_required
            option.main_question_id = questionId
 
            
            if option.cascade_ripa_id != ""{
                let cascadeRipaId = option.cascade_ripa_id
                
 //                if questionArray![questNumber!].question_code == "25" && option.question_code_for_cascading_id != "C29" {
//                    continue
//                }
                let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(cascadeRipaId)!)
               // for cascadeQuestion in cascadeQuestionArray!{
                   //  if cascadeQuestion.id == cascadeRipaId{
                
                        cascadeQuestion.order_number = orderId!
                         cascadeQuestionType = cascadeQuestion.questionTypeCode
                        option.questionoptions = cascadeQuestion.questionoptions
                         option.isExpanded = false
                        if option.isSelected == true{
                            option.isExpanded = true
                        }
                
                for opt in cascadeQuestion.questionoptions!{
                    opt.order_number = orderId!
                    opt.mainQuestOrder = orderId!
                    opt.main_question_id = questionId
                }
                
                
                   // }

                //  }
            }
        }
    }
    
    

    
}
