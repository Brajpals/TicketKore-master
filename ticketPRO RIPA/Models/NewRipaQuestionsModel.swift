//
//  NewRipaModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 17/02/21.
//

import Foundation
import ObjectMapper



class NewRipaQuestionsModel: Mappable {
    
    var result : [QuestionResult]?
    var id:String?
    var jsonrpc: String?
    
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map)
    {
        result <- map["result"]
        id  <- map["id"]
        jsonrpc  <- map["jsonrpc"]
    }
}

class QuestionResult : Mappable {
    var id : String=""
    var question : String=""
    var question_info : String=""
    var options : String=""
    var is_active : String=""
    var custid : String=""
    var order_number : String=""
    var is_add_value : String=""
    var question_key : String=""
    var question_code : String=""
    
    var `internal` : String=""
    var questionTypeId : String=""
    var is_required : String=""
    var isAddtion : String=""
    var isCascade_Question : String=""
    var ripa_group_id : String=""
    var isDescription_Required : String=""
    var inputTypeId : String=""
    var createdBy : String=""
    var createdOn : String=""
    var updatedBy : String=""
    var updatedOn : String=""
    var inputTypeCode : String=""
    var questionTypeCode : String=""
    var groupName : String=""
    var serviceError : String=""
    var errorStatusCode : Int = 2
    var token : String=""
    var common_question : String=""
    var editable_question : String=""
    var visible_question : String=""
    
    var questionoptions:[Questionoptions]?
    
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        question <- map["question"]
        question_info <- map["question_info"]
        options <- map["options"]
        is_active <- map["is_active"]
        custid <- map["custid"]
        order_number <- map["order_number"]
        is_add_value <- map["is_add_value"]
        `internal` <- map["internal"]
        questionTypeId <- map["questionTypeId"]
        is_required <- map["is_required"]
        isAddtion <- map["isAddtion"]
        question_key <- map["question_key"]
        question_code <- map["question_code"]
        isCascade_Question <- map["isCascade_Question"]
        ripa_group_id <- map["ripa_group_id"]
        isDescription_Required <- map["isDescription_Required"]
        inputTypeId <- map["inputTypeId"]
        createdBy <- map["CreatedBy"]
        createdOn <- map["CreatedOn"]
        updatedBy <- map["UpdatedBy"]
        updatedOn <- map["UpdatedOn"]
        inputTypeCode <- map["inputTypeCode"]
        questionTypeCode <- map["questionTypeCode"]
        groupName <- map["groupName"]
        questionoptions <- map["questionoptions"]
        serviceError <- map["serviceError"]
        errorStatusCode <- map["status"]
        token <- map["token"]
        common_question <- map["common_question"]
        editable_question <- map["editable_question"]
        visible_question <- map["visible_question"]
    }
    
    
    
}




class Questionoptions : Mappable {
    var mainQuestId:String = ""
    var mainQuestOrder:String = ""
    
    var option_id : String=""
    var ripa_id : String=""
    var custid : String=""
    var option_value : String=""
    var cascade_ripa_id : String=""
    var isK_12School : String=""
    var isHideQuesText : String=""
    var order_number : String=""
    var createdBy : String=""
    var createdOn : String=""
    var updatedBy : String=""
    var updatedOn : String=""
    var isAddtion : String=""
    var isDescription_Required : String=""
    var inputTypeCode : String=""
    var questionTypeCode : String=""
    var tag : String=""
    var physical_attribute : String=""
    var default_value : String=""
    var description : String = ""
    var question_code_for_cascading_id : String = ""
    var isQuestionMandatory : String = ""
    var isQuestionDescriptionReq : String = ""
    var main_question_id : String = ""
    
    var isSelected : String = "false"
    
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        option_id <- map["option_id"]
        ripa_id <- map["ripa_id"]
        custid <- map["custid"]
        option_value <- map["option_value"]
        cascade_ripa_id <- map["cascade_ripa_id"]
        isK_12School <- map["isK_12School"]
        order_number <- map["order_number"]
        createdBy <- map["CreatedBy"]
        createdOn <- map["CreatedOn"]
        updatedBy <- map["UpdatedBy"]
        updatedOn <- map["UpdatedOn"]
        isAddtion <- map["isAddtion"]
        isDescription_Required <- map["isDescription_Required"]
        inputTypeCode <- map["inputTypeCode"]
        questionTypeCode <- map["questionTypeCode"]
        tag <- map["tag"]
        physical_attribute <- map["physical_attribute"]
        default_value <- map["default_value"]
        question_code_for_cascading_id <- map["question_code_for_cascading_id"]
     }
    
}




class QuestionResult1  {
    var id, custid, question: String
    var question_key: String
    var question_info: String
    
    var question_code, questionTypeId, inputTypeId, is_add_value: String
    var `internal` , is_required, isAddtion, isCascade_Question: String
    var ripa_group_id: String
    var isDescription_Required, common_question, editable_question, visible_question: String
    var order_number, is_active, CreatedBy, CreatedOn: String
    let UpdatedBy, UpdatedOn, inputTypeCode: String
    let questionTypeCode: String
    let groupName: String
    
    var questionoptions:[Questionoptions1]?
    
    
    init(id: String, custid: String, question: String, question_info: String,question_key: String, question_code: String, questionTypeId: String, inputTypeId: String, is_add_value: String, `internal`: String, is_required: String, isAddtion: String, isCascade_Question: String, ripa_group_id: String, isDescription_Required: String, common_question: String, editable_question: String, visible_question: String, order_number: String, is_active: String, CreatedBy: String, CreatedOn: String, UpdatedBy: String, UpdatedOn: String, inputTypeCode: String, questionTypeCode: String, groupName: String, questionoptions:[Questionoptions1]?) {
        
        self.id = id
        self.custid = custid
        self.question = question
        self.question_info=question_info
        self.question_key = question_key
        self.question_code = question_code
        self.questionTypeId = questionTypeId
        self.inputTypeId = inputTypeId
        self.is_add_value = is_add_value
        self.`internal` = `internal`
        self.is_required = is_required
        self.isAddtion = isAddtion
        self.isCascade_Question = isCascade_Question
        self.ripa_group_id = ripa_group_id
        self.isDescription_Required = isDescription_Required
        self.common_question = common_question
        self.editable_question = editable_question
        self.visible_question = visible_question
        self.order_number = order_number
        self.is_active = is_active
        self.CreatedBy = CreatedBy
        self.CreatedOn = CreatedOn
        self.UpdatedBy = UpdatedBy
        self.UpdatedOn = UpdatedOn
        self.inputTypeCode = inputTypeCode
        self.questionTypeCode = questionTypeCode
        self.groupName = groupName
        
        self.questionoptions = questionoptions
        
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = QuestionResult1(id: id, custid: custid, question: question, question_info: question_info, question_key: question_key, question_code: question_code, questionTypeId: questionTypeId, inputTypeId: inputTypeId, is_add_value: is_add_value, internal: `internal`, is_required: is_required, isAddtion: isAddtion, isCascade_Question: isCascade_Question, ripa_group_id: ripa_group_id, isDescription_Required: isDescription_Required, common_question: common_question, editable_question: editable_question, visible_question: visible_question, order_number: order_number, is_active: is_active, CreatedBy: CreatedBy, CreatedOn: CreatedOn, UpdatedBy: UpdatedBy, UpdatedOn: UpdatedOn, inputTypeCode: inputTypeCode, questionTypeCode: questionTypeCode, groupName: groupName, questionoptions: questionoptions)
        return copy
    }
    
}




class Questionoptions1 : NSObject, NSCopying  {
    
    
    var mainQuestId:String
    var mainQuestOrder:String
    
    var option_id : String
    var ripa_id : String
    var custid : String
    var option_value : String
    var cascade_ripa_id : String
    var isK_12School : String
    var isHideQuesText : String
    var order_number : String
    var createdBy : String
    var createdOn : String
    var updatedBy : String
    var updatedOn : String
    var isSelected : Bool
    var isExpanded : Bool
    var isAddtion : String
    var isDescription_Required : String
    var inputTypeCode : String
    var questionTypeCode : String
    var tag : String
    var physical_attribute : String
    var default_value : String
    var optionDescription : String
    var question_code_for_cascading_id : String = ""
    
    var isQuestionMandatory : String
    var isQuestionDescriptionReq : String
    var main_question_id : String = ""
    
    var questionoptions:[Questionoptions1]?
    
    
    init(mainQuestId:String , mainQuestOrder:String, option_id:String, ripa_id : String,custid : String, option_value : String,cascade_ripa_id : String,isK_12School : String,isHideQuesText : String,order_number : String, createdBy : String,createdOn : String,updatedBy : String,updatedOn : String,isSelected : Bool,isAddtion : String,isDescription_Required : String,inputTypeCode : String,questionTypeCode : String ,tag : String,physical_attribute : String, default_value: String, optionDescription : String, question_code_for_cascading_id:String, isQuestionMandatory : String , isQuestionDescriptionReq:String,  main_question_id : String,
         isExpanded : Bool, questionoptions :[Questionoptions1]?) {
        
        self.mainQuestId =  mainQuestId
        self.mainQuestOrder =  mainQuestOrder
        self.option_id = option_id
        self.ripa_id =  ripa_id
        self.custid =  custid
        self.option_value = option_value
        self.cascade_ripa_id =  cascade_ripa_id
        self.isK_12School =  isK_12School
        self.isHideQuesText =  isHideQuesText
        self.order_number =  order_number
        self.createdBy =  createdBy
        self.createdOn =  createdOn
        self.updatedBy =  updatedBy
        self.updatedOn = updatedOn
        self.isSelected =  isSelected
        self.isExpanded =  isExpanded
        self.isAddtion =  isAddtion
        self.isDescription_Required =  isDescription_Required
        self.inputTypeCode =  inputTypeCode
        self.questionTypeCode =  questionTypeCode
        self.tag =  tag
        self.default_value =  default_value
        self.physical_attribute =  physical_attribute
        self.questionoptions =  questionoptions
        self.optionDescription =  optionDescription
        self.question_code_for_cascading_id =  question_code_for_cascading_id
        self.isQuestionMandatory = isQuestionMandatory
        self.isQuestionDescriptionReq = isQuestionDescriptionReq
        self.main_question_id = main_question_id
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Questionoptions1(mainQuestId: mainQuestId, mainQuestOrder: mainQuestOrder, option_id: option_id, ripa_id: ripa_id, custid: custid, option_value: option_value, cascade_ripa_id: cascade_ripa_id, isK_12School: isK_12School, isHideQuesText: isHideQuesText, order_number: order_number, createdBy: createdBy, createdOn: createdOn, updatedBy: updatedBy, updatedOn: updatedOn, isSelected: isSelected, isAddtion: isAddtion, isDescription_Required: isDescription_Required, inputTypeCode: inputTypeCode, questionTypeCode: questionTypeCode, tag: tag, physical_attribute: physical_attribute, default_value: default_value, optionDescription: optionDescription, question_code_for_cascading_id: question_code_for_cascading_id, isQuestionMandatory: isQuestionMandatory, isQuestionDescriptionReq: isQuestionDescriptionReq, main_question_id: main_question_id, isExpanded: isExpanded, questionoptions: questionoptions)
        return copy
    }
}



