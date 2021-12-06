//
//  StatusCount.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 12/07/21.
//

import Foundation


struct StatusCount {
    let result: [CountResult]
    let id, jsonrpc: String
}


struct CountResult {
    var total : String
    var statusID : String
    var statusCode : String
    var ripaActivityStatusName : String
}
