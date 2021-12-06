//
//  EducationCode.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 16/04/21.
//

import Foundation
 

// MARK: - Welcome
class Welcome {
    let result: EducationResult
    let id, jsonrpc: String

    init(result: EducationResult, id: String, jsonrpc: String) {
        self.result = result
        self.id = id
        self.jsonrpc = jsonrpc
    }
}

// MARK: - Result
class EducationResult {
    let educationCodeSection: [EducationCodeSection]
    let educationCodeSubsection: [EducationCodeSubsection]

    init(educationCodeSection: [EducationCodeSection], educationCodeSubsection: [EducationCodeSubsection]) {
        self.educationCodeSection = educationCodeSection
        self.educationCodeSubsection = educationCodeSubsection
    }
}

// MARK: - EducationCodeSection
class EducationCodeSection {
    let educationCodeSectionID, educationCode, educationCodeDesc, physicalAttribute: String
    let orderNumber, isActive, createdBy, createdOn: String
    let updatedBy, updatedOn: String
    var isSelected : Bool

    init(educationCodeSectionID: String, educationCode: String, educationCodeDesc: String, physicalAttribute: String, orderNumber: String, isActive: String, createdBy: String, createdOn: String, updatedBy: String, updatedOn:String ,isSelected:Bool ) {
        self.educationCodeSectionID = educationCodeSectionID
        self.educationCode = educationCode
        self.educationCodeDesc = educationCodeDesc
        self.physicalAttribute = physicalAttribute
        self.orderNumber = orderNumber
        self.isActive = isActive
        self.createdBy = createdBy
        self.createdOn = createdOn
        self.updatedBy = updatedBy
        self.updatedOn = updatedOn
        self.isSelected = isSelected
    }
}

// MARK: - EducationCodeSubsection
class EducationCodeSubsection {
    let educationCodeSubsectionID, educationCodeSectionID, educationCodeSubsection, educationCodeSubsectionDesc: String
    let physicalAttribute, orderNumber, isActive, createdBy: String
    let createdOn: String
    let updatedBy, updatedOn: String
    var isSelected : Bool

    init(educationCodeSubsectionID: String, educationCodeSectionID: String, educationCodeSubsection: String, educationCodeSubsectionDesc: String, physicalAttribute: String, orderNumber: String, isActive: String, createdBy: String, createdOn: String, updatedBy: String, updatedOn: String,isSelected:Bool) {
        self.educationCodeSubsectionID = educationCodeSubsectionID
        self.educationCodeSectionID = educationCodeSectionID
        self.educationCodeSubsection = educationCodeSubsection
        self.educationCodeSubsectionDesc = educationCodeSubsectionDesc
        self.physicalAttribute = physicalAttribute
        self.orderNumber = orderNumber
        self.isActive = isActive
        self.createdBy = createdBy
        self.createdOn = createdOn
        self.updatedBy = updatedBy
        self.updatedOn = updatedOn
        self.isSelected = isSelected
    }
}
