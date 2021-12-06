//
//  otherRipaData.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 15/02/21.
//

import Foundation
import ObjectMapper


 class Violations {
      var result = [ViolationsResult]()
      var id:String = ""
      var jsonrpc: String = ""
 
 }

 
 class ViolationsResult{
     var violationID: String = ""
     var custid: String = ""
     var violation: String = ""
     var code: String = ""
     var orderNumber: String = ""
     var violationDisplay: String = ""
     var isActive: String = ""
     var violationType: String = ""
     var violationGroup: String = ""
     var offense_code: String = ""
     var isSelected : Bool
    
 
    init(violationID:String,custid : String,violation : String,code:String,orderNumber : String,violationDisplay : String,isActive:String,violationType : String, violationGroup : String,  offense_code : String, isSelected : Bool) {
        self.violationID = violationID
        self.custid = custid
        self.violation = violation
        self.code = code
        self.orderNumber = orderNumber
        self.violationDisplay = violationDisplay
        self.isActive = isActive
        self.violationType = violationType
        self.violationGroup = violationGroup
        self.offense_code = offense_code
        self.isSelected = isSelected
  }
    
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ViolationsResult(violationID: violationID, custid: custid, violation: violation, code: code, orderNumber: orderNumber, violationDisplay: violationDisplay, isActive: isActive, violationType: violationType, violationGroup: violationGroup, offense_code: offense_code, isSelected: isSelected)
         return copy
     }
}


 


/// FOR CITIES


class Cities{
     var result = [CityResult]()
     var id:String = ""
     var jsonrpc: String = ""
 }

class CityResult:Encodable {
    var city_id: String = ""
    var custid: String = ""
    var city_name: String = ""
    var county_id: String = ""
    var order_number: String = ""
    var isSelected : Bool
    
    init(city_id:String,custid : String,city_name : String,county_id:String,order_number : String,isSelected : Bool) {
        self.city_id = city_id
        self.custid = custid
        self.city_name = city_name
        self.county_id = county_id
        self.order_number = order_number
        self.isSelected = isSelected
    }
  }

 

 

// MARK: - Result
class CountyResult {
    var countyID: String = ""
    var countyName : String = ""
    var courtHolidays: String = ""
    var webAddress: String = ""
    var isSelected : Bool
    
    init(countyID:String, countyName : String, courtHolidays : String, webAddress:String ,isSelected : Bool) {
        self.countyID = countyID
        self.countyName = countyName
        self.courtHolidays = courtHolidays
        self.webAddress = webAddress
        self.isSelected = isSelected
    }
  }


class FeaturesResult {
    var featureID : String = ""
    var custid: String = ""
    var feature: String = ""
    var admin: String = ""
    var officer: String = ""
    var value: String = ""
    var isActive: String = ""
    var orderNumber: String = ""
    var moduleName: String = ""
    var module: String = ""

    init(featureID: String, custid: String, feature: String, admin: String, officer: String, value: String, isActive: String, orderNumber: String, moduleName: String, module: String) {
        self.featureID = featureID
        self.custid = custid
        self.feature = feature
        self.admin = admin
        self.officer = officer
        self.value = value
        self.isActive = isActive
        self.orderNumber = orderNumber
        self.moduleName = moduleName
        self.module = module
    }
}





// FOR LOCATIONS
class Location:Encodable{
     var result = [LocationResult]()
     var id:String = ""
     var jsonrpc: String = ""
    
 }

 class LocationResult:Encodable{
    var location_id: String = ""
    var custid: String = ""
    var location: String = ""
    var zone_id: String = ""
    var order_number: String = ""
    var is_active: String = ""
    var county_id: String = ""
    var city_id: String = ""
    var isSelected : Bool
    
 
    init(location_id:String,custid : String,location : String,zone_id:String,order_number : String,is_active : String,county_id:String,city_id : String, isSelected : Bool) {
        self.location_id = location_id
        self.custid = custid
        self.location = location
        self.zone_id = zone_id
        self.order_number = order_number
        self.is_active = is_active
        self.county_id = county_id
        self.city_id = city_id
        self.isSelected = isSelected
    }
    
 }



// FOR SCHOOL

class School{
     var result = [SchoolResult]()
     var id:String = ""
     var jsonrpc: String = ""
  
}

  
 class SchoolResult{
    let schoolsID: String
    let custid: String
    let cdsCode, ncesDist, ncesSchool, statusType: String
    let countyid, county, district, school: String
    let street, streetABR, cityid, city: String
    let zip, state, phone, ext: String
    let faxNumber, email: String
    let webSite: String
    let doc, docType, soc, socType: String
    let edOpsCode, edOpsName, eilCode, eilName: String
    let gSoffered, gSserved, latitude, longitude: String
    let isK12School, isActive, orderNumber, createdBy: String
    let createdOn: String
    let updatedBy, updatedOn: String
    var isSelected : Bool

    init(schoolsID: String, custid: String, cdsCode: String, ncesDist: String, ncesSchool: String, statusType: String, countyid: String, county: String, district: String, school: String, street: String, streetABR: String, cityid: String, city: String, zip: String, state: String, phone: String, ext: String, faxNumber: String, email: String, webSite: String, doc: String, docType: String, soc: String, socType: String, edOpsCode: String, edOpsName: String, eilCode: String, eilName: String, gSoffered: String, gSserved: String, latitude: String, longitude: String, isK12School: String, isActive: String, orderNumber: String, createdBy: String, createdOn: String, updatedBy: String, updatedOn: String,isSelected:Bool) {
        self.schoolsID = schoolsID
        self.custid = custid
        self.cdsCode = cdsCode
        self.ncesDist = ncesDist
        self.ncesSchool = ncesSchool
        self.statusType = statusType
        self.countyid = countyid
        self.county = county
        self.district = district
        self.school = school
        self.street = street
        self.streetABR = streetABR
        self.cityid = cityid
        self.city = city
        self.zip = zip
        self.state = state
        self.phone = phone
        self.ext = ext
        self.faxNumber = faxNumber
        self.email = email
        self.webSite = webSite
        self.doc = doc
        self.docType = docType
        self.soc = soc
        self.socType = socType
        self.edOpsCode = edOpsCode
        self.edOpsName = edOpsName
        self.eilCode = eilCode
        self.eilName = eilName
        self.gSoffered = gSoffered
        self.gSserved = gSserved
        self.latitude = latitude
        self.longitude = longitude
        self.isK12School = isK12School
        self.isActive = isActive
        self.orderNumber = orderNumber
        self.createdBy = createdBy
        self.createdOn = createdOn
        self.updatedBy = updatedBy
        self.updatedOn = updatedOn
        self.isSelected = isSelected
    }
 
 }

 





class ActivityStore: Mappable {
     var result : ActivityData? = ActivityData()
     var id:String = ""
     var jsonrpc: String = ""
   
    // required init?(map: Map){}
   
   required convenience init?(map: Map) {
       self.init()
     }
   
    func mapping(map: Map)
   {
       result <- map["result"]
       id  <- map["id"]
       jsonrpc  <- map["jsonrpc"]
   }
}

// MARK: - Result
class ActivityData: Mappable {
     var   ripa_enrollment_id: String = ""
     var   enrollmentID: String = ""
     var   custid: String = ""
     var   productid: String = ""
     var   licenseCount: String = ""
     var   created_date: String = ""
     var   expire_date: String = ""
     var   is_active: String = ""
     var   order_number: String = ""
     var   CreatedBy: String = ""
     var   CreatedOn: String = ""
     var   UpdatedBy: String = ""
     var   UpdatedOn: String = ""
     var   userid: String = ""
     var   username: String = ""
     var   password: String = ""
     var   user_type: String = ""
     var   first_name: String = ""
     var   last_name: String = ""
     var   badge: String = ""
     var   department: String = ""
     var   email_address: String = ""
     var   modules: String = ""
     var   title: String = ""
     var   print_name: String = ""
     var   phone: String = ""
     var   phone1: String = ""
     var   message: String = ""
     var   serviceError: String = ""
     var   invalidToken: String = ""
     var   token: String = ""
    
    
 
   //required init?(map: Map){}
   required convenience init?(map: Map) {
         self.init()
     }
   
     func mapping(map: Map)
   {
             ripa_enrollment_id <- map["ripa_enrollment_id"]
             enrollmentID <- map["enrollmentID"]
             custid <- map["custid"]
             productid <- map["productid"]
             licenseCount <- map["licenseCount"]
             created_date <- map["created_date"]
             expire_date <- map["expire_date"]
             is_active <- map["is_active"]
             order_number <- map["order_number"]
             CreatedBy <- map["CreatedBy"]
             CreatedOn <- map["CreatedOn"]
             UpdatedBy <- map["UpdatedBy"]
             UpdatedOn <- map["UpdatedOn"]
             userid <- map["userid"]
             username <- map["username"]
             password <- map["password"]
             user_type <- map["user_type"]
             first_name <- map["first_name"]
             last_name <- map["last_name"]
             badge <- map["badge"]
             department <- map["department"]
             email_address <- map["email_address"]
             modules <- map["modules"]
             title <- map["title"]
             print_name <- map["print_name"]
             phone <- map["phone"]
             phone1 <- map["phone1"]
             message <- map["message"]
             serviceError <- map["serviceError"]
             invalidToken <- map["invalidToken"]
             token <- map["token"]
       }
   
    
   
}
