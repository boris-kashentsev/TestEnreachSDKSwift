//
//  AppDelegate.swift
//  EnreachPOCSwift
//
//  Created by Boris Kashentsev on 19/07/2017.
//  Copyright © 2017 Boris Kashentsev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    HTTPCookieStorage.shared.cookieAcceptPolicy = .always
    
    /*let property1 = [HTTPCookiePropertyKey.domain: ".katsomo.fi",
                    HTTPCookiePropertyKey.name:"evid_0002",
                    HTTPCookiePropertyKey.value:"2b58b182-7808-46cb-8b01-0cc444a15b15",
                    HTTPCookiePropertyKey.path:"/",
                    HTTPCookiePropertyKey.version:"0",
                    HTTPCookiePropertyKey.expires:Date().addingTimeInterval(31556916)] as [HTTPCookiePropertyKey : Any]
    
    let cookie1 = HTTPCookie(properties: property1)
    HTTPCookieStorage.shared.setCookie(cookie1!)
    
    let property2 = [HTTPCookiePropertyKey.domain: ".katsomo.fi",
                    HTTPCookiePropertyKey.name:"evid_0002-synced",
                    HTTPCookiePropertyKey.value:"true",
                    HTTPCookiePropertyKey.path:"/",
                    HTTPCookiePropertyKey.version:"0",
                    HTTPCookiePropertyKey.expires:Date().addingTimeInterval(31556916)] as [HTTPCookiePropertyKey : Any]
    
    let cookie2 = HTTPCookie(properties: property2)
    HTTPCookieStorage.shared.setCookie(cookie2!)*/
    
    let parameters = ["domain":"http://admp-tc.katsomo.fi/", "admpApiVersion":"2.24.1"]
    Enreach.setup(parameters: parameters)
    Enreach.shared
    
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

