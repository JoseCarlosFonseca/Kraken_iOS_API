//
//  TableViewController.swift
//  Kraken_iOS_API
//
//  Created by José Fonseca on 26/08/2018.
//  Copyright © 2018 Ze. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet weak var KrakenAPIURL: UITextField!
    @IBOutlet weak var APIKeyTextField: UITextField!
    @IBOutlet weak var APISecretTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KrakenAPIURL.text = "https://api.kraken.com"
        
        //You may put here your API credentials
        APIKeyTextField.text = "" //Your API Key
        APISecretTextField.text! = "" //Your API Secret
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Public Market Data

    @IBOutlet weak var publicTime: UILabel!
    
    @IBAction func getPublicTimeButton(_ sender: UIButton) {
        guard APIKeyTextField.text != nil && APISecretTextField.text != nil else { return }
        let url = CallKrakenAPI().url(APIKey: APIKeyTextField.text!, APISecret: APISecretTextField.text!, webServiceUrl: KrakenAPIURL.text!, webServiceName: .`public`, webServiceOperation: .Time, webServiceRequest: nil)
        CallKrakenAPI().callWebService(webServiceUrl: url, webServiceCallbackResultHandler: getPublicTimeResultHandler)
    }
    
    func getPublicTimeResultHandler(APIReturnData: String, APIStatus: Int) -> Void {
        let result = GetPublicTime().loadTimeResponse(APIReturnData: APIReturnData, APIStatus: APIStatus)
        if let unixtime = result.0, let rfc1123 = result.1 {
            publicTime.text = "\(unixtime) \(rfc1123)"
        }
    }
    
    
    @IBOutlet weak var publicTicker: UILabel!
    
    @IBAction func getPublicTickerButton(_ sender: UIButton) {
        guard APIKeyTextField.text != nil && APISecretTextField.text != nil else { return }
        let url = CallKrakenAPI().url(APIKey: APIKeyTextField.text!, APISecret: APISecretTextField.text!, webServiceUrl: KrakenAPIURL.text!, webServiceName: .`public`, webServiceOperation: .Ticker, webServiceRequest: ["pair": "XXBTZEUR"])
        CallKrakenAPI().callWebService(webServiceUrl: url, webServiceCallbackResultHandler: getPublicTickerResultHandler)
    }
    
    func getPublicTickerResultHandler(APIReturnData: String, APIStatus: Int) -> Void {
        if let result = GetPublicTicker().loadTickerResponse(APIReturnData: APIReturnData, APIStatus: APIStatus) {
            publicTicker.text = "XXBTZEUR: \(result)"
        } else {
            publicTicker.text = ""
        }
    }
    
    @IBOutlet weak var publicTrades: UILabel!
    
    @IBAction func getPublicTradesButton(_ sender: UIButton) {
        guard APIKeyTextField.text != nil && APISecretTextField.text != nil else { return }
        let url = CallKrakenAPI().url(APIKey: APIKeyTextField.text!, APISecret: APISecretTextField.text!, webServiceUrl: KrakenAPIURL.text!, webServiceName: .`public`, webServiceOperation: .Trades, webServiceRequest: ["pair": "XXBTZEUR"])
        CallKrakenAPI().callWebService(webServiceUrl: url, webServiceCallbackResultHandler: getPublicTradesResultHandler)
    }
    
    func getPublicTradesResultHandler(APIReturnData: String, APIStatus: Int) -> Void {
        if let result = GetPublicTrades().loadTradesResponse(APIReturnData: APIReturnData, APIStatus: APIStatus) {
            publicTrades.text = "XXBTZEUR: \(result)"
        } else {
            publicTrades.text = ""
        }
    }

    @IBOutlet weak var publicOHLC: UILabel!
    
    @IBAction func getPublicOHLCButton(_ sender: UIButton) {
        guard APIKeyTextField.text != nil && APISecretTextField.text != nil else { return }
        let url = CallKrakenAPI().url(APIKey: APIKeyTextField.text!, APISecret: APISecretTextField.text!, webServiceUrl: KrakenAPIURL.text!, webServiceName: .`public`, webServiceOperation: .OHLC, webServiceRequest: ["pair": "XXBTZEUR","interval": "60"])
        CallKrakenAPI().callWebService(webServiceUrl: url, webServiceCallbackResultHandler: getPublicOHLCResultHandler)
    }
    
    func getPublicOHLCResultHandler(APIReturnData: String, APIStatus: Int) -> Void {
        if let result = GetPublicOHLC().loadOHLCResponse(APIReturnData: APIReturnData, APIStatus: APIStatus) {
            publicOHLC.text = "XXBTZEUR 60: \(result)"
        } else {
            publicOHLC.text = ""
        }
    }
    
    // MARK: - Private Market Data
    
    @IBOutlet weak var privateBalance: UILabel!
    
    @IBAction func getPrivateBalanceButton(_ sender: UIButton) {
        guard APIKeyTextField.text != nil && APISecretTextField.text != nil else { return }
        let url = CallKrakenAPI().url(APIKey: APIKeyTextField.text!, APISecret: APISecretTextField.text!, webServiceUrl: KrakenAPIURL.text!, webServiceName: .`private`, webServiceOperation: .Balance, webServiceRequest: nil)
        CallKrakenAPI().callWebService(webServiceUrl: url, webServiceCallbackResultHandler: getPrivateBalanceHandler)
    }
    
    func getPrivateBalanceHandler(APIReturnData: String, APIStatus: Int) -> Void {
        if let result = GetPrivateBalance().loadBalanceResponse(APIReturnData: APIReturnData, APIStatus: APIStatus) {
            privateBalance.text = "\(result)"
        } else {
            privateBalance.text = ""
        }
    }
    
    @IBOutlet weak var privateTradeBalance: UILabel!
    
    @IBAction func getPrivateTradeBalanceButton(_ sender: UIButton) {
        guard APIKeyTextField.text != nil && APISecretTextField.text != nil else { return }
        let url = CallKrakenAPI().url(APIKey: APIKeyTextField.text!, APISecret: APISecretTextField.text!, webServiceUrl: KrakenAPIURL.text!, webServiceName: .`private`, webServiceOperation: .TradeBalance, webServiceRequest: ["asset":"ZEUR"])
        CallKrakenAPI().callWebService(webServiceUrl: url, webServiceCallbackResultHandler: getPrivateTradeBalanceHandler)
    }
    
    func getPrivateTradeBalanceHandler(APIReturnData: String, APIStatus: Int) -> Void {
        if let result = GetPrivateTradeBalance().loadTradeBalanceResponse(APIReturnData: APIReturnData, APIStatus: APIStatus) {
            privateTradeBalance.text = "\(result)"
        } else {
            privateTradeBalance.text = ""
        }
    }

    @IBOutlet weak var privateTradesHistory: UILabel!
    
    @IBAction func getPrivateTradesHistoryButton(_ sender: UIButton) {
        guard APIKeyTextField.text != nil && APISecretTextField.text != nil else { return }
        let url = CallKrakenAPI().url(APIKey: APIKeyTextField.text!, APISecret: APISecretTextField.text!, webServiceUrl: KrakenAPIURL.text!, webServiceName: .`private`, webServiceOperation: .TradesHistory, webServiceRequest: nil)
        CallKrakenAPI().callWebService(webServiceUrl: url, webServiceCallbackResultHandler: getPrivateTradesHistoryHandler)
    }
    
    func getPrivateTradesHistoryHandler(APIReturnData: String, APIStatus: Int) -> Void {
        if let result = GetPrivateTradesHistory().loadTradesHistoryResponse(APIReturnData: APIReturnData, APIStatus: APIStatus) {
            privateTradesHistory.text = "\(result)"
        } else {
            privateTradesHistory.text = ""
        }
    }

    @IBOutlet weak var privateOpenOrders: UILabel!
    
    @IBAction func getPrivateOpenOrdersButton(_ sender: UIButton) {
        guard APIKeyTextField.text != nil && APISecretTextField.text != nil else { return }
        let url = CallKrakenAPI().url(APIKey: APIKeyTextField.text!, APISecret: APISecretTextField.text!, webServiceUrl: KrakenAPIURL.text!, webServiceName: .`private`, webServiceOperation: .OpenOrders, webServiceRequest: nil)
        CallKrakenAPI().callWebService(webServiceUrl: url, webServiceCallbackResultHandler: getPrivateOpenOrdersHandler)
    }
    
    func getPrivateOpenOrdersHandler(APIReturnData: String, APIStatus: Int) -> Void {
        if let result = GetPrivateOpenOrders().loadOpenOrdersResponse(APIReturnData: APIReturnData, APIStatus: APIStatus) {
            privateOpenOrders.text = "\(result)"
        } else {
            privateOpenOrders.text = ""
        }
    }
    
    // MARK: - Private User Trading

    @IBOutlet weak var privateAddOrder: UILabel!
    
    // Add a standard order: sell 1 BTC/EUR with limit 100€
    @IBAction func getPrivateAddOrderButton(_ sender: UIButton) {
        guard APIKeyTextField.text != nil && APISecretTextField.text != nil else { return }
        let url = CallKrakenAPI().url(APIKey: APIKeyTextField.text!, APISecret: APISecretTextField.text!, webServiceUrl: KrakenAPIURL.text!, webServiceName: .`private`, webServiceOperation: .AddOrder, webServiceRequest: ["pair": "XXBTZEUR", "type": "sell", "ordertype": "limit", "price": "100", "volume": "1.0", "oflags": "post"])
        CallKrakenAPI().callWebService(webServiceUrl: url, webServiceCallbackResultHandler: getPrivateAddOrderHandler)
    }
    
    func getPrivateAddOrderHandler(APIReturnData: String, APIStatus: Int) -> Void {
        if let result = SetPrivateAddOrder().loadAddOrderResponse(APIReturnData: APIReturnData, APIStatus: APIStatus) {
            privateAddOrder.text = "\(result)"
        } else {
            privateAddOrder.text = ""
        }
    }
}
