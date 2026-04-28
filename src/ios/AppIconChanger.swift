import Foundation
import Cordova

@objc(AppIconChanger) class AppIconChanger : CDVPlugin {
    
    // Check if the current device and iOS version support alternate icons
    @objc(isSupported:)
    func isSupported(command: CDVInvokedUrlCommand) {
        let supported = UIApplication.shared.supportsAlternateIcons
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: supported)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    // Change the application icon
    @objc(changeIcon:)
    func changeIcon(command: CDVInvokedUrlCommand) {
        // Optimization: Use guard to check support immediately
        guard UIApplication.shared.supportsAlternateIcons else {
            let errorResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "This version of iOS doesn't support alternate icons")
            self.commandDelegate.send(errorResult, callbackId: command.callbackId)
            return
        }
        
        // Parse arguments safely
        guard let options = command.arguments[0] as? [String: Any],
              let iconName = options["iconName"] as? String else {
            let errorResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "The 'iconName' parameter is mandatory")
            self.commandDelegate.send(errorResult, callbackId: command.callbackId)
            return
        }
        
        // Default suppressUserNotification to true if not provided
        let suppressUserNotification = options["suppressUserNotification"] as? Bool ?? true
        
        // Perform the icon change
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                let errorResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                self.commandDelegate.send(errorResult, callbackId: command.callbackId)
            } else {
                let successResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(successResult, callbackId: command.callbackId)
            }
        }
        
        if suppressUserNotification {
            self.suppressUserNotification()
        }
    }
    
    // MARK: - Helper Functions
    
    // Optimization: Streamlined alert suppression logic
    private func suppressUserNotification() {
        DispatchQueue.main.async {
            let suppressAlertVC = UIViewController()
            self.viewController?.present(suppressAlertVC, animated: false) {
                suppressAlertVC.dismiss(animated: false, completion: nil)
            }
        }
    }
}