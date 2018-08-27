//
//  GetPublicTicker.swift
//  Kraken_iOS_API
//
//  Created by José Fonseca on 26/08/2018.
//  Copyright © 2018 Ze. All rights reserved.
//

import Foundation

class GetPublicTicker {
    // MARK: - Structs
    
    //apiTickerStruct
    struct apiTickerResponseStruct: Codable {
        let error: [String]
        let result: [String: TickerResponseStruct]?
        
        struct TickerResponseStruct: Codable {
            let ask: [String]
            let bid: [String]
            let lastTrade: [String]
            let volume: [String]
            let volumeWeightedAverage: [String]
            let numberOfTrades: [Int]
            let low: [String]
            let high: [String]
            let opening: String
            /*
             ask = ask array(<price>, <whole lot volume>, <lot volume>),
             bid = bid array(<price>, <whole lot volume>, <lot volume>),
             lastTrade = last trade closed array(<price>, <lot volume>),
             volume = volume array(<today>, <last 24 hours>),
             volumeWeightedAverage = volume weighted average price array(<today>, <last 24 hours>),
             numberOfTrades = number of trades array(<today>, <last 24 hours>),
             low = low array(<today>, <last 24 hours>),
             high = high array(<today>, <last 24 hours>),
             opening = today's opening price
             */
            
            enum CodingKeys: String, CodingKey {
                case ask = "a"
                case bid = "b"
                case lastTrade = "c"
                case volume = "v"
                case volumeWeightedAverage = "p"
                case numberOfTrades = "t"
                case low = "l"
                case high = "h"
                case opening = "o"
                /*
                 a = ask array(<price>, <whole lot volume>, <lot volume>),
                 b = bid array(<price>, <whole lot volume>, <lot volume>),
                 c = last trade closed array(<price>, <lot volume>),
                 v = volume array(<today>, <last 24 hours>),
                 p = volume weighted average price array(<today>, <last 24 hours>),
                 t = number of trades array(<today>, <last 24 hours>),
                 l = low array(<today>, <last 24 hours>),
                 h = high array(<today>, <last 24 hours>),
                 o = today's opening price
                 */
            }
        }
    }
    
    // MARK: - Kraken API response handler
    
    //Handler of the response of the Kraken API when there was no network error
    func loadTickerResponse(APIReturnData: String, APIStatus: Int)-> String? {

        if APIStatus == 200 { //HTTP status: OK
            
            let decoder = JSONDecoder()
            let resultJSONDecoded = try! decoder.decode(GetPublicTicker.apiTickerResponseStruct.self, from: APIReturnData.data(using: .utf8)!)
            
            let error = resultJSONDecoded.error
            if error.count == 0 {
                if let result = resultJSONDecoded.result {
                    let keys = Array(result.keys)
                    let values = Array(result.values)
                    let value = values[0]
                    return value.lastTrade[0]
                }
            } else {
                CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.Ticker, error: error[0])
            }
        } else { //HTTP status: different than OK
            let statusMessage = "HTTP Status Code \(APIStatus)"
            CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.Ticker, error: statusMessage)
        }
        return nil
    }
}
