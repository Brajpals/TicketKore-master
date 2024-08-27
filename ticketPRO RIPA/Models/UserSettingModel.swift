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
    var ethncity_option : [Ethncity]?
    var gender_option : [GenderOption]?
    var is_active: String?
    var genderQuestion: genderQuestion?
    var contracted : Contracted?
    var other : Other?
    var ethncity_question : Ethncity_question?
    var gender_question : Gender_question?
    
    init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        question <- map["question"]
        option <- map["option"]
        default_supervisor <- map["default_supervisor"]
        supervisor <- map["supervisor"]
        is_active <- map["is_active"]
        ethncity_option <- map["ethncity_option"]
        gender_option <- map["gender_option"]
        contracted <- map["Contracted"]
        genderQuestion <- map["gender_question"]
    }
}

class genderQuestion : Mappable {

    var isCascade_Question : String?
    var is_active : String?
    var id : String?
    var internall : String?
    var isDescription_Required : String?
    var inputTypeId : String?
    var editable_question : String?
    var question_code : String?
    var questionTypeId : String?
    var UpdatedBy : String?
    var question : String?
    var UpdatedOn : String?
    var ripa_group_id : String?
    var question_key : String?
    var visible_question : String?
    var question_info : String?
    var CreatedOn : String?
    var isAddtion : String?
    var is_required : String?
    var CreatedBy : String?
    var custid : String?
    var order_number : String?
    var is_add_value : String?
    var common_question : String?
   
    init() {}
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        isCascade_Question <- map["isCascade_Question"]
        is_active <- map["is_active"]
        id <- map["id"]
        internall <- map["internal"]
        isDescription_Required <- map["isDescription_Required"]
        inputTypeId <- map["inputTypeId"]
        editable_question <- map["editable_question"]
        question_code <- map["question_code"]
        questionTypeId <- map["questionTypeId"]
        UpdatedBy <- map["UpdatedBy"]
        question <- map["question"]
        UpdatedOn <- map["UpdatedOn"]
        ripa_group_id <- map["ripa_group_id"]
        question_key <- map["question_key"]
        visible_question <- map["visible_question"]
        question_info <- map["question_info"]
        CreatedOn <- map["CreatedOn"]
        isAddtion <- map["isAddtion"]
        is_required <- map["is_required"]
        CreatedBy <- map["CreatedBy"]
        custid <- map["custid"]
        order_number <- map["order_number"]
        is_add_value <- map["is_add_value"]
        common_question <- map["common_question"]
        
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
    var isSelected : Bool = false
   
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

class Ethncity : Mappable {

    var order_number : String?
    var custid : String?
    var default_value : String?
    var CreatedBy : String?
    var tag : String?
    var physical_attribute : String?
    var isK_12School : String?
    var option_code : String?
    var cascade_ripa_id : String?
    var CreatedOn : String?
    var option_id : String?
    var UpdatedBy : String?
    var UpdatedOn : String?
    
    var option_value : String?
    var isHideQuesText : String?
    var ripa_id : String?
    var isSelected: Bool = false
   
    init() {}
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        order_number <- map["order_number"]
        custid <- map["custid"]
        default_value <- map["default_value"]
        CreatedBy <- map["CreatedBy"]
        tag <- map["tag"]
        physical_attribute <- map["physical_attribute"]
        isK_12School <- map["isK_12School"]
        option_code <- map["option_code"]
        cascade_ripa_id <- map["cascade_ripa_id"]
        CreatedOn <- map["CreatedOn"]
        option_id <- map["option_id"]
        UpdatedBy <- map["UpdatedBy"]
        UpdatedOn <- map["UpdatedOn"]
        
        option_value <- map["option_value"]
        isHideQuesText <- map["isHideQuesText"]
        ripa_id <- map["ripa_id"]
     }
}


class GenderOption : Mappable {

    var order_number : String?
    var custid : String?
    var default_value : String?
    var CreatedBy : String?
    var tag : String?
    var physical_attribute : String?
    var isK_12School : String?
    var option_code : String?
    var cascade_ripa_id : String?
    var CreatedOn : String?
    var option_id : String?
    var UpdatedBy : String?
    var UpdatedOn : String?
    
    var option_value : String?
    var isHideQuesText : String?
    var ripa_id : String?
    var isSelected: Bool = false
   
    init() {}
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        order_number <- map["order_number"]
        custid <- map["custid"]
        default_value <- map["default_value"]
        CreatedBy <- map["CreatedBy"]
        tag <- map["tag"]
        physical_attribute <- map["physical_attribute"]
        isK_12School <- map["isK_12School"]
        option_code <- map["option_code"]
        cascade_ripa_id <- map["cascade_ripa_id"]
        CreatedOn <- map["CreatedOn"]
        option_id <- map["option_id"]
        UpdatedBy <- map["UpdatedBy"]
        UpdatedOn <- map["UpdatedOn"]
        
        option_value <- map["option_value"]
        isHideQuesText <- map["isHideQuesText"]
        ripa_id <- map["ripa_id"]
     }
}


class Contracted : Mappable {

    var order_number : String?
    var question_code : String?
    var is_add_value : String?
    var custid : String?
    var is_required : String?
    var id : String?
    var question_key : String?
    var question_info : String?
    var CreatedBy : String?
    var UpdatedBy : String?
    var UpdatedOn : String?
    var inputTypeId : String?
    var isCascade_Question : String?
    var option_code : String?
    var cascade_ripa_id : String?
    var CreatedOn : String?
    var ripa_group_id : String?
    var isDescription_Required : String?
    
    var internall : String?
    var common_question : String?
    var question : String?
    var editable_question : String?
   
    init() {}
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        order_number <- map["order_number"]
        question_code <- map["question_code"]
        is_add_value <- map["is_add_value"]
        custid <- map["custid"]
        is_required <- map["is_required"]
        id <- map["id"]
        question_key <- map["question_key"]
        question_info <- map["question_info"]
        
        CreatedBy <- map["CreatedBy"]
        isDescription_Required <- map["isDescription_Required"]
        inputTypeId <- map["inputTypeId"]
        isCascade_Question <- map["isCascade_Question"]
        option_code <- map["option_code"]
        cascade_ripa_id <- map["cascade_ripa_id"]
        CreatedOn <- map["CreatedOn"]
        ripa_group_id <- map["ripa_group_id"]
        UpdatedBy <- map["UpdatedBy"]
        UpdatedOn <- map["UpdatedOn"]
        
        internall <- map["internal"]
        common_question <- map["common_question"]
        question <- map["question"]
        editable_question <- map["editable_question"]
     }
}

class Other : Mappable {

    var order_number : String?
    var question_code : String?
    var is_add_value : String?
    var custid : String?
    var is_required : String?
    var id : String?
    var question_key : String?
    var question_info : String?
    var CreatedBy : String?
    var UpdatedBy : String?
    var UpdatedOn : String?
    var inputTypeId : String?
    var isCascade_Question : String?
    var option_code : String?
    var cascade_ripa_id : String?
    var CreatedOn : String?
    var ripa_group_id : String?
    var isDescription_Required : String?
    
    var internall : String?
    var common_question : String?
    var question : String?
    var editable_question : String?
   
    init() {}
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        order_number <- map["order_number"]
        question_code <- map["question_code"]
        is_add_value <- map["is_add_value"]
        custid <- map["custid"]
        is_required <- map["is_required"]
        id <- map["id"]
        question_key <- map["question_key"]
        question_info <- map["question_info"]
        
        CreatedBy <- map["CreatedBy"]
        isDescription_Required <- map["isDescription_Required"]
        inputTypeId <- map["inputTypeId"]
        isCascade_Question <- map["isCascade_Question"]
        option_code <- map["option_code"]
        cascade_ripa_id <- map["cascade_ripa_id"]
        CreatedOn <- map["CreatedOn"]
        ripa_group_id <- map["ripa_group_id"]
        UpdatedBy <- map["UpdatedBy"]
        UpdatedOn <- map["UpdatedOn"]
        
        internall <- map["internal"]
        common_question <- map["common_question"]
        question <- map["question"]
        editable_question <- map["editable_question"]
     }
}

class Ethncity_question : Mappable {

    var order_number : String?
    var question_code : String?
    var is_add_value : String?
    var custid : String?
    var is_required : String?
    var id : String?
    var question_key : String?
    var question_info : String?
    var CreatedBy : String?
    var UpdatedBy : String?
    var UpdatedOn : String?
    var inputTypeId : String?
    var isCascade_Question : String?
    var option_code : String?
    var cascade_ripa_id : String?
    var CreatedOn : String?
    var ripa_group_id : String?
    var isDescription_Required : String?
    
    var internall : String?
    var common_question : String?
    var question : String?
    var editable_question : String?
   
    init() {}
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        order_number <- map["order_number"]
        question_code <- map["question_code"]
        is_add_value <- map["is_add_value"]
        custid <- map["custid"]
        is_required <- map["is_required"]
        id <- map["id"]
        question_key <- map["question_key"]
        question_info <- map["question_info"]
        
        CreatedBy <- map["CreatedBy"]
        isDescription_Required <- map["isDescription_Required"]
        inputTypeId <- map["inputTypeId"]
        isCascade_Question <- map["isCascade_Question"]
        option_code <- map["option_code"]
        cascade_ripa_id <- map["cascade_ripa_id"]
        CreatedOn <- map["CreatedOn"]
        ripa_group_id <- map["ripa_group_id"]
        UpdatedBy <- map["UpdatedBy"]
        UpdatedOn <- map["UpdatedOn"]
        
        internall <- map["internal"]
        common_question <- map["common_question"]
        question <- map["question"]
        editable_question <- map["editable_question"]
     }
}

class Gender_question : Mappable {

    var order_number : String?
    var question_code : String?
    var is_add_value : String?
    var custid : String?
    var is_required : String?
    var id : String?
    var question_key : String?
    var question_info : String?
    var CreatedBy : String?
    var UpdatedBy : String?
    var UpdatedOn : String?
    var inputTypeId : String?
    var isCascade_Question : String?
    var option_code : String?
    var cascade_ripa_id : String?
    var CreatedOn : String?
    var ripa_group_id : String?
    var isDescription_Required : String?
    
    var internall : String?
    var common_question : String?
    var question : String?
    var editable_question : String?
   
    init() {}
    
    required init?(map: Map) {}

    func mapping(map: Map) {
        order_number <- map["order_number"]
        question_code <- map["question_code"]
        is_add_value <- map["is_add_value"]
        custid <- map["custid"]
        is_required <- map["is_required"]
        id <- map["id"]
        question_key <- map["question_key"]
        question_info <- map["question_info"]
        
        CreatedBy <- map["CreatedBy"]
        isDescription_Required <- map["isDescription_Required"]
        inputTypeId <- map["inputTypeId"]
        isCascade_Question <- map["isCascade_Question"]
        option_code <- map["option_code"]
        cascade_ripa_id <- map["cascade_ripa_id"]
        CreatedOn <- map["CreatedOn"]
        ripa_group_id <- map["ripa_group_id"]
        UpdatedBy <- map["UpdatedBy"]
        UpdatedOn <- map["UpdatedOn"]
        
        internall <- map["internal"]
        common_question <- map["common_question"]
        question <- map["question"]
        editable_question <- map["editable_question"]
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

