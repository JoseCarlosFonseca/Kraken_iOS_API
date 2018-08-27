//
//  GetPrivateTradesHistory.swift
//  Kraken_iOS_API
//
//  Created by José Fonseca on 27/08/2018.
//  Copyright © 2018 Ze. All rights reserved.
//

import Foundation

class GetPrivateTradesHistory {
    // MARK: - Structs
    
    //apiTradesHistoryStruct
    struct apiTradesHistoryStruct: Codable {
        let error: [String]
        let result: TradeInfoArrayStruct?
        
        struct TradeInfoArrayStruct: Codable {
            let trades: [String: TradeInfoStruct]
            let count: Int
            
            struct TradeInfoStruct: Codable {
                let ordertxid: String
                let pair: String
                let time: Double
                let type: String
                let ordertype: String
                let price: String
                let cost: String
                let fee: String
                let vol: String
                let margin: String
                let misc: String
                let closing: String?
                
                let posstatus: String?
                let cprice: String?
                let ccost: String?
                let cfee: String?
                let cvol: String?
                let cmargin: String?
                let net: String?
                let trades: String?
            }
        }
        /*
         trades = array of trade info with txid as the key
         ordertxid = order responsible for execution of trade
         pair = asset pair
         time = unix timestamp of trade
         type = type of order (buy/sell)
         ordertype = order type
         price = average price order was executed at (quote currency)
         cost = total cost of order (quote currency)
         fee = total fee (quote currency)
         vol = volume (base currency)
         margin = initial margin (quote currency)
         misc = comma delimited list of miscellaneous info
         closing = trade closes all or part of a position
         count = amount of available trades info matching criteria
         If the trade opened a position, the follow fields are also present in the trade info:
         
         posstatus = position status (open/closed)
         cprice = average price of closed portion of position (quote currency)
         ccost = total cost of closed portion of position (quote currency)
         cfee = total fee of closed portion of position (quote currency)
         cvol = total fee of closed portion of position (quote currency)
         cmargin = total margin freed in closed portion of position (quote currency)
         net = net profit/loss of closed portion of position (quote currency, quote currency scale)
         trades = list of closing trades for position (if available)
         Note:
         
         Unless otherwise stated, costs, fees, prices, and volumes are in the asset pair's scale, not the currency's scale.
         Times given by trade tx ids are more accurate than unix timestamps.
         */
    }
    
    // MARK: - Kraken API response handler
    
    //Handler of the response of the Kraken API when there was no network error
    func loadTradesHistoryResponse(APIReturnData: String, APIStatus: Int)-> String? {
        
        if APIStatus == 200 { //HTTP status: OK
            
            let decoder = JSONDecoder()
            
            let resultJSONDecoded = try! decoder.decode(apiTradesHistoryStruct.self, from: APIReturnData.data(using: .utf8)!)
            let error = resultJSONDecoded.error
            if error.count == 0 {
                if let result = resultJSONDecoded.result?.trades {
                    let keys = Array(result.keys)
                    let values = Array(result.values)
                    var lastResult = "No Trades History"
                    for value in values {
                        lastResult = "\(keys[0]) \(value.pair) \(value.price)"
                    }
                    return lastResult
                }
            } else {
                CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.TradesHistory, error: error[0])
            }
        } else { //HTTP status: different than OK
            let statusMessage = "HTTP Status Code \(APIStatus)"
            CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.TradesHistory, error: statusMessage)
        }
        return nil
    }
}
