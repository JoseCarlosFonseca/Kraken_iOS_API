//
//  SetPrivateAddOrder.swift
//  Kraken_iOS_API
//
//  Created by José Fonseca on 27/08/2018.
//  Copyright © 2018 Ze. All rights reserved.
//

import Foundation

class SetPrivateAddOrder {
    // MARK: - Structs
    
    //apiAddOrderStruct
    struct apiAddOrderResponseStruct: Codable {
        let error: [String]
        let result: apiAddOrderResponseSubStruct?
        
        struct apiAddOrderResponseSubStruct: Codable {
            let descr: apiAddOrderResponseSubSubStruct
            let txid: [String]
        }
        
        struct apiAddOrderResponseSubSubStruct: Codable {
            let order: String
        }
        /*
         EGeneral:Invalid arguments
         EService:Unavailable
         ETrade:Invalid request
         EOrder:Cannot open position
         EOrder:Cannot open opposing position
         EOrder:Margin allowance exceeded
         EOrder:Margin level too low
         EOrder:Insufficient margin (exchange does not have sufficient funds to allow margin trading)
         EOrder:Insufficient funds (insufficient user funds)
         EOrder:Order minimum not met (volume too low)
         EOrder:Orders limit exceeded
         EOrder:Positions limit exceeded
         EOrder:Rate limit exceeded
         EOrder:Scheduled orders limit exceeded
         EOrder:Unknown position
         */
    }
    
    //AddOrder
    struct AddOrderRequestStruct {
        let pair: CallKrakenAPI.currencyPairPicker
        let type: AddOrderRequestType
        let ordertype: AddOrderRequestOrderType
        let price: String
        let price2: String
        let volume: Double
        let oflags: String?
        var createdTime: Int
        var balanceCount: Int?
        var status: AddOrderRequestStatus
        var startExecutingTime: Int?
        var executedTime: Int?
        
        enum AddOrderRequestStatus {
            case created, submitted, executed
        }
        
        enum AddOrderRequestType: String {
            case buy, sell
        }
        
        enum AddOrderRequestOrderType: String {
            case market, limit, stopLoss = "stop-loss", takeProfit = "take-profit", stopLossProfit = "stop-loss-profit", stopLossProfitLimit = "stop-loss-profit-limit", stopLossLimit = "stop-loss-limit", takeProfitLimit = "take-profit-limit", trailingStop = "trailing-stop", trailingStopLimit = "trailing-stop-limit", stopLossAndLimit = "stop-loss-and-limit", settlePosition = "settle-position"
        }
        
        /*
         pair = asset pair
         type = type of order (buy/sell)
         ordertype = order type:
         market
         limit (price = limit price)
         stop-loss (price = stop loss price)
         take-profit (price = take profit price)
         stop-loss-profit (price = stop loss price, price2 = take profit price)
         stop-loss-profit-limit (price = stop loss price, price2 = take profit price)
         stop-loss-limit (price = stop loss trigger price, price2 = triggered limit price)
         take-profit-limit (price = take profit trigger price, price2 = triggered limit price)
         trailing-stop (price = trailing stop offset)
         trailing-stop-limit (price = trailing stop offset, price2 = triggered limit offset)
         stop-loss-and-limit (price = stop loss price, price2 = limit price)
         settle-position
         price = price (optional.  dependent upon ordertype)
         price2 = secondary price (optional.  dependent upon ordertype)
         volume = order volume in lots
         leverage = amount of leverage desired (optional.  default = none)
         oflags = comma delimited list of order flags (optional):
         viqc = volume in quote currency (not available for leveraged orders)
         fcib = prefer fee in base currency
         fciq = prefer fee in quote currency
         nompp = no market price protection
         post = post only order (available when ordertype = limit)
         starttm = scheduled start time (optional):
         0 = now (default)
         +<n> = schedule start time <n> seconds from now
         <n> = unix timestamp of start time
         expiretm = expiration time (optional):
         0 = no expiration (default)
         +<n> = expire <n> seconds from now
         <n> = unix timestamp of expiration time
         userref = user reference id.  32-bit signed number.  (optional)
         validate = validate inputs only.  do not submit order (optional)
         
         optional closing order to add to system when order gets filled:
         close[ordertype] = order type
         close[price] = price
         close[price2] = secondary price
         
         */
    }
    
    // MARK: - Kraken API response handler
    
    //Handler of the response of the Kraken API when there was no network error
    func loadAddOrderResponse(APIReturnData: String, APIStatus: Int)-> String? {
        
        if APIStatus == 200 { //HTTP status: OK
            
            let decoder = JSONDecoder()
            
            let resultJSONDecoded = try! decoder.decode(apiAddOrderResponseStruct.self, from: APIReturnData.data(using: .utf8)!)
            let error = resultJSONDecoded.error
            if error.count == 0 {
                if let order = resultJSONDecoded.result?.descr.order {
                    if let txid = resultJSONDecoded.result?.txid {
                        return "\(order) \(txid) created"
                    }
                }
            } else {
                CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.AddOrder, error: error[0])
            }
        } else { //HTTP status: different than OK
            let statusMessage = "HTTP Status Code \(APIStatus)"
            CallKrakenAPI().printError(APIMethod: CallKrakenAPI.Method.AddOrder, error: statusMessage)
        }
        return nil
    }
}
