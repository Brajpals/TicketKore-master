// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
// let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct RejectedApplicationModel {
    let result: RejectedApplication
    let id, jsonrpc: String
}

// MARK: - Result
struct RejectedApplication {
    var ativity: Ativity
    var response: [Response]
    var location: RejectedApplicationLocation
    //var logindata: Logindata
}

// MARK: - Ativity
struct Ativity {
    let activityID, activityNotes: String
    let officerExperience: String
    var city: String
    var location: String
    let activityCreationDate, username, stopDate, stopTime: String
    let stopDuration, activityCheckedBy: String
    var timetaken : String
}

// MARK: - Location
struct RejectedApplicationLocation {
    var block, street, intersection: String
}


// MARK: - Logindata
struct Logindata {
    let ripaEnrollmentActivityID, ripaEnrollmentID, custid, userid: String
    let userName: String
    let userEmail: String
    let rmsid, badge, phoneNumber, phoneNumber1: String
    let countyID: String
    let createdDate, expireDate, appVersion, platform: String
    let isActive, uid, orderNumber, createdBy: String
    let createdOn: String
    let updatedBy, updatedOn: String
    let cityName, enrollmentID, activityUid, accessToken: String
}



// MARK: - Response
struct Response {
    let recID, activityID, ripaPersonID, userid: String
    let questionID, question, questionCode: String
    let cascadeQuesID, optionID: String
    var response: String
    let physicalAttribute: String
    let responseInternal, responseDescription, devicesUniqueNo, orderNumber: String
    let createdBy, createdOn: String
    let updatedBy, updatedOn: String
    let personName: String
}


 
 



 
 
 





// MARK: - Welcome
class UpdateRejectedApplication : Encodable {
    var id, jsonrpc, method: String
    var params: UpdateParams

    init(id: String, jsonrpc: String, method: String, params: UpdateParams) {
        self.id = id
        self.jsonrpc = jsonrpc
        self.method = method
        self.params = params
    }
}

// MARK: - Params
class UpdateParams : Encodable{
    var ripa_location: [UpdateRipaLocation]

    init(ripa_location: [UpdateRipaLocation]) {
        self.ripa_location = ripa_location
    }
}

 

// MARK: - RipaLocation
class UpdateRipaLocation : Encodable{
    var Street, Block, Intersection, Location , City, timetaken, access_token, ip_address, platform, app_version, time_duration_enable, deviceid : String
    var ripa_response: [UpdateRipaResponse]

    init(Street: String, Block: String, Intersection: String, Location: String, City: String ,timetaken: String , access_token: String, ip_address: String, platform: String, app_version: String, time_duration_enable: String,deviceid : String, ripa_response: [UpdateRipaResponse]) {
        self.Street = Street
        self.Block = Block
        self.Intersection = Intersection
        self.Location = Location
        self.City = City
        self.ripa_response = ripa_response
        self.timetaken = timetaken
        self.access_token = access_token
        self.ip_address = ip_address
        self.platform = platform
        self.app_version = app_version
        self.deviceid = deviceid
        self.time_duration_enable = time_duration_enable
    }
}
 

// MARK: - RipaResponse
class UpdateRipaResponse : Encodable{
    var activity_id, question_id, rec_id, ripa_person_id: String
    var response, description: String
    var userid: String
    var optionID: String?

    init(activity_id: String, question_id: String, rec_id: String, ripa_person_id: String, response: String, description: String, userid: String, optionID: String?) {
        self.activity_id = activity_id
        self.question_id = question_id
        self.rec_id = rec_id
        self.ripa_person_id = ripa_person_id
        self.response = response
        self.description = description
        self.userid = userid
        self.optionID = optionID
        self.userid = userid
    }
}

 



//TO UPDATE CHANGES


