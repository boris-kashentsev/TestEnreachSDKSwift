//
//  Enreach.swift
//  EnreachPOCSwift
//
//  Created by Boris Kashentsev on 19/07/2017.
//  Copyright © 2017 Boris Kashentsev. All rights reserved.
//

import UIKit

private let EMPTYEVID: String = "-entered"

private class SingletonSetupHelper {
  var parameterms: [String:String]?
}

class Enreach {
  static let shared = Enreach()
  private static let setup = SingletonSetupHelper()
  private var responseData: Data
  
  var evid: String
  var paths: EnreachPaths
  
  class func setup(parameters:[String:String]) {
    Enreach.setup.parameterms = parameters
  }
  
  private init() {
    let parameters = Enreach.setup.parameterms
    guard parameters != nil else {
      fatalError("Error - you must call setup before accessing Enreach.shared")
    }
    
    self.evid = EMPTYEVID
    self.paths = EnreachPaths(with: parameters!)
    self.responseData = Data()
    
    self.getUserEvid()
    
    debugPrint("STATUS: Enreach.shared initialized")
  }
  
  func isEmptyEvid() -> Bool {
    return evid == EMPTYEVID
  }
  
  func clearEvid() {
    evid = EMPTYEVID;
    UserDefaults.standard.removeObject(forKey: "evid")
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
  
  func getUserEvid() {
    if UserDefaults.standard.object(forKey: "evId") != nil {
      self.evid = UserDefaults.standard.object(forKey: "evId") as! String
    }
    else {
      let getUserURL = URL(string: paths.getUser())!
      let dataTask = URLSession.shared.dataTask(with: getUserURL, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
        self.handleGetUser(data: data!, response: response!)
      })
      dataTask.resume()
    }
  }
  
  private func handleGetUser(data:Data, response:URLResponse) {
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
      if let responseString = String(data:data, encoding: .utf8), !responseString.contains(EMPTYEVID) {
        do {
          let strippedData = stripNativeMethodName(from: responseString).data(using: .utf8)!
          let jsonDictionary = try JSONSerialization.jsonObject(with: strippedData, options: []) as? [String:Any]
          if jsonDictionary?["evId"] != nil {
            self.evid = jsonDictionary?["evId"] as! String
            UserDefaults.standard.set(self.evid, forKey: "evId")
            UserDefaults.standard.synchronize()
          }
        }
        catch {
          debugPrint("ERROR: Problem serializing JSON object")
        }
      }
      else {
        let getCampaignsURL : URL = URL(string: paths.getCampaigns(with: ["evid":self.evid, "includeSegments":"true"]))!
        let dataTask = URLSession.shared.dataTask(with: getCampaignsURL, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
          self.handleGetCampaigns(data: data!, response: response!)
        })
        dataTask.resume()
      }
    }
    else {
      debugPrint("ERROR: Problem acessing getUser API")
    }
  }
  
  private func handleGetCampaigns(data:Data, response:URLResponse) {
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
      let validateURL : URL = URL(string: paths.validate(with: ["evid": self.evid]))!
      let dataTask = URLSession.shared.dataTask(with: validateURL, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
        self.handleValidate(data: data!, response: response!)
      })
      dataTask.resume()
    }
    else {
      debugPrint("ERROR: Problem acessing getCampaigns API")
    }
  }
  
  private func handleValidate(data:Data, response:URLResponse) {
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
      if let responseString = String(data:data, encoding: .utf8), !responseString.contains(EMPTYEVID) {
        do {
          let strippedData = stripNativeMethodName(from: responseString).data(using: .utf8)!
          let jsonDictionary = try JSONSerialization.jsonObject(with: strippedData, options: []) as? [String:Any]
          if jsonDictionary?["evId"] != nil && self.evid == EMPTYEVID && (jsonDictionary!["evId"] as! String) != EMPTYEVID {
            self.evid = jsonDictionary?["evId"] as! String
            UserDefaults.standard.set(self.evid, forKey: "evId")
            UserDefaults.standard.synchronize()
          }
        }
        catch {
          debugPrint("ERROR: Problem serializing JSON object")
        }
      }
    }
    else {
      debugPrint("ERROR: Problem acessing validate API")
    }
  }
  
  func getCampaigns(with block:@escaping (_ result: CampaignsResponse) -> Void) {
    let getCampaignsURL:URL = URL(string: paths.getCampaigns(with: ["evid": evid, "includeSegments":"true"]))!
    let dataTask:URLSessionDataTask = URLSession.shared.dataTask(with: getCampaignsURL) { (data:Data?, response:URLResponse?, error:Error?) in
      let jsonResponse:String = String(data:data!, encoding: .utf8)!
      let campResp: CampaignsResponse = CampaignsResponse(with: jsonResponse)
      block(campResp)
    }
    dataTask.resume()
  }
  
  func getCampaignsSync() -> CampaignsResponse {
    let getCampaignsURL:URL = URL(string: paths.getCampaigns(with: ["evid": evid, "includeSegments":"true"]))!
    let semaphore = DispatchSemaphore(value: 1)
    let dataTask:URLSessionDataTask = URLSession.shared.dataTask(with: getCampaignsURL) { (data:Data?, response:URLResponse?, error:Error?) in
      self.responseData = data!
      semaphore.signal()
    }
    
    dataTask.resume()
    semaphore.wait()
    
    return CampaignsResponse(with: String(data: responseData, encoding: .utf8)!)
  }
  
  func serVisitor(with provider:String, id:String) {
    let parameters: [String:String] = ["source":provider, "id":id, "evid":evid]
    
    let registerURL : URL = URL(string: paths.register(with: parameters))!
    
    let dataTask = URLSession.shared.dataTask(with: registerURL) { (data:Data?, response:URLResponse?, error:Error?) in
      debugPrint("STATUS: registration for provider \(provider) with ID \(id) is done")
    }
    dataTask.resume()
  }
  
  func pageStat(with location:String) {
    let parameters : [String:String] = ["location":location, "evid":evid]
    
    let pageStatURL : URL = URL(string: paths.pageStat(with: parameters))!
    
    let dataTask = URLSession.shared.dataTask(with: pageStatURL) { (data:Data?, response:URLResponse?, error:Error?) in
      debugPrint("STATUS: page statistcs sent with location \(location)")
    }
    
    dataTask.resume()
  }
  
  func placementStat(with location:String, ids:[String]) {
    placementStat(with: "id", location: location, ids: ids)
  }
  
  func placementStat(with source:String, location:String, ids:[String]) {
    let parameters : [String:String] = ["location": location, "evid": evid, "source":source, "values": ids.joined(separator: ",")]
    
    let placementStatURL = URL(string: paths.placementStat(with: parameters))!
    
    let dataTask = URLSession.shared.dataTask(with: placementStatURL) { (data:Data?, response:URLResponse?, error:Error?) in
      debugPrint("STATUS: placement statistics sent with location \(location), source \(source) and IDs \(ids.joined(separator: ","))")
    }
    
    dataTask.resume()
  }
  
  func arStat(with location:String) {
    let parameters : [String:String] = ["location": location, "evid": evid]
    
    let arStatURL : URL = URL(string: paths.adStat(with: parameters))!
    
    let dataTask = URLSession.shared.dataTask(with: arStatURL) { (data:Data?, response:URLResponse?, error:Error?) in
      debugPrint("STATUS: arStat was sent with location \(location)")
    }
    
    dataTask.resume()
  }
  
  private func getParameters(with evid:String, location:String, action:String, adInfo:AdInfo) -> [String:String] {
    return ["location": location, "evid": evid, "action": action, "adId": adInfo.adId, "bnId": adInfo.bnId, "pId": adInfo.pId]
  }
  
  private func adStatTask(with parameters:[String:String]) {
    let adStatURL = URL(string: paths.adStat(with: parameters))!
    
    let dataTask = URLSession.shared.dataTask(with: adStatURL) { (data:Data?, response:URLResponse?, error:Error?) in
      debugPrint("STATUS: adStat was sent with location \(parameters["location"]!) and action \(parameters["action"]!)")
    }
    
    dataTask.resume()
  }
  
  func adDwellTime(with location:String, adInfo:AdInfo) {
    let parameters : [String:String] = getParameters(with: evid, location: location, action: AdStatState.shared.getType(AdStatStateEnum.DWELL) , adInfo: adInfo)
    
    adStatTask(with: parameters)
  }
  
  func adClick(with location:String, adInfo:AdInfo) {
    let parameters : [String:String] = getParameters(with: evid, location: location, action: AdStatState.shared.getType(AdStatStateEnum.CLICK) , adInfo: adInfo)
    
    adStatTask(with: parameters)
  }
  
  func adImpression(with location:String, adInfo:AdInfo) {
    let parameters : [String:String] = getParameters(with: evid, location: location, action: AdStatState.shared.getType(AdStatStateEnum.IMPRESSION) , adInfo: adInfo)
    
    adStatTask(with: parameters)
  }
  
  func videoStart(with location:String, adInfo:AdInfo) {
    let parameters : [String:String] = getParameters(with: evid, location: location, action: AdStatState.shared.getType(AdStatStateEnum.VIDEO_START) , adInfo: adInfo)
    
    adStatTask(with: parameters)
  }
  
  func videoFirstQuartile(with location:String, adInfo:AdInfo) {
    let parameters : [String:String] = getParameters(with: evid, location: location, action: AdStatState.shared.getType(AdStatStateEnum.VIDEO_FIRST_QUARTILE) , adInfo: adInfo)
    
    adStatTask(with: parameters)
  }
  
  func videoMidPoint(with location:String, adInfo:AdInfo) {
    let parameters : [String:String] = getParameters(with: evid, location: location, action: AdStatState.shared.getType(AdStatStateEnum.VIDEO_MIDPOINT) , adInfo: adInfo)
    
    adStatTask(with: parameters)
  }
  
  func videoThirdQuartile(with location:String, adInfo:AdInfo) {
    let parameters : [String:String] = getParameters(with: evid, location: location, action: AdStatState.shared.getType(AdStatStateEnum.VIDEO_THIRD_QUARTILE) , adInfo: adInfo)
    
    adStatTask(with: parameters)
  }
  
  func videoComplete(with location:String, adInfo:AdInfo) {
    let parameters : [String:String] = getParameters(with: evid, location: location, action: AdStatState.shared.getType(AdStatStateEnum.VIDEO_COMPLETE) , adInfo: adInfo)
    
    adStatTask(with: parameters)
  }
  
}
