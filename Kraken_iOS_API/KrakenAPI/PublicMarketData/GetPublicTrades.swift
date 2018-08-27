//
//  GetPublicTrades.swift
//  Kraken_iOS_API
//
//  Created by José Fonseca on 26/08/2018.
//  Copyright © 2018 Ze. All rights reserved.
//

import Foundation

class GetPublicTrades {
    // MARK: - Structs
    
    ///apiTradesStruct
    struct apiTradesResponseStruct: Codable {
        let error: [String]
        let result: [String: Any]?
        //The Codable Protocol does not allow tuples nor Any, so we need to implement a custom decoder (and enconder if we want to encode the struct later on)
        
        /*
         <pair_name> = pair name
         array of array entries(<price>, <volume>, <time>, <buy/sell>, <market/limit>, <miscellaneous>)
         last = id to be used as since when polling for new trade data
         */
        
        enum CodingKeys: String, CodingKey {
            case XXBTZEUR, BCHEUR, XETHZEUR, error, result, last
            
            static let array = [XXBTZEUR, BCHEUR, XETHZEUR] // to allow iteration
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.error = try container.decode([String].self, forKey: .error)
            
            var pair: String = ""
            var values: [[Any]] = []
            let last: String
            
            if let resultContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .result) {
                for pairElement in CodingKeys.array { // Search for all pairs
                    if var subContainer = try? resultContainer.nestedUnkeyedContainer(forKey: pairElement) {
                        var arrayArrayAny: [[Any]] = []
                        while subContainer.isAtEnd == false {
                            var subSubContainer = try subContainer.nestedUnkeyedContainer()
                            var arrayAny: [Any] = []
                            while subSubContainer.isAtEnd == false {
                                if let value = try? subSubContainer.decode(Double.self) {
                                    arrayAny.append(value)
                                } else if let value = try? subSubContainer.decode(String.self) {
                                    arrayAny.append(value)
                                }
                            }
                            arrayArrayAny.append(arrayAny)
                        }
                        pair = pairElement.rawValue
                        values = arrayArrayAny
                        break //since only one pair is delivered each time, when one is found we can skip searching for the others to speed up the process
                    }
                }
                last = try resultContainer.decode(String.self, forKey: .last)
                self.result = [pair: values, "last": last]
            } else {
                self.result = nil
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.error, forKey: .error)
            
            if self.result != nil {
                let keys = Array(self.result!.keys)
                let pairIndex = keys[0] == "last" ? 1 : 0
                let lastIndex = pairIndex == 0 ? 1 : 0
                
                let pair = Array(self.result!.keys)[pairIndex]
                let values = Array(self.result!.values)[pairIndex] as! [[Any]]
                let last = Array(self.result!.values)[lastIndex] as! String
                var resultContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .result)
                for pairElement in CodingKeys.array { // Search for all pairs
                    if (pair == pairElement.rawValue) {
                        var subContainer = resultContainer.nestedUnkeyedContainer(forKey: pairElement)
                        for value in values {
                            var subSubContainer = subContainer.nestedUnkeyedContainer()
                            let price = value[0] as! String
                            let volume = value[1] as! String
                            let time = value[2] as! Double
                            let buySell = value[3] as! String
                            let marketLimit = value[4] as! String
                            let miscellaneous = value[5] as! String
                            
                            try subSubContainer.encode(price)
                            try subSubContainer.encode(volume)
                            try subSubContainer.encode(time)
                            try subSubContainer.encode(buySell)
                            try subSubContainer.encode(marketLimit)
                            try subSubContainer.encode(miscellaneous)
                        }
                    }
                }
                try resultContainer.encode(last, forKey: .last)
            }
        }
    }
    
    // MARK: - Kraken API response handler
    
    //Handler of the response of the Kraken API when there was no network error
    func loadTradesResponse(APIReturnData: String, APIStatus: Int)-> String? {
        
        // print("\(dateString) Response \(currentMethod) key: \(key)")
        if APIStatus == 200 { //HTTP status: OK
            
            let decoder = JSONDecoder()
            let resultJSONDecoded = try! decoder.decode(GetPublicTrades.apiTradesResponseStruct.self, from: APIReturnData.data(using: .utf8)!)
            
            let error = resultJSONDecoded.error
            if error.count == 0 {
                if let result = resultJSONDecoded.result {
                    let keys = Array(result.keys)
                    let pairIndex = keys[0] == "last" ? 1 : 0
                    let pair = keys[pairIndex]
                    
                    let values = Array(result.values) as [Any]
                    
                    //This is the id to be used as since when polling for new, committed OHLC data
                    let lastIndex = pairIndex == 0 ? 1 : 0
                    let last = values[lastIndex] as! String
                    
                    var lastPrice = ""
                    let valuesArray = values[pairIndex] as! [Any]
                    if valuesArray.count > 0 { //it is 0 when while searching for a current trade that does not yet exist
                        let valuesArrayArray = values[pairIndex] as! [[Any]]
                        for index in 0..<valuesArray.count {
                            let price = valuesArrayArray[index][0] as! String
                            let volume = valuesArrayArray[index][1] as! String
                            let time = valuesArrayArray[index][2] as! Double
                            let buySell = valuesArrayArray[index][3] as! String
                            let marketLimit = valuesArrayArray[index][4] as! String
                            let miscellaneous = valuesArrayArray[index][5] as! String
                            
                       lastPrice = price
                        }
                        return lastPrice
                    }
                }
            } else {
                CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.Trades, error: error[0])
            }
        } else { //HTTP status: different than OK
            let statusMessage = "HTTP Status Code \(APIStatus)"
            CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.Trades, error: statusMessage)
        }
        return nil
    }
}
