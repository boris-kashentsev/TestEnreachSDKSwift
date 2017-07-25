//
//  AdInfo.swift
//  EnreachPOCSwift
//
//  Created by Boris Kashentsev on 20/07/2017.
//  Copyright © 2017 Boris Kashentsev. All rights reserved.
//

import UIKit

class AdInfo {
  let pId: String
  let adId: String
  let bnId: String
  
  init(with placementId:String) {
    self.pId = placementId
    self.adId = ""
    self.bnId = ""
  }
  
  init(with placementId: String, campaignId: String, creativeId: String) {
    self.pId = placementId
    self.adId = campaignId
    self.bnId = creativeId
  }
}
