//
//  UIApplication+ViewHierarchy.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/4/25.
//

import UIKit

extension UIApplication {
  /// Retrieves the top-most view controller in the app's window hierarchy.
  /// See https://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller 
  class func topViewController(from base: UIViewController? = nil) -> UIViewController? {
    let baseVC = base ?? UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }?
      .rootViewController
    
    switch baseVC {
    case let nav as UINavigationController:
      return topViewController(from: nav.visibleViewController)
    case let tab as UITabBarController:
      return topViewController(from: tab.selectedViewController)
    case let presented where baseVC?.presentedViewController != nil:
      return topViewController(from: presented?.presentedViewController)
    default:
      return baseVC
    }
  }
}

