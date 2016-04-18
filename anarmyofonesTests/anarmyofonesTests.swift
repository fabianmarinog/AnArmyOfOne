//
//  anarmyofonesTests.swift
//  anarmyofonesTests
//
//  Created by Fabian Mariño on 4/4/16.
//  Copyright © 2016 Fabian Mariño. All rights reserved.
//

import XCTest

class anarmyofonesTests: XCTestCase {
    
    var viewController: ConverterViewController!
    var expectation:XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.classForCoder))
        viewController = storyboard.instantiateInitialViewController() as! ConverterViewController
        viewController.loadView()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCurrenciesCount() {
        // Check currencies has 4 items
        let count = CURRENCIES.count
        XCTAssertEqual(count, 4)
    }
    
    func testDollarAmountIs1(){
        //at the beggining dollarAmount should be 1.0
        if let dollarAmount = self.viewController._dollarAmount {
            XCTAssertEqual(dollarAmount, 1.0)
        }
    }
    
    func afterRequestTest(){
        
        XCTAssertTrue(self.viewController._requestedWasOk) //checks if request had no error
        
        let exchangeDictCount = self.viewController._exchangesDictionary
        XCTAssertEqual(exchangeDictCount?.count, 4) //checks that exchangeDictionary has 4 items, one for each rate
        
        
        if var testPriceGBP = exchangeDictCount![CURRENCIES["UK"]!] {
            if let dollarAmount = self.viewController._dollarAmount {
                testPriceGBP = testPriceGBP * dollarAmount;
                XCTAssertGreaterThan(testPriceGBP, 0.0) //Checks if exchange conversion is greater than 0
            }
        }
        
        self.expectation?.fulfill()
        
    }
    
    func testRequestIsOk(){
        
        self.expectation = self.expectationWithDescription("asynchronous exchange values request")
        
        self.viewController.getCurrencyValues(self.afterRequestTest)
        
        self.waitForExpectationsWithTimeout(10.0, handler:nil)
        
    }
    
    /*func testPerformanceExample() {
        // Performance test case.
        self.measureBlock {
            // code to measure the time of updating prices.
            self.viewController.updatePrices()
        }
    }*/
    
}
