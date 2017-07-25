//
//  CampaignsResponse.swift
//  EnreachPOCSwift
//
//  Created by Boris Kashentsev on 20/07/2017.
//  Copyright © 2017 Boris Kashentsev. All rights reserved.
//

import UIKit

public class CampaignsResponse {
  var evId: String
  var campaignIds: [String:String]
  var segments: [String]
  var reference: Bool
  
  var vv: String
  
  init(with jsonString:String) {
    self.evId = String()
    self.campaignIds = [String:String]()
    self.segments = [String]()
    self.vv = String()
    self.reference = false
    
    if let data = stripNativeMethodName(from: jsonString).data(using: .utf8) {
      do {
        let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
        
        for key in (jsonDictionary?.keys)! {
          switch key {
            case "evId":
              self.evId = jsonDictionary?["evId"] as! String
            case "vv":
              self.vv = jsonDictionary?["vv"] as! String
            case "campaignIds":
              self.campaignIds = jsonDictionary?["campaignIds"] as! [String:String]
            case "segments":
              self.segments = jsonDictionary?["segments"] as! [String]
            case "reference":
              self.reference = jsonDictionary?["reference"] as! Bool
            default:
              print("Warning: Unexpected key \"\(key)\" with a value \"\(jsonDictionary?[key] as! String)\" passed to CampaignsResponse init method.")
          }
        }
      } catch {
        print(error.localizedDescription)
      }
    }
    else {
      print("Error: Problem with JSON. Some problem with the encoding.")
    }
  }
  
  private func stripNativeMethodName(from str: String) -> String {
    if str.contains("native") {
      let startLocation = str.range(of: "(")
      let endLocation = str.range(of: ")", options: String.CompareOptions.backwards, range: nil, locale: nil)
      if startLocation != nil && endLocation != nil {
        return str [(startLocation?.upperBound)!..<(endLocation?.lowerBound)!]
      }
      else {
        print("Error: Problem with JSON format. Please, make sure that it has both '(' and ')' in it.")
      }
    }
    return str
  }
}
