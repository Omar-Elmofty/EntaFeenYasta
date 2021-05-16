//
//  EntaFeenYastaTests.swift
//  EntaFeenYastaTests
//
//  Created by Omar Elmofty on 2021-05-13.
//

import XCTest
@testable import EntaFeenYasta

class EntaFeenYastaTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
           
        }
    }
    
    func testParamMap() throws {
        // Do any additional setup after loading the view.
        let param_map = AttributeHandler()

        // Check Reading wrong Json
        XCTAssertFalse(param_map.fromJson(json_dir: "wrong_json.json"))

        // Check reading correct Json
        XCTAssertTrue(param_map.fromJson(json_dir: "/Users/omarelmofty/user_info.json"))

        // Reading the username
        var user_name : String = ""
        XCTAssertTrue(param_map.get(key : "user_name", value : &user_name))
        XCTAssertTrue(user_name == "omarelmofty")

        // Reading wrong variable
        var wrong_var : String = ""
        XCTAssertFalse(param_map.get(key : "wrong_var", value : &wrong_var))

        // Test setting and getting a param
        let in_int : Int = 10
        param_map.set(key : "int", value : in_int)
        var out_int : Int?
        XCTAssertTrue(param_map.get(key : "int", value : &out_int))
        XCTAssertEqual(out_int, in_int)
    }
    
    func testMapMarker() throws
    {
        let base_user = MapMarker(name : "omar", location : (1.0, 2.0))
        
        var user_name : String = ""
        var location : (Double, Double) = (0.0, 0.0)
        
        XCTAssertTrue(base_user.get(key : "user_name", value : &user_name))
        XCTAssertTrue(base_user.get(key : "location", value : &location))
        XCTAssertEqual(location.0, 1.0, accuracy : 0.01)
        XCTAssertEqual(location.1, 2.0, accuracy : 0.01)
    }
}
