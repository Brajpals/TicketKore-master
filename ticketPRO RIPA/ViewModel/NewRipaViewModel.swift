//
//  NewRipaViewModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 17/02/21.
//

import Foundation
import SwiftyJSON


protocol newRipaModelDelegate: AnyObject {
    func proceedToAddViolationReasonStopTypeOfStop()
 }


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
    
    weak var  delegate: newRipaModelDelegate?
    
    
    
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
             if feature.feature == "RipaCounty"  &&  feature.isActive == "Y"  &&  feature.admin == "Y"  &&  feature.officer == "Y"{
                AppConstants.ripaCounty = "Y"
           }
            if feature.feature == "RipaGps"  &&  feature.isActive == "Y"  &&  feature.admin == "Y"  &&  feature.officer == "Y"{
               AppConstants.ripaGPS = "Y"
          }
            if feature.feature == "RipaTimeDuration"  &&  feature.isActive == "Y"  &&  feature.admin == "Y"  &&  feature.officer == "Y"{
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
                            opt.option_id = "0"
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
    
  
    
    func getHighways(cityID:String)->([LocationResult],Location){
        db.openDatabase()
                var locations = [LocationResult]()
                var filteredLocation = [LocationResult]()

                 let jsonString = db.getCity(tableName: "locationTable")
        if jsonString != nil{
                if let data = jsonString!.data(using: .utf8) {
                    if let json = try? JSON(data: data) {
                        for item in json["result"].arrayValue {
                          
                            let location = LocationResult(location_id: item["location_id"].stringValue, custid: item["custid"].stringValue, location: item["location"].stringValue, zone_id: item["zone_id"].stringValue, order_number: item["order_number"].stringValue, is_active: item["is_active"].stringValue, county_id: item["county_id"].stringValue, city_id: item["city_id"].stringValue, isSelected: false, Highway:  item["Highway"].stringValue)
                           
                            locations.append(location)
                            if cityID == location.city_id && item["Highway"].stringValue == "1"{
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
        AppUtility.hideProgress()
      //  let filteredLocation = locations.filter({ (cityID).contains($0.city_id)})
             return (filteredLocation,locationObj)
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
                          
                            let location = LocationResult(location_id: item["location_id"].stringValue, custid: item["custid"].stringValue, location: item["location"].stringValue, zone_id: item["zone_id"].stringValue, order_number: item["order_number"].stringValue, is_active: item["is_active"].stringValue, county_id: item["county_id"].stringValue, city_id: item["city_id"].stringValue, isSelected: false, Highway: item["Highway"].stringValue)
                            
                               locations.append(location)
                              if cityID == location.city_id && item["Highway"].stringValue != "1"{
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
                           // print(item)
                            let school = SchoolResult(schoolsID: item["schools_Id"].stringValue, custid: item["custid"].stringValue, cdsCode: item["CDSCode"].stringValue, ncesDist: item["NCESDist"].stringValue, ncesSchool: item["NCESSchool"].stringValue, statusType: item["StatusType"].stringValue, countyid: item["countyid"].stringValue, county: item["County"].stringValue, district: item["District"].stringValue, school: item["School"].stringValue, street: item["Street"].stringValue, streetABR: item["StreetAbr"].stringValue, cityid: item["cityid"].stringValue, city: item["City"].stringValue, zip: item["Zip"].stringValue, state: item["State"].stringValue, phone: item["Phone"].stringValue, ext: item["Ext"].stringValue, faxNumber: item["FaxNumber"].stringValue, email: item["Email"].stringValue, webSite: item["WebSite"].stringValue, doc: item["DOC"].stringValue, docType: item["DOCType"].stringValue, soc: item["SOC"].stringValue, socType: item["SOCType"].stringValue, edOpsCode: item["EdOpsCode"].stringValue, edOpsName: item["EdOpsName"].stringValue, eilCode: item["EILCode"].stringValue, eilName: item["EILName"].stringValue, gSoffered: item["GSoffered"].stringValue, gSserved: item["GSserved"].stringValue, latitude: item["Latitude"].stringValue, longitude: item["Longitude"].stringValue, isK12School: item["isK_12School"].stringValue, isActive: item["isActive"].stringValue, orderNumber: item["order_number"].stringValue, createdBy: item["CreatedBy"].stringValue, createdOn: item["CreatedOn"].stringValue, updatedBy: item["UpdatedBy"].stringValue, updatedOn: item["UpdatedOn"].stringValue, isSelected: false)
                            
                            if cityID == school.cityid && school.statusType == "Active"{
                                schools.append(school)
                            }
                           
                         }
                      }
                }
                }
        
        let schl = self.getSchoolForDiffernt(cityID: "0")
        if !schl.isEmpty {
            schools.append(schl[0])
        }
       
        return (schools)
     }
    
    func getSchoolForDiffernt(cityID:String)->([SchoolResult]){
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
                            let violation = ViolationsResult(violationID: item["violation_id"].stringValue, custid: item["custid"].stringValue, violation: item["violation"].stringValue, code: item["code"].stringValue, orderNumber: item["order_number"].stringValue, violationDisplay: item["violation_display"].stringValue, isActive: item["is_active"].stringValue, violationType: item["violation_type"].stringValue, violationGroup: item["violation_group"].stringValue, offense_code: item["offense_code"].stringValue , isSelected: false, isNewAdded: false, mainId: "")
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
    
    

    func createObj(mainQuestId:String?,ripaID:String?,optionValue:String?,physical_attribute:String?, description:String?,isSelected:Bool,mainQuestOrder:String,isNewAdded : Bool,mainId:String)->Questionoptions1{
        let option:Questionoptions1 = Questionoptions1(mainQuestId: mainQuestId!, mainQuestOrder:mainQuestOrder ,option_id: "0", ripa_id:ripaID!, custid: "", option_value: optionValue!, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: mainQuestOrder, createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: isSelected, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "", tag: "", physical_attribute: physical_attribute!, default_value: "", optionDescription: description!, question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: mainQuestId!, isExpanded: false, isNewAdded: isNewAdded, mainId: mainId, questionoptions: [])
        return option
    }
    
    func setIsPersonStudentOrder() -> Questionoptions1 {
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "61", mainQuestOrder:"3" ,option_id: "1234", ripa_id:"61", custid: "", option_value: "Is person a student?", cascade_ripa_id: "62", isK_12School: "", isHideQuesText: "", order_number: "3", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "AN", questionTypeCode: "SC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C27", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        return option1
    }
    
    func setPercievedAgeOption() -> Questionoptions1 {
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "61", mainQuestOrder:"3" ,option_id: "1248", ripa_id:"61", custid: "", option_value: "Perceived Age?", cascade_ripa_id: "65", isK_12School: "", isHideQuesText: "", order_number: "3", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "N", questionTypeCode: "SL", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C29", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        return option1
    }
    
    func setIsPersonStudentOption() -> Questionoptions1 {
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "C27", mainQuestOrder:"3" ,option_id: "1246", ripa_id:"C27", custid: "", option_value: "No", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "3", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        return option1
    }
    
    func setLimitedOrNoEnglishFluenctQuestion() -> Questionoptions1 {
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "61", mainQuestOrder:"3" ,option_id: "1240", ripa_id:"61", custid: "", option_value: "Limited or No English Fluency?", cascade_ripa_id: "68", isK_12School: "", isHideQuesText: "", order_number: "3", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "AN", questionTypeCode: "SC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C33", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        return option1
    }
    
    func setLimitedOrNoEnglishFluenctOption() -> Questionoptions1 {
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "68", mainQuestOrder:"3" ,option_id: "1258", ripa_id:"68", custid: "", option_value: "No", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "3", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        return option1
    }
    
    func setEducationCodeOption() -> Questionoptions1 {
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "46", mainQuestOrder:"10" ,option_id: "222", ripa_id:"46", custid: "", option_value: "Education Code", cascade_ripa_id: "47", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        return option1
    }
    
    func setWrittenWarningOption() -> Questionoptions1 {
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "74", mainQuestOrder:"17" ,option_id: "1291", ripa_id:"74", custid: "", option_value: "Written Warning", cascade_ripa_id: "76", isK_12School: "", isHideQuesText: "", order_number: "17", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "V ", questionTypeCode: "LV", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C41", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "39", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        return option1
    }
    
    func setClosestIntersectionOption() -> Questionoptions1 {
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1410", ripa_id: "118", custid: "1", option_value: "Closest Intersection", cascade_ripa_id: "121", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A", questionTypeCode: "MC", tag: "", physical_attribute: "3", default_value: "", optionDescription: "", question_code_for_cascading_id: "C55", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        return option1
    }
    
    func setTrafficViolationOption() -> Questionoptions1 {
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "15", mainQuestOrder: "10", option_id: "93", ripa_id: "15", custid: "", option_value: "Specific code (CJIS offense table; select drop down)", cascade_ripa_id: "20", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "V ", questionTypeCode: "LV", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C5", isQuestionMandatory: "", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        return option1
    }
    
    func createPersonInformation(selectedOptionArray : [[Questionoptions1]]) -> [Questionoptions1] {
        var selectArray = [Questionoptions1]()
        
        // is person a student ?
        let obj1 = selectedOptionArray[2].filter({$0.cascade_ripa_id == "62"})
        if obj1.count > 0 {
            selectArray.append(obj1[0])
        }
        else {
            selectArray.append(self.setIsPersonStudentOrder())
        }
        let obj2 = selectedOptionArray[2].filter({$0.ripa_id == "62"})
        if obj2.count > 0 {
            selectArray.append(obj2[0])
        }
        else {
            selectArray.append(self.setIsPersonStudentOption())
        }
        
        //Age
        let obj3 = selectedOptionArray[2].filter({$0.cascade_ripa_id == "65"})
        if obj3.count > 0 {
            selectArray.append(obj3[0])
        }
        let obj4 = selectedOptionArray[2].filter({$0.ripa_id == "65"})
        if obj4.count > 0 {
            selectArray.append(obj4[0])
        }
        
        //Perceived Gender
        let obj5 = selectedOptionArray[2].filter({$0.cascade_ripa_id == "64"})
        if obj5.count > 0 {
            selectArray.append(obj5[0])
        }
        let obj6 = selectedOptionArray[2].filter({$0.ripa_id == "64"})
        if obj6.count > 0 {
            selectArray.append(obj6[0])
        }
        
        //Perceived Sexual Orientation
        let obj7 = selectedOptionArray[2].filter({$0.cascade_ripa_id == "66"})
        if obj7.count > 0 {
            selectArray.append(obj7[0])
        }
        let obj8 = selectedOptionArray[2].filter({$0.ripa_id == "66"})
        if obj8.count > 0 {
            selectArray.append(obj8[0])
        }
        
        //Perceived Race
        let obj9 = selectedOptionArray[2].filter({$0.cascade_ripa_id == "67"})
        if obj9.count > 0 {
            selectArray.append(obj9[0])
        }
        let obj10 = selectedOptionArray[2].filter({$0.ripa_id == "67"})
        for optObj in obj10 {
            selectArray.append(optObj)
        }
        
        //Perceived Disability?
        let obj11 = selectedOptionArray[2].filter({$0.cascade_ripa_id == "69"})
        if obj11.count > 0 {
            selectArray.append(obj11[0])
        }
        let obj12 = selectedOptionArray[2].filter({$0.ripa_id == "69"})
        for optObj in obj12 {
            selectArray.append(optObj)
        }
        
        //Limited or No English Fluence?
        let obj13 = selectedOptionArray[2].filter({$0.cascade_ripa_id == "68"})
        if obj13.count > 0 {
            selectArray.append(obj13[0])
        }
        else {
            selectArray.append(self.setLimitedOrNoEnglishFluenctQuestion())
        }
        let obj14 = selectedOptionArray[2].filter({$0.ripa_id == "68"})
        if obj14.count > 0 {
            selectArray.append(obj14[0])
        }
        else {
            selectArray.append(self.setLimitedOrNoEnglishFluenctOption())
        }
      
        return selectArray
    }
    
    
    func makeSelectedOptionList(isSaved : Bool)->[[Questionoptions1]]{
        var  selectedOptions=[Questionoptions1]()
        var createSelectedArray = [[Questionoptions1]]()
        
        for quest in questionsArray!{
            print(selectedOptions.count)
            selectedOptions.removeAll()
 
            for  optionn in quest.questionoptions!{
                
                optionn.mainQuestOrder = quest.order_number
                optionn.order_number = quest.order_number
                optionn.main_question_id = quest.id
                
                var cascadeQuestionID = (optionn).cascade_ripa_id
                if (optionn).isSelected && (optionn).mainQuestId == "21" && (optionn).mainQuestOrder == "2" && (optionn).option_id == "0" && (optionn).ripa_id == "108" && (optionn).order_number == "2" && (optionn).main_question_id == "108" {
                    continue
                }
               else if (optionn).isSelected && cascadeQuestionID == ""{
                    selectedOptions.append(optionn)
                   if quest.question_code == "21"{
                      if  quest.questionoptions!.contains(where: {
                          $0.isSelected == true && $0.physical_attribute == "1"
                      }) {
                          continue
                      }
                   }
                }
                
                if quest.question_code == "21"{
                    if  quest.questionoptions!.contains(where: {
                        $0.isSelected == true && $0.physical_attribute == "1"
                    }) {
                        continue
                    }
                }
                else if quest.question_code == "14" && optionn.option_value.capitalized == "Traffic Violation"{
                   // cascadeQuestionID = "16"
                }
                
                if quest.question_code == "14" && optionn.mainQuestOrder == "10" && (optionn.option_id == "0" || optionn.option_id == "") && optionn.isSelected == true && optionn.isQuestionDescriptionReq == "1" {
                    print(quest.question_code)
                  //  selectedOptions.append(option )
                }
                  if  cascadeQuestionID != ""{
                
                      if quest.question_code == "T5" && (optionn).questionTypeCode == "SC" && (optionn).inputTypeCode == "AN" && selectedOptions.contains(where: { name in name.option_value != optionn.option_value }){
                          
                          let exist = selectedOptions.contains(where: {
                              $0.option_value == optionn.option_value
                          })
                          if exist {
                              selectedOptions.remove(object: optionn)
                           }
                        
                          selectedOptions.append(optionn )
                       }
                     else
                      if quest.question_code == "T6" && (optionn).questionTypeCode == "SC" && (optionn).inputTypeCode == "AN"{
                          selectedOptions.append(optionn)
                       }

                      else if quest.question_code == "5"{
                           selectedOptions.append(optionn)
                        }
                      else if quest.question_code == "T5",selectedOptionsArray.count > 1 && selectedOptionsArray[1].contains(where: { name in name.option_id == optionn.option_id }){
                          let index = selectedOptionsArray[1].firstIndex(where: {
                              $0.option_id == optionn.option_id
                          })
                           selectedOptions.remove(at: index!)
                           selectedOptions.append(optionn )
                        }
                      else if quest.question_code == "T5" {
                          selectedOptions.append(optionn)
                      }
//                      else if quest.question_code == "25" && optionn.cascade_ripa_id == "62" && optionn.isSelected == false{
//                          selectedOptions.append(optionn)
//                      }
                      else if (optionn).isSelected{
                          selectedOptions.append(optionn)
                      }
                     
                      
                    var cascadeQuest = getCascadeQuestionUsingId(questionID: Int(cascadeQuestionID)!)
                      if isSaved && quest.question_code == "T6" {
                          cascadeQuest = QuestionResult1(id: optionn.cascade_ripa_id, custid: optionn.custid, question: optionn.option_value, question_info: "Testing Purpose", question_key: "", question_code: optionn.question_code_for_cascading_id, questionTypeId: optionn.isQuestionDescriptionReq, inputTypeId: "2", is_add_value: "0", internal: "0", is_required: optionn.isQuestionDescriptionReq, isAddtion: "0", isCascade_Question: "1", ripa_group_id: "", isDescription_Required: "", common_question: "", editable_question: "", visible_question: "1", order_number: optionn.order_number, is_active: "1", CreatedBy: optionn.createdBy, CreatedOn: optionn.createdOn, UpdatedBy: optionn.updatedBy, UpdatedOn: optionn.updatedOn, inputTypeCode: optionn.inputTypeCode, questionTypeCode: optionn.questionTypeCode, groupName: "", questionoptions: [])
                          cascadeQuest.questionoptions = self.setPassengerOptions(cascadeId: cascadeQuestionID)
                          cascadeQuestionID = ""
                      }
                      if cascadeQuestionID == "35" && cascadeQuest.questionoptions?.count ?? 0 > 2 {
                          cascadeQuest = getCascadeQuestionUsingId(questionID: 63)
                      }
                      if quest.question_code == "T5" && cascadeQuest.questionoptions?.count == 0 && cascadeQuestionID == "101"{
                          cascadeQuest.questionoptions = self.setOptionOrder()
                      }
                     
                      if quest.question_code == "T5" && cascadeQuest.questionoptions?.count == 0 && cascadeQuestionID == "79"{
                          let objjj = self.setStopInformationOption(questId: "79")
                          objjj[1].isSelected = true
                          cascadeQuest.questionoptions = objjj
                      }
                    
                    for  option in cascadeQuest.questionoptions!{
                        
                        option.mainQuestOrder = quest.order_number
                        option.order_number = quest.order_number
                        option.main_question_id = quest.id
                            
                        cascadeQuestionID = (option ).cascade_ripa_id
                        
                        if quest.question_code == "25" && option.ripa_id == "62" && option.isSelected == false {
                             continue
                            //is person student
                          }
                        
                        if optionn.ripa_id == "61" && optionn.cascade_ripa_id == "62"{
                            let filteredArray = cascadeQuest.questionoptions?.filter{$0.isSelected == true}
                            if option.option_value.capitalized == "No" && filteredArray?.count == 0{
                                selectedOptions.append(option )
                            }
                        }
                        
                        if (option ).isSelected && quest.question_code == "21" && option.mainQuestId == "73" && option.questionTypeCode.count == 0{
                           continue
                        }
                       else if (option ).isSelected && cascadeQuestionID == "" && option.mainQuestId == "21" && quest.question_code == "T5"{
                           continue
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "78" && option.option_id == "1295" && (option ).isSelected {
                            selectedOptions.append(option )
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "78" && option.option_id == "1296" && (option ).isSelected {
                            selectedOptions.append(option )
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "78" && option.option_id == "1297" && (option ).isSelected {
                            selectedOptions.append(option )
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "79" && (option ).isSelected{
                            selectedOptions.append(option )
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "80" && option.option_value == "No" {
                            if let object = selectedOptions.first(where: { $0.mainQuestId == "80"}) {}
                            else {
                                selectedOptions.append(option)
                            }
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "79" && option.option_value == "No" {
                            if let object = selectedOptions.first(where: { $0.mainQuestId == "79"}) {}
                            else {
                                selectedOptions.append(option)
                            }
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "101" && (option).isSelected{
                            selectedOptions.append(option )
                        }
                       
                        else if quest.question_code == "T5" && option.mainQuestId == "101" && option.option_value == "No" {
                            if let object = selectedOptions.first(where: { $0.mainQuestId == "101"}) {}
                            else {
                                selectedOptions.append(option )
                            }
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "35"  && (option ).isSelected {
                            selectedOptions.append(option )
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "35" && option.option_value == "No" {
                            if let object = selectedOptions.first(where: { $0.mainQuestId == "35"}) {}
                            else {
                                selectedOptions.append(option )
                            }
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "108"  && (option ).isSelected {
                            selectedOptions.append(option )
                        }
                        else if quest.question_code == "T5" && option.mainQuestId == "108" && option.option_value == "No" {
                            if let object = selectedOptions.first(where: { $0.mainQuestId == "108"}) {}
                            else {
                                selectedOptions.append(option )
                            }
                        }
                     
                       
                       if quest.question_code != "T5" && (option ).isSelected && cascadeQuestionID == ""{
                           if quest.question_code == "T6" && (option ).option_value == "Yes" && selectedOptions.count > 0{
                               selectedOptions[selectedOptions.count - 1].isSelected = true
                           }
                           selectedOptions.append(option )
                        }
                        else if quest.question_code != "T5" {
                          //  selectedOptions.append(option )
                        }


                          if cascadeQuestionID != ""{
                            if  quest.question_code == "21" && (optionn ).isSelected == false{
                                continue
                             }
                            else
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
                            }
                        }
                    }
                }
            }
            
            if quest.question_code == "5" && quest.questionoptions?.count == 3{
                let optionObj = self.setLocationOptions()
                for opt in optionObj{
                    selectedOptions.append(opt)
                }
            }
            createSelectedArray.append(selectedOptions)
        }
        return createSelectedArray
     }
    
    func setPassengerOptions(cascadeId : String) -> [Questionoptions1] {
        var passOption = [Questionoptions1] ()
        if cascadeId == "77" {
            let blockObj = Questionoptions1(mainQuestId: "77", mainQuestOrder: "4", option_id: "1292", ripa_id: "77", custid: "", option_value: "Yes", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "4", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "109", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(blockObj)
            
            let blockObjj = Questionoptions1(mainQuestId: "77", mainQuestOrder: "4", option_id: "1293", ripa_id: "77", custid: "", option_value: "No", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "4", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "109", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(blockObjj)
        }
        else  if cascadeId == "80" {
            let blockObj = Questionoptions1(mainQuestId: "77", mainQuestOrder: "4", option_id: "1300", ripa_id: "77", custid: "", option_value: "Yes", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "4", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "109", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(blockObj)
            
            let blockObjj = Questionoptions1(mainQuestId: "77", mainQuestOrder: "4", option_id: "1301", ripa_id: "77", custid: "", option_value: "No", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "4", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "109", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(blockObjj)
        }
        else  if cascadeId == "83" {
            let blockObj = Questionoptions1(mainQuestId: "77", mainQuestOrder: "4", option_id: "1302", ripa_id: "77", custid: "", option_value: "Yes", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "4", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "109", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(blockObj)
            
            let blockObjj = Questionoptions1(mainQuestId: "77", mainQuestOrder: "4", option_id: "1303", ripa_id: "77", custid: "", option_value: "No", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "4", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "109", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(blockObjj)
        }
        return passOption
    }
    
    
    func setLocationOptions() -> [Questionoptions1] {
        var passOption = [Questionoptions1] ()
        if AppConstants.LocTypeIndex == 1 {
            let blockObjj = Questionoptions1(mainQuestId: "21", mainQuestOrder: "1", option_id: "0", ripa_id: "120", custid: "", option_value: AppConstants.street, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A ", questionTypeCode: "MC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(blockObjj)
        }
        else if AppConstants.LocTypeIndex == 2 {
          //"Closest Intersection"
            let blockObjj = Questionoptions1(mainQuestId: "21", mainQuestOrder: "1", option_id: "0", ripa_id: "121", custid: "", option_value: AppConstants.firstIntersection, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A ", questionTypeCode: "MC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(blockObjj)
            let blockObjjj = Questionoptions1(mainQuestId: "21", mainQuestOrder: "1", option_id: "0", ripa_id: "121", custid: "", option_value: AppConstants.secondIntersection, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A ", questionTypeCode: "MC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(blockObjjj)
        }
        else if AppConstants.LocTypeIndex == 3 {
          //"Highway and Closest Highway Exit"
            let blockObjj = Questionoptions1(mainQuestId: "21", mainQuestOrder: "1", option_id: "0", ripa_id: "122", custid: "", option_value: AppConstants.highway, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A ", questionTypeCode: "MC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(blockObjj)
        }
        else if AppConstants.LocTypeIndex == 4 {
             //"Other"
        }
        else {
                //"Geographic Coordinates"
        }
      
        return passOption
    }
    
    func setOptionOrder() -> [Questionoptions1] {
        var passOption = [Questionoptions1] ()
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "101", mainQuestOrder:"2" ,option_id: "1413", ripa_id:"101", custid: "1", option_value: "Yes", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        passOption.append(option1)
        
        let option2:Questionoptions1 = Questionoptions1(mainQuestId: "101", mainQuestOrder:"2" ,option_id: "1414", ripa_id:"101", custid: "1", option_value: "NO", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        passOption.append(option2)
        
        return passOption
    }
    
    func setDescriptionForReasonForStop(stringg : String) -> Questionoptions1 {
        let passOption:Questionoptions1 = Questionoptions1(mainQuestId: "14", mainQuestOrder:"10" ,option_id: "", ripa_id:"14", custid: "", option_value: stringg, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "Description", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        
        return passOption
    }
    
    func setDescriptionForBasisForSearch(descripStr : String) -> Questionoptions1 {
        let passOption:Questionoptions1 = Questionoptions1(mainQuestId: "25", mainQuestOrder:"13" ,option_id: "", ripa_id:"25", custid: "", option_value: descripStr, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "13", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "Description", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "1", isQuestionDescriptionReq: "1", main_question_id: "25", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        
        return passOption
    }
    
    func setStopInformationOption(questId : String) -> [Questionoptions1] {
        var passOption = [Questionoptions1] ()
        if questId == "35" {
            let option1:Questionoptions1 = Questionoptions1(mainQuestId: "35", mainQuestOrder:"2" ,option_id: "169", ripa_id:"35", custid: "", option_value: "Yes", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(option1)
            
            let option2:Questionoptions1 = Questionoptions1(mainQuestId: "35", mainQuestOrder:"2" ,option_id: "170", ripa_id:"35", custid: "", option_value: "No", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(option2)
        }
        else if questId == "79" {
            let option1:Questionoptions1 = Questionoptions1(mainQuestId: "79", mainQuestOrder:"2" ,option_id: "1298", ripa_id:"79", custid: "", option_value: "Yes", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(option1)
            
            let option2:Questionoptions1 = Questionoptions1(mainQuestId: "79", mainQuestOrder:"2" ,option_id: "1299", ripa_id:"79", custid: "", option_value: "No", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(option2)
        }
        else {
            let option1:Questionoptions1 = Questionoptions1(mainQuestId: "101", mainQuestOrder:"2" ,option_id: "1413", ripa_id:"101", custid: "", option_value: "Yes", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(option1)
            
            let option2:Questionoptions1 = Questionoptions1(mainQuestId: "101", mainQuestOrder:"2" ,option_id: "1414", ripa_id:"101", custid: "", option_value: "No", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            passOption.append(option2)
        }
        
        return passOption
    }
    
    func setviolationType() -> [Questionoptions1] {
        var passOption = [Questionoptions1] ()
        let option1:Questionoptions1 = Questionoptions1(mainQuestId: "16", mainQuestOrder:"10" ,option_id: "95", ripa_id:"16", custid: "", option_value: "Equipment violation", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "2", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        passOption.append(option1)
        
        let option2:Questionoptions1 = Questionoptions1(mainQuestId: "16", mainQuestOrder:"10" ,option_id: "96", ripa_id:"16", custid: "", option_value: "Moving violation", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "1", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        passOption.append(option2)
        
        let option3:Questionoptions1 = Questionoptions1(mainQuestId: "16", mainQuestOrder:"10" ,option_id: "94", ripa_id:"16", custid: "", option_value: "Non-moving violation including registration violation", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "3", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        passOption.append(option3)
        
        return passOption
    }
    
    func checkConsent(){
        let personSearch =  getCascadeQuestionUsingQuestionCode(questionCode: "C13")
        let propertySearch =  getCascadeQuestionUsingQuestionCode(questionCode: "C14")
        let quest = getQuestionUsingQuestionCode(question_code: 17).questionoptions!
         var select = false
    
        if personSearch.questionoptions![1].isSelected || propertySearch.questionoptions![1].isSelected{
            select = false
        }
        else if personSearch.questionoptions![0].isSelected || propertySearch.questionoptions![0].isSelected{
            select = true
        }
        
        
        for opt in quest{
         if opt.physical_attribute == "1"{
             opt.isSelected = select
             opt.questionoptions?.forEach({$0.isSelected = false})
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
                print(question.question_code)
                if question.question_code == questionCode{
                    quest = question
                }
            }
            return quest!
    }
    
    func createDisabilityOptions () -> [Questionoptions1]{
         var personArr = NSArray()
        if let myarray : NSArray = UserDefaults.standard.object(forKey: "personInfo") as? NSArray{
            personArr = myarray
         }
        print(personArr)
        var optionArray = [Questionoptions1]()
        let Obj = Questionoptions1(mainQuestId: "69", mainQuestOrder: "3", option_id: "1269", ripa_id: "69", custid: "1", option_value: "None", cascade_ripa_id: "", isK_12School: "0", isHideQuesText: "", order_number: "3", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "8", default_value: "1", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        for i in (0..<personArr.count)
        {
            if Obj.mainQuestId == (personArr[i] as AnyObject)["question_id"]! as? String && Obj.physical_attribute == (personArr[i] as AnyObject)["physical_attribute"]! as? String {
                Obj.isSelected = true
             }
        }
        optionArray.append(Obj)
        
        let Objj = Questionoptions1(mainQuestId: "69", mainQuestOrder: "3", option_id: "1263", ripa_id: "69", custid: "1", option_value: "Blind or limited vision", cascade_ripa_id: "", isK_12School: "0", isHideQuesText: "", order_number: "3", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "3", default_value: "0", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        for i in (0..<personArr.count)
        {
            if Objj.mainQuestId == (personArr[i] as AnyObject)["question_id"]! as? String && Objj.physical_attribute == (personArr[i] as AnyObject)["physical_attribute"]! as? String {
                Objj.isSelected = true
             }
        }
        optionArray.append(Objj)
        
        let Objjj = Questionoptions1(mainQuestId: "69", mainQuestOrder: "3", option_id: "1261", ripa_id: "69", custid: "1", option_value: "Deafness or difficulty hearing", cascade_ripa_id: "", isK_12School: "0", isHideQuesText: "", order_number: "3", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "1", default_value: "3", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        for i in (0..<personArr.count)
        {
            if Objjj.mainQuestId == (personArr[i] as AnyObject)["question_id"]! as? String && Objjj.physical_attribute == (personArr[i] as AnyObject)["physical_attribute"]! as? String {
                Objjj.isSelected = true
             }
        }
        optionArray.append(Objjj)
        
        let Objjjj = Questionoptions1(mainQuestId: "69", mainQuestOrder: "3", option_id: "1267", ripa_id: "69", custid: "1", option_value: "Disability related to hyperactivity or implusion behaviour", cascade_ripa_id: "", isK_12School: "1", isHideQuesText: "", order_number: "0", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "7", default_value: "0", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        for i in (0..<personArr.count)
        {
            if Objjjj.mainQuestId == (personArr[i] as AnyObject)["question_id"]! as? String && Objjjj.physical_attribute == (personArr[i] as AnyObject)["physical_attribute"]! as? String {
                Objjjj.isSelected = true
             }
        }
        optionArray.append(Objjjj)
        
        let Objjjjj = Questionoptions1(mainQuestId: "69", mainQuestOrder: "3", option_id: "1265", ripa_id: "69", custid: "1", option_value: "Intellectual or developmental disability, including dementia", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "0", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "5", default_value: "0", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        for i in (0..<personArr.count)
        {
            if Objjjjj.mainQuestId == (personArr[i] as AnyObject)["question_id"]! as? String && Objjjjj.physical_attribute == (personArr[i] as AnyObject)["physical_attribute"]! as? String {
                Objjjjj.isSelected = true
             }
        }
        optionArray.append(Objjjjj)
        
        let Objjjjjj = Questionoptions1(mainQuestId: "69", mainQuestOrder: "3", option_id: "1264", ripa_id: "69", custid: "1", option_value: "Mental health condition", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "0", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "4", default_value: "0", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        for i in (0..<personArr.count)
        {
            if Objjjjjj.mainQuestId == (personArr[i] as AnyObject)["question_id"]! as? String && Objjjjjj.physical_attribute == (personArr[i] as AnyObject)["physical_attribute"]! as? String {
                Objjjjjj.isSelected = true
             }
        }
        optionArray.append(Objjjjjj)
        
        let Objjjjjjj = Questionoptions1(mainQuestId: "69", mainQuestOrder: "3", option_id: "1266", ripa_id: "69", custid: "1", option_value: "Other disability", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "0", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "6", default_value: "0", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
       
        for i in (0..<personArr.count)
        {
            if Objjjjjjj.mainQuestId == (personArr[i] as AnyObject)["question_id"]! as? String && Objjjjjjj.physical_attribute == (personArr[i] as AnyObject)["physical_attribute"]! as? String {
                Objjjjjjj.isSelected = true
             }
        }
        optionArray.append(Objjjjjjj)
        
        let Objjjjjjjj = Questionoptions1(mainQuestId: "69", mainQuestOrder: "3", option_id: "1262", ripa_id: "69", custid: "1", option_value: "Speech impairment or limited use of language", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "0", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "2", default_value: "0", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        for i in (0..<personArr.count)
        {
            if Objjjjjjjj.mainQuestId == (personArr[i] as AnyObject)["question_id"]! as? String && Objjjjjjjj.physical_attribute == (personArr[i] as AnyObject)["physical_attribute"]! as? String {
                Objjjjjjjj.isSelected = true
             }
        }
        optionArray.append(Objjjjjjjj)
            
        return optionArray
    }
    
    func getCascadeQuestionUsingId(questionID:Int) -> QuestionResult1{
        var quest:QuestionResult1?
        var quId : Int = questionID

        let arr = cascadeQuestionArray
     //   print(arr)
        
        for question in cascadeQuestionArray!{
            print(question.question)
            if Int(question.id) == quId{
                quest = question
               // print(quest?.questionoptions)
             }
             if quId == 66,let check = quest?.questionoptions?.contains(where: { $0.mainQuestId != String(quId)}),check == true {
                 for questionn in cascadeQuestionArray!{
                     if Int(questionn.question_code) == 10{
                         quest = questionn
                     }
                 }
             }
            else if quId == 67,let check = quest?.questionoptions?.contains(where: { $0.mainQuestId != String(quId)}),check == true {
                for questionn in cascadeQuestionArray!{
                    if Int(questionn.question_code) == 8{
                        quest = questionn
                    }
                }
            }
            else if quId == 69,let check = quest?.questionoptions?.contains(where: { $0.mainQuestId != String(quId)}),check == true {
                quest?.questionoptions = self.createDisabilityOptions()
            }
            else if quId == 76 && quest?.questionoptions?.count ?? 0 > 0 {
                for questionn in cascadeQuestionArray!{
                    if (questionn.question_code) == "C41"{
                        quest = questionn
                    }
                }
            }
            else if quId == 64 && quest?.questionoptions?.count ?? 0 > 5 {
                for questionn in cascadeQuestionArray!{
                    if Int(questionn.question_code) == 9{
                        quest = questionn
                    }
                }
            }
        }
        
        if quId == 35{
            quest = getQuestionUsingQuestionCode(question_code: 15)
        }
        else  if quId == 18 , quest?.questionoptions?.count == 0{
           // quest = getQuestionUsingQuestionCode(question_code: 72)
            for questionn in cascadeQuestionArray!{
                if (questionn.question_code) == "C37"{
                    quest = questionn
                }
            }
        }
        
        if let find = quest {
            
        }
        else {
            quest = getQuestionUsingQuestionCode(question_code: 22)
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
    
    func setReasonableSuspiciousOptions(reasonArr : [Questionoptions1]) -> [Questionoptions1] {
        var createArr = [Questionoptions1]()
        let obj1 = reasonArr.filter({$0.cascade_ripa_id == "17"})
        if reasonArr.count == 0,obj1.count > 0 {
            createArr.insert(obj1[0], at: 0)
        }
        else if obj1.count > 0 {
            createArr.append(obj1[0])
        }
        
        let obj2 = reasonArr.filter({$0.cascade_ripa_id == "28"})
        if reasonArr.count == 0,obj2.count > 1 {
            createArr.insert(obj2[0], at: 1)
        }
        else if obj2.count > 0 {
            createArr.append(obj2[0])
        }
        
        let obj3 = reasonArr.filter({$0.ripa_id == "28"})
        for obj in obj3 {
            createArr.append(obj)
        }
        
        let obj4 = reasonArr.filter({$0.cascade_ripa_id == "18"})
        if obj4.count > 0 {
            createArr.append(obj4[0])
        }
        
        let obj5 = reasonArr.filter({$0.ripa_id == "18"})
        for obj in obj5 {
            createArr.append(obj)
        }
        
        for obj in reasonArr {
            let checkk = createArr.contains(where: {$0.option_value == obj.option_value})
            if checkk == false {
                createArr.append(obj)
            }
        }
        
        return createArr
    }
    
    
    func createBasisForSearchConsentGivenOption() -> [Questionoptions1] {
        var questOption = [Questionoptions1]()
        let Obj = Questionoptions1(mainQuestId: "84", mainQuestOrder: "13", option_id: "1306", ripa_id: "84", custid: "", option_value: "Implied by Conduct", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "13", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "3", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "25", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questOption.append(Obj)
        
        let Objj = Questionoptions1(mainQuestId: "84", mainQuestOrder: "13", option_id: "1304", ripa_id: "84", custid: "", option_value: "Verbal", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "13", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "1", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "25", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questOption.append(Objj)
        
        let Objjj = Questionoptions1(mainQuestId: "84", mainQuestOrder: "13", option_id: "1305", ripa_id: "84", custid: "", option_value: "Written", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "13", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "2", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "25", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questOption.append(Objjj)
      
        
        return questOption
    }
    
    func createProbaleCaseToArrestOption() -> [Questionoptions1]  {
        var questOption = [Questionoptions1]()
        let Obj = Questionoptions1(mainQuestId: "70", mainQuestOrder: "10", option_id: "1275", ripa_id: "70", custid: "", option_value: "Specific Code (select one using SDCS Offence table)", cascade_ripa_id: "71", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "V ", questionTypeCode: "LV", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C37", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questOption.append(Obj)
        
        let Objj = Questionoptions1(mainQuestId: "70", mainQuestOrder: "10", option_id: "1276", ripa_id: "70", custid: "", option_value: "Basis (select all that applly)", cascade_ripa_id: "72", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A ", questionTypeCode: "MC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C37", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        
        questOption.append(Objj)
        
        return questOption
    }
    
    func createNonForceRelatedActionOption() -> [Questionoptions1] {
        var questOption = [Questionoptions1]()
        let Obj = Questionoptions1(mainQuestId: "32", mainQuestOrder: "12", option_id: "32", ripa_id: "", custid: "1", option_value: "Consent given", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "12", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "106", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questOption.append(Obj)
        
        let Objj = Questionoptions1(mainQuestId: "32", mainQuestOrder: "12", option_id: "32", ripa_id: "", custid: "1", option_value: "Consent not given", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "12", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "106", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questOption.append(Objj)
        
        return questOption
    }
    
    func createStopInformationOption() -> [Questionoptions1] {
        var questOption = [Questionoptions1]()
        let Obj = Questionoptions1(mainQuestId: "78", mainQuestOrder: "2", option_id: "1296", ripa_id: "78", custid: "", option_value: "Bicycle Stop", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "2", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questOption.append(Obj)
        
        let Objj = Questionoptions1(mainQuestId: "78", mainQuestOrder: "2", option_id: "1297", ripa_id: "78", custid: "", option_value: "Pedestrian Stop", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "3", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questOption.append(Objj)
        
        let Objjj = Questionoptions1(mainQuestId: "78", mainQuestOrder: "2", option_id: "1295", ripa_id: "78", custid: "", option_value: "Vehicular Stop", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "1", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questOption.append(Objjj)
        
        return questOption
    }
    
    func createBlockStreetObject() -> Questionoptions1 {
        let blockObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1409", ripa_id: "118", custid: "1", option_value: "Block Number and Street Name", cascade_ripa_id: "1", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A", questionTypeCode: "MC", tag: "", physical_attribute: "2", default_value: "", optionDescription: "", question_code_for_cascading_id: "C54", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
       return blockObj
    }
    
    func createInfieldOptionObject() -> Questionoptions1 {
        let blockObj = Questionoptions1(mainQuestId: "51", mainQuestOrder: "17", option_id: "225", ripa_id: "51", custid: "", option_value: "In-field cite and release: Code", cascade_ripa_id: "41", isK_12School: "", isHideQuesText: "", order_number: "17", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "V ", questionTypeCode: "LV", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C16", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "39", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
       return blockObj
    }
    
    func createTypeViolationObject() -> Questionoptions1 {
        let blockObj = Questionoptions1(mainQuestId: "15", mainQuestOrder: "10", option_id: "92", ripa_id: "15", custid: "", option_value: "Type Of Violation", cascade_ripa_id: "16", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A ", questionTypeCode: "SC", tag: "", physical_attribute: "1", default_value: "", optionDescription: "", question_code_for_cascading_id: "C2", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
       return blockObj
    }
    
    func createCitationForInfractionObject() -> Questionoptions1 {
        let blockObj = Questionoptions1(mainQuestId: "50", mainQuestOrder: "17", option_id: "224", ripa_id: "50", custid: "", option_value: "Citation for infraction: Code", cascade_ripa_id: "40", isK_12School: "", isHideQuesText: "", order_number: "17", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "V ", questionTypeCode: "LV", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C15", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "39", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
       return blockObj
    }
    
    func createCustodialArrestWithoutWarrantObject() -> Questionoptions1 {
        let blockObj = Questionoptions1(mainQuestId: "24", mainQuestOrder: "17", option_id: "226", ripa_id: "24", custid: "", option_value: "Custodial arrest without warrant: Code", cascade_ripa_id: "42", isK_12School: "", isHideQuesText: "", order_number: "17", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "V ", questionTypeCode: "LV", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C17", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "39", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
       return blockObj
    }
    
    func createVerbalWarningObject() -> Questionoptions1 {
        let blockObj = Questionoptions1(mainQuestId: "73", mainQuestOrder: "17", option_id: "1290", ripa_id: "73", custid: "", option_value: "Verbal Warning", cascade_ripa_id: "75", isK_12School: "", isHideQuesText: "", order_number: "17", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "V ", questionTypeCode: "LV", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C40", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "39", isExpanded: true, isNewAdded: false, mainId: "", questionoptions: [])
       return blockObj
    }
    
    
    func getQuestionUsingQuestionCodeUsingString(question_code:String)->QuestionResult1{
        var quest:QuestionResult1?
         for question in questionsArray!{
             if question.question_code == question_code {
                quest = question
            }
        }
        if quest == nil{
            quest = getCascadeQuestionUsingQuestionCode(questionCode: question_code)
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
    
    func checkPhysicalAttribute(type : String) -> String {
        var attribute : String = "2"
        if type.lowercased() == "cisgender man/boy" {
            attribute = "2"
        }
        else if type.lowercased() == "cisgender woman/girl" {
            attribute = "1"
        }
        else if type.lowercased() == "transgender man/boy" {
            attribute = "3"
        }
        else if type.lowercased() == "transgender woman/girl" {
            attribute = "4"
        }
        else if type.lowercased() == "nonbinary person" {
            attribute = "5"
        }
        else if type.uppercased() == "LGB+" {
            attribute = "1"
        }
        else if type.lowercased() == "straight/heterosexual" {
            attribute = "2"
        }
        return attribute
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
    
    func getViolationsRipaParam(violationId:String){
        AppUtility.showProgress(nil, title: "")
        let id = AppManager.getLastSavedLoginDetails()?.id
        let param:[String : Any] = ["violationIds": violationId, "access_token": AppManager.getLastSavedLoginDetails()?.result?.access_token ?? ""]
        let params:[String : Any] =  ["id": id!, "method":"getViolationInfoByViolationId", "params":param ,"jsonrpc": "2.0"]
        print(params)
        getViolationsList(params: params)
    }
  
    func getViolationsList(params: [String:Any]){
        var URL:String?
        
        URL = AppConstants.Api.otpRequest
        
        ApiManager.getRipaViolation(params: params, methodTyPe: .post, url: URL!, completion: { json,successmsg   in
            AppUtility.hideProgress(nil)
            if successmsg == "Success"{
                if let json = try? JSON(data: json as! Data) {
                    print(json)
                    let errorMsg = json["result"][0]["serviceError"].stringValue
                    if  errorMsg == ""{
                             let object = json.dictionaryValue
                             let dictionary = object["result"]
                             AppConstants.violation_type = dictionary?["violation_type"].stringValue ?? ""
                             AppConstants.travel_method = dictionary?["travel_method"].stringValue ?? ""
                             AppConstants.offenceCodes = dictionary?["offense_codes"].stringValue ?? ""
                             self.delegate?.proceedToAddViolationReasonStopTypeOfStop()
                     }
                    else{
                       
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
 
             let optionId = option.option_id
             if optionId.count == 0 {
                 option.option_id = "0"
             }
            
            if option.cascade_ripa_id != ""{
                var cascadeRipaId = option.cascade_ripa_id

                let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(cascadeRipaId)!)
                
                        cascadeQuestion.order_number = orderId!
                         cascadeQuestionType = cascadeQuestion.questionTypeCode
                       
                  // option.questionoptions = cascadeQuestion.questionoptions
                     if questionArray![questNumber!].question_code == "21" && option.cascade_ripa_id == "50" && viewType != "StartNewRipa" {
                         let optt = Questionoptions1(mainQuestId: option.cascade_ripa_id, mainQuestOrder: cascadeQuestion.order_number , option_id: "", ripa_id: option.cascade_ripa_id, custid: cascadeQuestion.custid, option_value: "", cascade_ripa_id: "40",isK_12School: "", isHideQuesText: "No", order_number: cascadeQuestion.order_number, createdBy: "", createdOn: "", updatedBy: "", updatedOn: "" , isSelected:true, isAddtion : "",isDescription_Required : "",inputTypeCode : "V ",questionTypeCode : "LV",tag:"", physical_attribute:"", default_value: "", optionDescription: "", question_code_for_cascading_id: cascadeQuestion.question_code, isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id:questionArray![questNumber!].question_code, isExpanded: false, isNewAdded: true, mainId: "", questionoptions: cascadeQuestion.questionoptions)
                         let checkk = option.questionoptions?.contains(where: {$0.cascade_ripa_id == "40"})
                         if checkk == false {
                             option.questionoptions?.append(optt)
                         }
                     }
                else {
                    option.questionoptions = cascadeQuestion.questionoptions
                }
                         option.isExpanded = false
                        if option.isSelected == true{
                            option.isExpanded = true
                        }
                
               
                
                for opt in cascadeQuestion.questionoptions!{
                    opt.order_number = orderId!
                    let opId = opt.option_id
                    if opId.count == 0 {
                        opt.option_id = "0"
                    }
                    opt.mainQuestOrder = orderId!
                    opt.main_question_id = questionId
                }
            }
        }
    }
    
    

    
}


extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
