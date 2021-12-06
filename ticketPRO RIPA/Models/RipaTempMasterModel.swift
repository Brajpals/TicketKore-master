//
//  RipaTempMaster.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 26/05/21.
//

import Foundation

 

// MARK: - Welcome
class RipaTempMasterModel {
    let result: [Result]
    let id, jsonrpc: String

    init(result: [Result], id: String, jsonrpc: String) {
        self.result = result
        self.id = id
        self.jsonrpc = jsonrpc
    }
}

// MARK: - Result
class RipaTempMaster {
    var key: String
    var skeletonID, activityId, custid, userid, username: String
    let rmsid, phoneNumber : String
    let street: String
    let block: String
    let intersectionStreet: String
    let note: String
    let activity_notes: String
    let location: String
    let city: String
    let CreatedBy: String
    let ticketDate, declarationDate, violation, violationCode: String
    let violationType : String
    let violationID, offenceCode, email, createdOn: String
    let updatedBy, updatedOn: String
    var citationNumber, status: String
    var mainStatus: String
    let statusChnageDate: String
    let ripaTempId:String
    let tempType:String
    let stopDate:String
    let stopTime:String
    let stopDuration:String
    let rejectedURL:String
    var syncStatus:String
    var startDate  :String
    var endDate :String
    var is_K_12_Student :String
    var lat :String
    var long : String
    var timeTaken : String
    var countyId : String
    var deviceid : String
    
    
    // New For Dispatch
    var callNumber : String
    var callTime : String
    var onsceneTime : String
    var clearTimeOfOfficer : String
    var overallCallClearTime : String
    var callType : String
    var unitId : String
    var zone : String
    

    init(key: String, skeletonID: String,activityId:String, custid: String, userid: String, username: String, rmsid: String, phoneNumber: String, location: String , city: String, street: String, block: String, intersectionStreet: String, note: String, activity_notes: String, CreatedBy: String, ticketDate: String, declarationDate: String, violation: String, violationCode: String, violationType: String , violationID: String, offenceCode: String, email: String, createdOn: String, updatedBy: String, updatedOn: String, citationNumber: String, status: String, mainStatus: String, statusChnageDate: String, ripaTempId:String, tempType:String ,stopDate:String , stopTime:String, stopDuration:String, rejectedURL:String , syncStatus:String, startDate:String ,endDate:String , is_K_12_Student:String, lat:String, long:String,timeTaken : String, countyId : String , deviceid : String, callNumber : String, callTime : String, onsceneTime : String, clearTimeOfOfficer : String, overallCallClearTime : String, callType : String, unitId : String, zone : String) {
        
        self.key = key
        self.skeletonID = skeletonID
        self.custid = custid
        self.userid = userid
        self.username = username
        self.rmsid = rmsid
        self.phoneNumber = phoneNumber
        self.location = location
        self.city = city
        self.street = street
        self.block = block
        self.intersectionStreet = intersectionStreet
        self.note = note
        self.activity_notes = activity_notes
        self.CreatedBy = CreatedBy
        self.ticketDate = ticketDate
        self.declarationDate = declarationDate
        self.violation = violation
        self.violationCode = violationCode
        self.violationType = violationType
        self.violationID = violationID
        self.offenceCode = offenceCode
        self.email = email
        self.createdOn = createdOn
        self.updatedBy = updatedBy
        self.updatedOn = updatedOn
        self.citationNumber = citationNumber
        self.status = status
        self.mainStatus = mainStatus
        self.statusChnageDate = statusChnageDate
        self.ripaTempId = ripaTempId
        self.tempType = tempType
        self.stopDate = stopDate
        self.rejectedURL = rejectedURL
        self.syncStatus = syncStatus
        self.activityId = activityId
        self.stopTime = stopTime
        self.stopDuration = stopDuration
        self.startDate = startDate
        self.endDate = endDate
        self.is_K_12_Student = is_K_12_Student
        self.lat = lat
        self.long = long
        self.timeTaken = timeTaken
        self.countyId = countyId
        self.deviceid = deviceid

        self.callNumber = callNumber
        self.callTime = callTime
        self.onsceneTime = onsceneTime
        self.clearTimeOfOfficer = clearTimeOfOfficer
        self.overallCallClearTime = overallCallClearTime
        self.callType = callType
        self.unitId = unitId
        self.zone = zone
     }
}

