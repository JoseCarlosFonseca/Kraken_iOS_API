//
//  GetPrivateOpenOrders.swift
//  Kraken_iOS_API
//
//  Created by José Fonseca on 27/08/2018.
//  Copyright © 2018 Ze. All rights reserved.
//

import Foundation

class GetPrivateOpenOrders {
    // MARK: - Structs
    
    //apiOpenOrdersStruct
    struct apiOpenOrdersResponseStruct: Codable {
        let error: [String]
        let result: OpenOrdersResponseStruct?
        
        struct OpenOrdersResponseStruct: Codable {
            let open: [String: OpenOrdersResponseSubStruct]
            
            struct OpenOrdersResponseSubStruct: Codable {
                let refid: Int?
                let userref: Int?
                let status: String
                let opentm: Double
                let starttm: Int
                let expiretm: Int
                let descr: OpenOrdersResponseSubSubStruct
                let vol: String
                let vol_exec: String
                let cost: String
                let fee: String
                let price: String
                let misc: String
                let oflags: String
                
                struct OpenOrdersResponseSubSubStruct: Codable {
                    let pair: String
                    let type: String
                    let ordertype: String
                    let price: String
                    let price2: String
                    let leverage: String
                    let order: String
                }
            }
        }
        /*
         refid = Referral order transaction id that created this order
         userref = user reference id
         status = status of order:
         pending = order pending book entry
         open = open order
         closed = closed order
         canceled = order canceled
         expired = order expired
         opentm = unix timestamp of when order was placed
         starttm = unix timestamp of order start time (or 0 if not set)
         expiretm = unix timestamp of order end time (or 0 if not set)
         descr = order description info
         pair = asset pair
         type = type of order (buy/sell)
         ordertype = order type (See Add standard order)
         price = primary price
         price2 = secondary price
         leverage = amount of leverage
         order = order description
         close = conditional close order description (if conditional close set)
         vol = volume of order (base currency unless viqc set in oflags)
         vol_exec = volume executed (base currency unless viqc set in oflags)
         cost = total cost (quote currency unless unless viqc set in oflags)
         fee = total fee (quote currency)
         price = average price (quote currency unless viqc set in oflags)
         stopprice = stop price (quote currency, for trailing stops)
         limitprice = triggered limit price (quote currency, when limit based order type triggered)
         misc = comma delimited list of miscellaneous info
         stopped = triggered by stop price
         touched = triggered by touch price
         liquidated = liquidation
         partial = partial fill
         oflags = comma delimited list of order flags
         viqc = volume in quote currency
         fcib = prefer fee in base currency (default if selling)
         fciq = prefer fee in quote currency (default if buying)
         nompp = no market price protection
         trades = array of trade ids related to order (if trades info requested and data available)
         */
    }
    
    // MARK: - Kraken API response handler
    
    //Handler of the response of the Kraken API when there was no network error
    func loadOpenOrdersResponse(APIReturnData: String, APIStatus: Int)-> String? {
        
        if APIStatus == 200 { //HTTP status: OK
            
            let decoder = JSONDecoder()
            
            let resultJSONDecoded = try! decoder.decode(apiOpenOrdersResponseStruct.self, from: APIReturnData.data(using: .utf8)!)
            let error = resultJSONDecoded.error
            if error.count == 0 {                
                if let result = resultJSONDecoded.result?.open {
                    let keys = Array(result.keys)
                    let values = Array(result.values)
                    var lastResult = "No Open Orders"
                    for value in values {
                        lastResult = "\(keys[0]) \(value.cost) \(value.price)"
                    }
                    return lastResult
                }
            } else {
                CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.OpenOrders, error: error[0])
            }
        } else { //HTTP status: different than OK
            let statusMessage = "HTTP Status Code \(APIStatus)"
            CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.OpenOrders, error: statusMessage)
        }
        return nil
    }
}
