import Foundation
import ObjectMapper

 

struct ripaActivity{
     var ripa_activity: Int
     var custid: Int
     var date_time: Date
     var username:  String = ""
     var Notes:  String = ""
     var latitude: Float
     var longitude: Float
     var start_date: Date
     var end_date: Date
     var ripa_response :[ripaResponse]
    
}
 
struct ripaResponse{
    private(set)   var activity_id: Int
    private(set)   var question_id: Int
    private(set)   var response: String = ""
    private(set)   var `internal`:  String = ""
    private(set)   var question:  String = ""
}

struct ripaResponseGetData{
    private(set)   var id:  String = ""
    private(set)   var method: String = ""
    private(set)   var params:getRipatPrams
    private(set)   var jsonrpc:  String = ""
    
    struct getRipatPrams{
        private(set)   var custId: String
        private(set)   var fullSync: String
     }
    
    
}
 



 

class LoginDetailsOTP: Mappable {
    
    var result: Result?
    var id:String?
    var jsonrpc: String?
    
    required init?(map: Map){}
    
    func mapping(map: Map)
    {
        result <- map["result"]
        id  <- map["id"]
        jsonrpc  <- map["jsonrpc"]
    }
}

class Result: Mappable {
    
 
    var   serviceError: String = ""
    var   ripa_enrollment_id: String = ""
    var   ripa_enrollment_activity_id: String = ""
    var   enrollment_id: String = ""
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
    var   rmsid: String = ""
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
    var   access_token: String = ""
 
    var   name: String = ""
    var   address: String = ""
    var   contact_number: String = ""
    var   logo_image: String = ""
    var   agency_code: String = ""
    var   web_address: String = ""
    var   content_folder: String = ""
    var   agencyid: String = ""
    var   ticket_color: String = ""
    var   ticket_back: String = ""
    var   TRCourtCode: String = ""
    var   TRPrintAgencyName: String = ""
    var   city_address: String = ""
    var   ORI: String = ""
    var   agency_group: String = ""
    var   is_security_check: String = ""
    var   county_id: String = ""
    var   start_year: String = ""
 
  
    
 
    required init?(map: Map){}
    
      func mapping(map: Map)
    {
        serviceError <- map["serviceError"]
        ripa_enrollment_id <- map["ripa_enrollment_id"]
        ripa_enrollment_activity_id <- map["ripa_enrollment_activity_id"]
        enrollment_id <- map ["enrollment_id"]
        custid <- map ["custid"]
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
        rmsid <- map["rmsid"]
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
        
        name <- map["name"]
        address <- map["address"]
        contact_number <- map["contact_number"]
        logo_image <- map["logo_image"]
        agency_code <- map["agency_code"]
        web_address <- map["web_address"]
        content_folder <- map["content_folder"]
        agencyid <- map["agencyid"]
        ticket_color <- map["ticket_color"]
        ticket_back <- map["ticket_back"]
        TRCourtCode <- map["TRCourtCode"]
        TRPrintAgencyName <- map["TRPrintAgencyName"]
        city_address <- map["city_address"]
        ORI <- map["ORI"]
        agency_group <- map["agency_group"]
        is_security_check <- map["is_security_check"]
        county_id <- map["county_id"]
        start_year <- map["start_year"]
 
        access_token <- map["access_token"]
 
   
 
    }
}
