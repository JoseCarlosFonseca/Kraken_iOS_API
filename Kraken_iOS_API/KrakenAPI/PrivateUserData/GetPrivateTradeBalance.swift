//
//  GetPrivateTradeBalance.swift
//  Kraken_iOS_API
//
//  Created by José Fonseca on 26/08/2018.
//  Copyright © 2018 Ze. All rights reserved.
//

import Foundation

class GetPrivateTradeBalance {
    // MARK: - Structs
    
    //apiTradeBalanceStruct
    struct apiTradeBalanceResponseStruct: Codable {
        let error: [String]
        let result: TradeBalanceResponseStruct?
        
        struct TradeBalanceResponseStruct: Codable {
            let eb: String
            let tb: String
            let m: String
            let n: String
            let c: String
            let v: String
            let e: String
            let mf: String
            let ml: String?
            /*
             eb = equivalent balance (combined balance of all currencies)
             tb = trade balance (combined balance of all equity currencies)
             m = margin amount of open positions
             n = unrealized net profit/loss of open positions
             c = cost basis of open positions
             v = current floating valuation of open positions
             e = equity = trade balance + unrealized net profit/loss
             mf = free margin = equity - initial margin (maximum margin available to open new positions)
             ml = margin level = (equity / initial margin) * 100
             */
        }
    }
    
    // MARK: - Kraken API response handler
    
    //Handler of the response of the Kraken API when there was no network error
    func loadTradeBalanceResponse(APIReturnData: String, APIStatus: Int)-> String? {
        
        if APIStatus == 200 { //HTTP status: OK
            
            let decoder = JSONDecoder()
            
            let resultJSONDecoded = try! decoder.decode(apiTradeBalanceResponseStruct.self, from: APIReturnData.data(using: .utf8)!)
            let error = resultJSONDecoded.error
            if error.count == 0 {
                if let result = resultJSONDecoded.result {
                    return result.eb
                }
            } else {
                CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.TradeBalance, error: error[0])
            }
        } else { //HTTP status: different than OK
            let statusMessage = "HTTP Status Code \(APIStatus)"
            CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.TradeBalance, error: statusMessage)
        }
        return nil
    }
}
