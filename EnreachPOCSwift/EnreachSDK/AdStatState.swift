//
//  AdStatState.swift
//  EnreachPOCSwift
//
//  Created by Boris Kashentsev on 21/07/2017.
//  Copyright © 2017 Boris Kashentsev. All rights reserved.
//

import UIKit

enum AdStatStateEnum: Int {
  case IMPRESSION = 0, CLICK, DWELL, VIDEO_START, VIDEO_MIDPOINT, VIDEO_FIRST_QUARTILE, VIDEO_THIRD_QUARTILE, VIDEO_COMPLETE
}

class AdStatState {
  static let shared = AdStatState()
  
  private static let adStatStateDictionary: [Int : String] = [0:"imp", 1:"click", 2:"dwellTime", 3:"start", 4:"midpoint", 5:"firstQuartile", 6:"thirdQuartile", 7:"complete"]
  
  func getType(_ adStat:AdStatStateEnum) -> String {
    return AdStatState.adStatStateDictionary[adStat.rawValue]!
  }
}
