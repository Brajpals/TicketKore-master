//
//  LocationModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 06/10/21.
//

import Foundation


// MARK: - LocationModel
class LocationModel {
    let address: Address

    init(address: Address) {
        self.address = address
    }
}

// MARK: - Address
class Address {
    let matchAddr, longLabel, shortLabel, addrType: String
    let type, placeName, addNum, address: String
    let block, sector, neighborhood, district: String
    var city, metroArea, subregion, region: String
    let territory, postal, postalEXT, countryCode: String

    init(matchAddr: String, longLabel: String, shortLabel: String, addrType: String, type: String, placeName: String, addNum: String, address: String, block: String, sector: String, neighborhood: String, district: String, city: String, metroArea: String, subregion: String, region: String, territory: String, postal: String, postalEXT: String, countryCode: String) {
        self.matchAddr = matchAddr
        self.longLabel = longLabel
        self.shortLabel = shortLabel
        self.addrType = addrType
        self.type = type
        self.placeName = placeName
        self.addNum = addNum
        self.address = address
        self.block = block
        self.sector = sector
        self.neighborhood = neighborhood
        self.district = district
        self.city = city
        self.metroArea = metroArea
        self.subregion = subregion
        self.region = region
        self.territory = territory
        self.postal = postal
        self.postalEXT = postalEXT
        self.countryCode = countryCode
    }
}
