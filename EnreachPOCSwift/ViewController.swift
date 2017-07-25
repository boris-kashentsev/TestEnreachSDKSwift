//
//  ViewController.swift
//  EnreachPOCSwift
//
//  Created by Boris Kashentsev on 19/07/2017.
//  Copyright © 2017 Boris Kashentsev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view, typically from a nib.
  }

  @IBAction func getCampaignsClicked(_ sender: Any) {
    Enreach.shared.getCampaigns { (response:CampaignsResponse) in
      print("response evId is \(response.evId)")
      print("Swift blocks are working as suppose to")
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

