//
//  RemoteConfigUtility.swift
//  ConsumerApp
//
//  Created by Priyanka on 9/26/16.
//  Copyright © 2016 Spireon. All rights reserved.
//

import Firebase

let RemoteConfigNotificationFetchCompleted = Notification.Name("com.spireon.fleet.remoteconfigfetched")

struct RemoteConfigKey {
    static let appStoreLink         = "ios_app_store_link"
    static let forceUpgrade         = "ios_force_upgrade"
    static let versionCode          = "ios_version_code"
    static let forceUpdateContinue  = "ios_force_upgrade_show_continue"
}

class RemoteConfigUtility {
    
    public static var sharedInstance = RemoteConfigUtility()
    var remoteConfig: RemoteConfig?

    private  init() {
        //private init for singleton class object
    }
    
    func setup() {
        
        FirebaseApp.configure()
        remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings.init()
        remoteConfig?.configSettings = remoteConfigSettings
        
        // Fetch default configuration from local plist
        remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        //Fetch remote config from firebase console
        fetchRemoteConfig()
    }
    
    func getRemoteConfigValueForKey(key: String) -> RemoteConfigValue {
        if remoteConfig == nil {
            remoteConfig = RemoteConfig.remoteConfig()
            remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
        }
        return (remoteConfig?.configValue(forKey: key)) ?? RemoteConfigValue.init()
    }

    func postRemoteConfigCompletionNotification(){
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: RemoteConfigNotificationFetchCompleted, object: nil)
        }
    }
    
    //Check if app update is needed or not
    func appUpdateNeeded() -> Bool {
        var appUpdateNeeded = false
        let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let remoteAppVersion = (RemoteConfigUtility.sharedInstance.getRemoteConfigValueForKey(key: RemoteConfigKey.versionCode).stringValue)!
        let shouldForceUpdate = RemoteConfigUtility.sharedInstance.getRemoteConfigValueForKey(key: RemoteConfigKey.forceUpgrade).boolValue
        let compareValue = remoteAppVersion.compare(currentAppVersion, options: NSString.CompareOptions.numeric)
        if compareValue == ComparisonResult.orderedDescending &&  shouldForceUpdate == true {
            appUpdateNeeded = true
        }
        return appUpdateNeeded
    }
    
    //Check if the update is optional or mandatory
    func isOptionalUpdate()->Bool{
        return RemoteConfigUtility.sharedInstance.getRemoteConfigValueForKey(key: RemoteConfigKey.forceUpdateContinue).boolValue
        
    }
    
    func fetchRemoteConfig(isForceFetch:Bool? = false){
        let interval:TimeInterval = (isForceFetch ?? false) ? 0: 3600
        
        remoteConfig?.fetch(withExpirationDuration: TimeInterval(interval)) { (status, error) -> Void in
            if (status == RemoteConfigFetchStatus.success) {
                self.remoteConfig?.activate(completion: { (acivated, error) in
                    self.postRemoteConfigCompletionNotification()
                })
            } else if let error = error { //Unwrap
                print(error)
                self.postRemoteConfigCompletionNotification()
            }
        }
    }


}

