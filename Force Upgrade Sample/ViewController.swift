//
//  ViewController.swift
//  Force Upgrade Sample
//
//  Created by Aparna Bhat on 16/01/23.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotification()
    }
    
    func registerForNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(checkForAppUpdate), name: RemoteConfigNotificationFetchCompleted, object: nil)
    }

    
    @objc func checkForAppUpdate() {
        
        //Dismiss alert if already presented
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
        
        let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        
        if RemoteConfigUtility.sharedInstance.isAppUpdateNeeded() {
            
            let alertController = UIAlertController.init(title: "We just got better!", message:"The new version of the app is here. It's time for you to update so you can enjoy the latest fixes, features and fun", preferredStyle: UIAlertController.Style.alert)
            let updateAction = UIAlertAction.init(title: "GET THE UPDATE", style: .default){ (action) -> Void in
                //Open app store
                self.openAppstore()
            }
            alertController.addAction(updateAction)
            
            if RemoteConfigUtility.sharedInstance.isOptionalUpdate(){
                print("optional update")
                let skipAction = UIAlertAction.init(title: "NOT NOW", style: .default){ (action) -> Void in
                    //Continue without app update
                }
                alertController.addAction(skipAction)
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            print("No update")
        }
    }
    
    
    func openAppstore(){
        if  let url  = URL(string: RemoteConfigUtility.sharedInstance.getRemoteConfigValueForKey(key: RemoteConfigKey.appStoreLink).stringValue!), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { (status) in
                print(status)
            }
        }
    }
    
}

