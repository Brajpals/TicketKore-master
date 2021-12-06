//
//  VersionUpdate.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 6/18/21.
//

import Foundation
import ObjectMapper

class versionUpdate: Mappable {
    
    var result: Result1?
    var id:String?
    var jsonrpc: String?
    
 
    required init?(map: Map){}
    
    func mapping(map: Map)
    {
        result <- map["result"]
        id  <- map["id"]
        jsonrpc  <- map["jsonrpc"]
    }

    class Result1: Mappable {
        
        var   android_version: String = ""
        var   ios_verion: String? = ""
        var   web_version: String = ""
        var   created_on: String = ""
        var   updated_on: String? = ""
        required init?(map: Map){}
    
        
        func mapping(map: Map) {
            android_version <- map["android_version"]
            ios_verion <- map["ios_verion"]
            web_version <- map["web_version"]
            created_on <- map ["created_on"]
            updated_on <- map["updated_on"]
           
        }
        
    }
}
