//
//  ConverterViewController.swift
//  anarmyofones
//
//  Created by Fabian Mariño on 4/4/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import UIKit

// MARK: Local Constants

// Define server side script URL
let EXCHANGESURL = "https://api.fixer.io/latest?base=USD&symbols=GBP,EUR,JPY,BRL"
let REQUESTMETHOD = "GET"
let CURRENCIES = [ "UK": "GBP",
                   "EUR": "EUR",
                   "JAP": "JPY",
                   "BRA": "BRL"
                 ]
let FIELDMAXLENGTH = 8
let DEFAULTAMOUNT = 1.0

class ConverterViewController: UIViewController, UITextFieldDelegate {
    
    var _dollarAmount: Double? = DEFAULTAMOUNT
    var _exchangesDictionary:[String:Double]?
    let _currencyFormatter : NSNumberFormatter = NSNumberFormatter()
    var _requestedWasOk = false
    
    @IBOutlet weak var lblGBP: UILabel!
    @IBOutlet weak var lblEUR: UILabel!
    @IBOutlet weak var lblBRL: UILabel!
    @IBOutlet weak var lblJPY: UILabel!
    
    @IBOutlet weak var dollarNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets format number style to currency
        _currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        //set delegate for dollarnumberUITextField
        self.dollarNumberTextField.delegate = self
        
        //get current dollar price from fixer.io
        getCurrencyValues(self.updateValues)
        
        // Gesture that recognices tap to hide keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action:Selector("endEditing:"))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture);
    }
    
    // fetches exchange values for dollar using a get request and receiving a callback
    func getCurrencyValues(completion: (() -> Void)!) {
        
        // Create NSURL Ibject
        let pricesUrl = NSURL(string: EXCHANGESURL);
        
        // Creaste URL Request
        let pricesRequest = NSMutableURLRequest(URL:pricesUrl!);
        
        // Set request HTTP method to GET. It could be POST as well
        pricesRequest.HTTPMethod = REQUESTMETHOD
        
        // Excute HTTP Request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(pricesRequest) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    self._requestedWasOk = true
                    
                    self._exchangesDictionary = convertedJsonIntoDict["rates"] as? [String : Double]
                    
                    completion() //callback
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                
                self._requestedWasOk = false
            }
            
        }
        
        task.resume()
    }
    
    //displays equivalent values in different format currencies.
    func updateValues() {
     
      dispatch_async(dispatch_get_main_queue(), {
        
            //Calculates and shows exchange value for UK Pounds
            if var priceGBP = self._exchangesDictionary![CURRENCIES["UK"]!] {
                priceGBP = priceGBP * self._dollarAmount!;
                self._currencyFormatter.currencyCode = CURRENCIES["UK"]!
                self.lblGBP.text = self._currencyFormatter.stringFromNumber(priceGBP);
            }
        
            //Calculates and shows exchange value for Euros
            if var priceEUR = self._exchangesDictionary![CURRENCIES["EUR"]!] {
                priceEUR = priceEUR * self._dollarAmount!;
                self._currencyFormatter.currencyCode = CURRENCIES["EUR"]!
                self.lblEUR.text = self._currencyFormatter.stringFromNumber(priceEUR);
                
            }
        
            //Calculates and shows exchange value for Brasilian reals
            if var priceBRL = self._exchangesDictionary![CURRENCIES["BRA"]!] {
                priceBRL = priceBRL * self._dollarAmount!;
                self._currencyFormatter.currencyCode = CURRENCIES["BRA"]!
                self.lblBRL.text = self._currencyFormatter.stringFromNumber(priceBRL);
            }
        
            //Calculates and shows exchange value for Japan Yens
            if var priceJPY = self._exchangesDictionary![CURRENCIES["JAP"]!] {
                priceJPY = priceJPY * self._dollarAmount!;
                self._currencyFormatter.currencyCode = CURRENCIES["JAP"]!
                self.lblJPY.text = self._currencyFormatter.stringFromNumber(priceJPY);
            }
      })
    
    }
    
    // detects when dollarNumberTextField changed
    @IBAction func didDollarChange(sender: AnyObject) {
        
        self._dollarAmount = DEFAULTAMOUNT //just in case the textfield format is not valid
        
        if let dollarTextNumer: String = self.dollarNumberTextField.text {
            if let dollarConverted = Double(dollarTextNumer) {
                self._dollarAmount = dollarConverted
            }
        }
        
        self.updateValues()
    }
    
//MARK: Textfield methods 
    
    //Sets a max value for dollarNumberTextField
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
        let currentString: NSString = textField.text!
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= FIELDMAXLENGTH
    }
    
    // function that hides keyboard after touch
    func endEditing(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
}
