//
//  UserSettingModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 29/11/21.
//

import Foundation
import ObjectMapper

class UserSettingModel : Mappable {
    
    var question : Question?
    var option : [Option]?
    var default_supervisor: String?
    var supervisor : [Supervisor]?
    var is_active: String?
    init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        question <- map["question"]
        option <- map["option"]
        default_supervisor <- map["default_supervisor"]
        supervisor <- map["supervisor"]
        is_active <- map["is_active"]
    }
}

class Question: Mappable {

    var inputTypeId : String?
    var CreatedBy : String?
    var CreatedOn : String?
    var order_number : String?
    var questionTypeId : String?
    var internall : String?
    var id : String?
    var is_active : String?
    var isDescription_Required : String?
    var isAddtion : String?
    var UpdatedBy : String?
    var question_info : String?
    var question : String?
    var question_key : String?
    var isCascade_Question : String?
    var question_code : String?
    var ripa_group_id : String?
    var editable_question : String?
    var UpdatedOn : String?
    var visible_question : String?
    var common_question : String?
    var custid : String?
    var is_required : String?
    var is_add_value : String?
    var response : String?
   
    required init?(map: Map) {}

    func mapping(map: Map) {
        inputTypeId <- map["inputTypeId"]
        CreatedBy <- map["CreatedBy"]
        CreatedOn <- map["CreatedOn"]
        order_number <- map["order_number"]
        questionTypeId <- map["questionTypeId"]
        internall <- map["internal"]
        id <- map["id"]
        isAddtion <- map["isAddtion"]
        isDescription_Required <- map["isDescription_Required"]
        is_active <- map["is_active"]
        UpdatedBy <- map["UpdatedBy"]
        question_info <- map["question_info"]
        question <- map["question"]
        question_key <- map["question_key"]
        isCascade_Question <- map["isCascade_Question"]
        question_code <- map["question_code"]
        ripa_group_id <- map["ripa_group_id"]
        editable_question <- map["editable_question"]
        UpdatedOn <- map["UpdatedOn"]
        visible_question <- map["visible_question"]
        is_add_value <- map["is_add_value"]
        common_question <- map["common_question"]
        custid <- map["custid"]
        is_required <- map["is_required"]
     }
}

class Option: Mappable {

    var CreatedBy : String?
    var option_id : String?
    var UpdatedOn : String?
    var CreatedOn : String?
    var physical_attribute : String?
    var default_value : String?
    var tag : String?
    var ripa_id : String?
    var order_number : String?
    var UpdatedBy : String?
    var cascade_ripa_id : String?
    var isHideQuesText : String?
    var option_value : String?
    var option_code : String?
    var custid : String?
    var isK_12School : String?
    var subOption : String?
    var is_select : Bool = false
   
    required init?(map: Map) {}

    func mapping(map: Map) {
        CreatedBy <- map["CreatedBy"]
        option_id <- map["option_id"]
        UpdatedOn <- map["UpdatedOn"]
        CreatedOn <- map["CreatedOn"]
        physical_attribute <- map["physical_attribute"]
        default_value <- map["default_value"]
        tag <- map["tag"]
        ripa_id <- map["ripa_id"]
        order_number <- map["order_number"]
        UpdatedBy <- map["UpdatedBy"]
        cascade_ripa_id <- map["cascade_ripa_id"]
        isHideQuesText <- map["isHideQuesText"]
        option_value <- map["option_value"]
        option_code <- map["option_code"]
        custid <- map["custid"]
        isK_12School <- map["isK_12School"]
     }
}

class Supervisor : Mappable {

    var Initials : String?
    var SupervisorId : String?
    var LastName : String?
    var FirstName : String?
    var CustId : String?
    var AgencyId : String?
    var Title : String?
    var CreatedBy : String?
    var CreatedOn : String?
    var UpdatedBy : String?
    var PersonId : String?
    var Active : String?
    var UpdatedOn : String?
   
    init() {}
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        Initials <- map["Initials"]
        SupervisorId <- map["SupervisorId"]
        LastName <- map["LastName"]
        FirstName <- map["FirstName"]
        CustId <- map["CustId"]
        AgencyId <- map["AgencyId"]
        Title <- map["Title"]
        CreatedBy <- map["CreatedBy"]
        CreatedOn <- map["CreatedOn"]
        UpdatedBy <- map["UpdatedBy"]
        PersonId <- map["PersonId"]
        Active <- map["Active"]
        UpdatedOn <- map["UpdatedOn"]
     }
}

 
// MARK: - Formatted data

extension UserSettingModel {
    
    static func formattedData(data: [String: Any]) -> UserSettingModel? {
        return Mapper<UserSettingModel>().map(JSON:data)
    }
    
    static func formattedArray(data: [[String: Any]]) -> [UserSettingModel]? {
        return Mapper<UserSettingModel>().mapArray(JSONArray: data)
    }
}

