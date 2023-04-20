//
//  DefaultCityModel.swift
//  ticketPRO RIPA
//
//  Created by mac on 14/04/23.
//

import Foundation
import ObjectMapper


class DefaultCityModel : Mappable {
    
    var city_id : String?
    var custid : String?
    var city_name: String?
    var county_id : String?
    var order_number : String?
    
    var court_I : String?
    var court_M: String?
    var court_F : String?
    var court_J : String?
    
    init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        city_id <- map["city_id"]
        custid <- map["custid"]
        city_name <- map["city_name"]
        county_id <- map["county_id"]
        order_number <- map["order_number"]
        court_I <- map["court_I"]
        court_M <- map["court_M"]
        court_F <- map["court_F"]
        court_J <- map["court_J"]
    }
}


// MARK: - Formatted data

extension DefaultCityModel {
    
    static func formattedData(data: [String: Any]) -> DefaultCityModel? {
        return Mapper<DefaultCityModel>().map(JSON:data)
    }
    
    static func formattedArray(data: [[String: Any]]) -> [DefaultCityModel]? {
        return Mapper<DefaultCityModel>().mapArray(JSONArray: data)
    }
}

