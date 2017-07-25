//
//  EnreachPaths.swift
//  EnreachPOCSwift
//
//  Created by Boris Kashentsev on 21/07/2017.
//  Copyright © 2017 Boris Kashentsev. All rights reserved.
//

import UIKit

public class EnreachPaths {
  
  var domain: String
  
  var getUserPath: String = getUserPathConst
  var campaignsPath: String = campaignsPathConst
  var validatePath: String = validatePathConst
  var registerPath: String = registerPathConst
  var arStatPath: String = arStatPathConst
  var adStatPath: String = adStatPathConst
  var pageStatPath: String = pageStatPathConst
  var placementPath: String = placementPathConst
  
  var adServerId: String = ""
  
  var admpApiVersion: String = admpApiVersionConst
  
  public init(with parameters:[String:String]) {
    if parameters["domain"] != nil {
      self.domain = parameters["domain"]!
    }
    else {
      print("Error: EnreachPath requires domain to be initialized.")
      self.domain = ""
      return
    }
    
    for key in parameters.keys {
      switch key {
        case "domain":
          continue
        case "getUserPath":
          self.getUserPath = parameters[key]!
        case "campaignsPath":
          self.campaignsPath = parameters[key]!
        case "validatePath":
          self.validatePath = parameters[key]!
        case "registerPath":
          self.registerPath = parameters[key]!
        case "arStatPath":
          self.arStatPath = parameters[key]!
        case "adStatPath":
          self.adStatPath = parameters[key]!
        case "pageStatPath":
          self.pageStatPath = parameters[key]!
        case "placementPath":
          self.placementPath = parameters[key]!
        case "adServerId":
          self.adServerId = parameters[key]!
        case "admpApiVersion":
          self.admpApiVersion = parameters[key]!
        default:
          print("Warning: Unexpected key \"\(key)\" with a value \"\(parameters[key]!)\" passed to EnreachPaths init method.")
      }
    }
    
  }
  
  func getUser() -> String {
    return getUser(with: [String:String]())
  }
  
  func getUser(with parameters:[String:String]) -> String {
    return getFullURL(with: domain, path: getUserPath, parameters: parameters, requiresAdServerId: false)
  }
  
  func getCampaigns(with parameters:[String:String]) -> String {
    return getFullURL(with: domain, path: campaignsPath, parameters: parameters, requiresAdServerId: false)
  }
  
  func register(with parameters:[String:String]) -> String {
    return getFullURL(with: domain, path: registerPath, parameters: parameters, requiresAdServerId: false)
  }
  
  func validate(with parameters:[String: String]) -> String {
    return getFullURL(with: domain, path: validatePath, parameters: parameters, requiresAdServerId: false)
  }
  
  func pageStat(with parameters:[String:String]) -> String {
    return getFullURL(with: domain, path: pageStatPath, parameters: parameters, requiresAdServerId: false)
  }
  
  func placementStat(with parameters:[String:String]) -> String {
    return getFullURL(with: domain, path: placementPath, parameters: parameters, requiresAdServerId: true)
  }
  
  func adStat(with parameters:[String:String]) -> String {
    return getFullURL(with: domain, path: adStatPath, parameters: parameters, requiresAdServerId: true)
  }
  
  func arStat(with parameters:[String:String]) -> String {
    return getFullURL(with: domain, path: arStatPath, parameters: parameters, requiresAdServerId: false)
  }
  
  private func getFullURL(with domain:String, path:String, parameters:[String:String], requiresAdServerId:Bool) -> String {
    if domain == "" {
      print("Error: Domain parameter is empty.")
    }
    
    var resultURL = domain + path + "?"
    for key in parameters.keys {
      resultURL += encode(key) + "=" + encode(parameters[key]!) + "&"
    }
    
    if requiresAdServerId {
      resultURL += "adserverid=" + encode(adServerId) + "&"
    }
    
    resultURL += "cb=" + String(Date().timeIntervalSince1970) + "&"
    resultURL += "callback=native" + "&"
    resultURL += "v=" + admpApiVersion
    
    return resultURL
  }
  
  private func encode(_ string:String) -> String {
    let result = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed);
    return result != nil ? result! : ""
  }
}
