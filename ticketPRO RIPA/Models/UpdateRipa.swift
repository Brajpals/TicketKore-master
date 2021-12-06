//
//  UpdateRipa.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 08/04/21.
//

import Foundation
 

import Foundation



// MARK: - Welcome
struct UpdateRipa:Encodable {
    let id, method: String
    let params: UpdateParam
    let jsonrpc: String

    init(id: String, method: String, params: UpdateParam, jsonrpc: String) {
        self.id = id
        self.method = method
        self.params = params
        self.jsonrpc = jsonrpc
    }
    
 
}

// MARK: - Params
struct UpdateParam:Encodable {
    let ripaactivity: [Ripaactivity]

    init(ripaactivity: [Ripaactivity]) {
        self.ripaactivity = ripaactivity
    }
}

// MARK: - Ripaactivity
struct Ripaactivity:Encodable {
    var key: String
    var custid: String
    var City : String
    var date_time: String
    var userid: String
    var username: String
    var Notes: String
    var latitude: String
    var longitude: String
    var start_date, end_date: String
    var deviceid: Int
    var Location: String
    var officer_experience: String
    var timetaken: String
    var citation_number: String
    var is_K_12_Student, CreatedBy, ip_address: String
    var stop_date: String
    var stop_time: String
    var stop_duration: String
    var app_version: String
    var platform: String
    var traffic_id: String
    var activity_status_id: String
    var access_token: String
    var county_id: String
    var time_duration_enable: String
    
    var call_number : String
    var onscene_time : String
    var clear_time_of_the_Offrcer : String
    var overall_call_clear_time : String
    var call_type : String
    var unitId : String
    var zone : String
    var supervisorId : String
    
 
    var ripaPersons: [RipaPerson]
    
 
    init(key: String, custid: String, City : String, date_time: String, userid: String, username: String, Notes: String, latitude: String, longitude: String, start_date: String, end_date: String, deviceid: Int, Location: String, officer_experience:String, is_K_12_Student: String, CreatedBy: String, ip_address: String , stop_date: String , stop_time: String , stop_duration: String, app_version: String, platform: String, traffic_id: String, activity_status_id: String, access_token: String, timetaken : String, citation_number: String ,county_id: String,time_duration_enable: String, call_number : String, onscene_time : String, clear_time_of_the_Offrcer : String, overall_call_clear_time : String, call_type : String, unitId : String, zone : String, ripaPersons: [RipaPerson], supervisorId : String) {
        self.key = key
        self.custid = custid
        self.date_time = date_time
        self.userid = userid
        self.username = username
        self.Notes = Notes
        self.latitude = latitude
        self.longitude = longitude
        self.start_date = start_date
        self.end_date = end_date
        self.deviceid = deviceid
        self.Location = Location
        self.officer_experience = officer_experience
        self.is_K_12_Student = is_K_12_Student
        self.CreatedBy = CreatedBy
        self.ip_address = ip_address
        
        self.stop_date = stop_date
        self.stop_time = stop_time
        self.stop_duration = stop_duration
        self.ripaPersons = ripaPersons
        self.app_version = app_version
        self.traffic_id = traffic_id
        self.City = City
        self.platform = platform
        self.activity_status_id = activity_status_id
        self.timetaken = timetaken
        self.access_token = access_token
        self.citation_number = citation_number
        self.county_id = county_id
        self.time_duration_enable = time_duration_enable
        
        self.call_number = call_number
        self.onscene_time = onscene_time
        self.clear_time_of_the_Offrcer = clear_time_of_the_Offrcer
        self.overall_call_clear_time = overall_call_clear_time
        self.call_type = call_type
        self.unitId = unitId
        self.zone = zone
        self.supervisorId = supervisorId
       
     }
}



// MARK: - RipaPerson
struct RipaPerson:Encodable {
    let CreatedBy: String
    let person_name: String
    let date : String
    let time : String
    let duration : String
    var key: String

    
    var ripa_response: [RipaResponse]

    init(CreatedBy: String, person_name: String, key: String, date : String, time : String, duration : String, ripa_response: [RipaResponse]) {
        self.CreatedBy = CreatedBy
        self.person_name = person_name
        self.key = key
        self.date = date
        self.time = time
        self.duration = duration
        self.ripa_response = ripa_response
     }
}


// MARK: - RipaResponse
struct RipaResponse:Encodable {
    let CreatedBy: String
    let internall: String
   // let option_id: String
    let physical_attribute: String
    var question: String
    var question_code: String
    var question_id: String
    var response: String?
    var description: String
    let userid: String
    let key: String
    let personId: String
    var cascade_ques_id: String
    var order_number: String
    var option_id: String
    var cascade_option_id: String
    var main_question_id: String
    var supervisorId: String
 

    init(question_id: String, response: String?, `internal`: String, userid: String, question: String, CreatedBy: String, physical_attribute: String , key: String, personId: String, description: String, question_code: String, cascade_ques_id: String ,order_number: String, option_id:String, cascade_option_id: String, main_question_id: String, supervisorId: String) {
        self.question_id = question_id
        self.response = response
        self.internall = `internal`
        self.userid = userid
        self.question = question
        self.CreatedBy = CreatedBy
        self.physical_attribute = physical_attribute
        self.key = key
        self.personId = personId
        self.description = description
       
        self.question_code = question_code
        self.cascade_ques_id = cascade_ques_id
        self.order_number = order_number
        self.option_id = option_id
        self.cascade_option_id = cascade_option_id
        self.main_question_id = main_question_id
        self.main_question_id = main_question_id
        self.supervisorId = supervisorId
    }
}
