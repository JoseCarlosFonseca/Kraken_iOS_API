//
//  GetPublicTime.swift
//  Kraken_iOS_API
//
//  Created by José Fonseca on 26/08/2018.
//  Copyright © 2018 Ze. All rights reserved.
//

import Foundation

class GetPublicTime {
    // MARK: - Structs
    
    //apiTimeStruct
    struct apiTimeResponseStruct: Codable {
        let error: [String]
        let result: TimeResponseStruct?
        
        struct TimeResponseStruct: Codable {
            let unixtime: Int
            let rfc1123: String
        }
    }
    
    // MARK: - Kraken API response handler
    
    //Handler of the response of the Kraken API when there was no network error
    func loadTimeResponse(APIReturnData: String, APIStatus: Int) -> (Int?, String?) {
        
        if APIStatus == 200 { //HTTP status: OK
            
            let decoder = JSONDecoder()
            let resultJSONDecoded = try! decoder.decode(apiTimeResponseStruct.self, from: APIReturnData.data(using: .utf8)!)
            
            let error = resultJSONDecoded.error
            if error.count == 0 {
                return (resultJSONDecoded.result?.unixtime, resultJSONDecoded.result?.rfc1123)
            } else {
                CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.Time, error: error[0])
            }
        } else { //HTTP status: different than OK
            let statusMessage = "HTTP Status Code \(APIStatus)"
            CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.Time, error: statusMessage)
        }
        return (nil, nil)
    }
}
