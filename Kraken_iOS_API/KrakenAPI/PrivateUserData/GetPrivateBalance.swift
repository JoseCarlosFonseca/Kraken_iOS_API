//
//  GetPrivateBalance.swift
//  Kraken_iOS_API
//
//  Created by José Fonseca on 26/08/2018.
//  Copyright © 2018 Ze. All rights reserved.
//

import Foundation

class GetPrivateBalance {
    // MARK: - Structs
    
    //apiBalanceStruct
    struct apiBalanceResponseStruct: Codable {
        let error: [String]
        let result: [String: String]?
    }
    
    // MARK: - Kraken API response handler
    
    //Handler of the response of the Kraken API when there was no network error
    func loadBalanceResponse(APIReturnData: String, APIStatus: Int)-> String? {
        
        if APIStatus == 200 { //HTTP status: OK
            
            let decoder = JSONDecoder()
            
            let resultJSONDecoded = try! decoder.decode(apiBalanceResponseStruct.self, from: APIReturnData.data(using: .utf8)!)
            let error = resultJSONDecoded.error
            if error.count == 0 {
                if let result = resultJSONDecoded.result {
                    var lastResult = ""
                    for (key, value) in result {
                        lastResult = "\(key) \(value)"
                    }
                    return lastResult
                }
            } else {
                CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.Balance, error: error[0])
            }
        } else { //HTTP status: different than OK
            let statusMessage = "HTTP Status Code \(APIStatus)"
            CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.Balance, error: statusMessage)
        }
        return nil
    }
}
