//
//  AppDelegate.swift
//  ParseChat
//
//  Created by Kay Lab on 5/6/19.
//  Copyright © 2019 Darrel Muonekwu. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    Parse.initialize(with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) in
    
        // conecting this app with the parse server that i set up
        configuration.applicationId = "Parstagram"
        configuration.server = "https://stark-river-64085.herokuapp.com/parse"
        
    }))
        
        if PFUser.current() != nil {
            let main = UIStoryboard(name: "Main", bundle: nil)
            
            let feedNavigationVC = main.instantiateViewController(withIdentifier: Controllers.FeedNavigationController)
            
            window?.rootViewController = feedNavigationVC
        }
        
        return true
    }
}

