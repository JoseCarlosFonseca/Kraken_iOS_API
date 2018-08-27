//
//  CallKrakenAPI.swift
//  Kraken_iOS_API
//
//  Created by José Fonseca on 26/08/2018.
//  Copyright © 2018 Ze. All rights reserved.
//

import Foundation
import UIKit

class CallKrakenAPI: NSObject, URLSessionDelegate  {
    
    //API type
    enum Api: String {
        case `private`, `public`
    }
    
    enum Method: String {
        case Time, Ticker, OHLC, Trades, Balance, TradeBalance, TradesHistory, OpenOrders, AddOrder
        
        init?(string: String) {
            switch string {
            case "Time": self = .Time
            case "Ticker": self = .Ticker
            case "OHLC": self = .OHLC
            case "Trades": self = .Trades
            case "Balance": self = .Balance
            case "TradeBalance": self = .TradeBalance
            case "TradesHistory": self = .TradesHistory
            case "OpenOrders": self = .OpenOrders
            case "AddOrder": self = .AddOrder
            default: return nil
            }
        }
    }
    
    enum currencyPairPicker: String {
        case XXBTZEUR, BCHEUR, XETHZEUR
        
        static let arrayRawValue = ["XXBTZEUR", "BCHEUR", "XETHZEUR"] // to allow iteration
        static let array = [XXBTZEUR, BCHEUR, XETHZEUR] // to allow iteration
    }
    
    enum intervalPicker: Int {
        case one = 1, five = 5, fifteen = 15, thirty = 30, one_hour = 60, two_hours = 240, one_day = 1440, one_week = 10080, half_month = 21600 //minutes
        
        static let arrayRawValue = [1, 5, 15, 30, 60, 240, 1440, 10080, 21600] // to allow iteration
        static let array = [one, five, fifteen, thirty, one_hour, two_hours, one_day, one_week, half_month] // to allow iteration
    }
    
    enum currencyPicker: String {
        case ZEUR, USD
        
        static let arrayRawValue = ["ZEUR", "USD"] // to allow iteration
        static let array = [ZEUR, USD] // to allow iteration
    }
    
    // MARK: - callWebService method
    
    //Calls the Web Service and when the response is received it calls back a completion handler to deal with the results
    func callWebService(webServiceUrl: NSMutableURLRequest ,webServiceCallbackResultHandler: @escaping (_ wsReturnData: String, _ wsStatus: Int) -> Void) {
        
        // start the display the network activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //Creates a task that retrieves the contents of a URL based on the specified URL request object, and calls a handler upon completion.
        let task = URLSession.shared.dataTask(with: webServiceUrl as URLRequest) { (data, response, error) in
            
            DispatchQueue.main.async { //execute in the main queue. UIKit classes have to be accessed on the main thread.
                // stop the display the network activity indicator
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if error == nil { // There is no network error
                let status = (response as! HTTPURLResponse).statusCode
                if let dataValue = data {
                    let returnData = NSString(data: dataValue, encoding: String.Encoding.ascii.rawValue)
                    DispatchQueue.main.async { //execute in the main queue. UIKit classes have to be accessed on the main thread.
                        webServiceCallbackResultHandler(returnData! as String, status)
                    }
                } else { // There is no data (eg. the web service did not return any data)
                    let methodFromHttpResponse = Method(string: ((response as! HTTPURLResponse).url?.lastPathComponent)!)
                    
                    DispatchQueue.main.async { //execute in the main queue. UIKit classes have to be accessed on the main thread.
                        self.APINoDataHandler(APIStatus: status, APIMethod: methodFromHttpResponse)
                    }
                }
            } else { // There is an error (eg. no network connection)
                let error = error!
                DispatchQueue.main.async { //execute in the main queue. UIKit classes have to be accessed on the main thread.
                    self.APIErrorHandler(APIMethod: nil, APIError: error.localizedDescription)
                }
            }
        }
        //Send the network request
        task.resume()
    }
    
    // MARK: - URLSessionDelegate methods
    
    //Requests credentials from the delegate in response to a session-level authentication request from the remote server.
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler:  @escaping(URLSession.AuthChallengeDisposition, URLCredential?) -> Void){
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    // MARK: - WS API response handler when there are errors
    
    //Handler of the response of the trader API when there was no data returned
    func APINoDataHandler(APIStatus: Int, APIMethod: Method?) -> Void {
        printError(APIMethod: APIMethod, error: String(describing: APIStatus))
    }
    
    //Handler of the response of the trader API when there was an network error
    func APIErrorHandler(APIMethod: Method?, APIError: String) -> Void {
        printError(APIMethod: APIMethod, error: APIError)
    }
    
    // MARK: - Print error message private method
    
    //Print error message with time stamp
    func printError(APIMethod: Method?, error: String) {
        let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss" //Specify the format that you want
        let dateString = dateFormatter.string(from: date)
        let method = APIMethod?.rawValue ?? "Unknown method"
        print("\(dateString) \(method) error -> \(error)")
    }
    
    func url(APIKey: String, APISecret: String,webServiceUrl: String, webServiceName: Api, webServiceOperation: Method, webServiceRequest: [String: String]?)-> NSMutableURLRequest {
        var hash = ""
        var hashData = Data()
        var binaryData = Data()
        var secretDecoded = Data()
        var sign = Data()
        var pathSh256 = Data()
        var apiKey = ""
        var apiSign = ""
        var path = ""
        let serviceName = "/\(webServiceName.rawValue)/"
        var serviceRequest = ""
        var postdata = ""
        
        let webServicePath = "/0"+serviceName+"\(webServiceOperation)"
        let url = NSURL(string: "\(webServiceUrl)\(webServicePath)")!
        
        //Create an request object and configurate it
        let request = NSMutableURLRequest(url: url as URL)
        
        if let webServiceRequests = webServiceRequest {
            for(key,value) in webServiceRequests {
                serviceRequest += key+"="+value+"&"
            }
        }
        
        if serviceName == "/private/" {
            // generate a 64 bit nonce using a timestamp at microsecond resolution
            // string functions are used to avoid problems on 32 bit systems
            let nonce = Int64(Date().timeIntervalSince1970 * 1000000)
            postdata = "\(serviceRequest)nonce=\(nonce)"
            path = "/0"+serviceName+"\(webServiceOperation)"
            
            hash = ("\(nonce)"+postdata).sha256!
            
            hashData = hash.data(using: .bytesHexLiteral)!
            
            binaryData = path.data(using: .utf8, allowLossyConversion: false)!
            
            let lenTotal = binaryData.count + hashData.count
            pathSh256 = Data(capacity: lenTotal)
            for i in 0..<binaryData.count {
                let j = binaryData.index(binaryData.startIndex, offsetBy: i)
                let bytes = binaryData[j]
                pathSh256.append(bytes)
            }
            for i in 0..<(hashData.count) {
                let j = hashData.index((hashData.startIndex), offsetBy: i)
                let bytes = hashData[j]
                pathSh256.append(bytes)
            }
            
            secretDecoded = Data(base64Encoded: APISecret, options: .ignoreUnknownCharacters)!
            
            sign = HMAC.sign(data: pathSh256, algorithm: .sha512, key: secretDecoded)
            
            apiSign = String(data: (sign.base64EncodedData()),encoding: String.Encoding.utf8)!
            apiKey = APIKey
            
            request.addValue(apiKey, forHTTPHeaderField: "API-Key")
            request.addValue(apiSign, forHTTPHeaderField: "API-Sign")
        } else {
            postdata = "\(serviceRequest)"
        }
        
        request.addValue("Kraken PHP API Agent", forHTTPHeaderField: "User-Agent")
        request.addValue("\(postdata.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = postdata.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        return request
    }
}
