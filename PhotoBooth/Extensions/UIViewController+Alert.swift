//
//  UIViewController+Alert.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/3/25.
//

import UIKit

extension UIViewController {
  func showErrorAlert(
    _ errorMessage: String,
    okTapped: (() -> Void)? = nil
  ) {
    let alert = UIAlertController(title: Strings.Global.error, message: errorMessage, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: Strings.Global.ok, style: .default) { _ in
      okTapped?()
    })
    present(alert, animated: true, completion: nil)
  }
  
  func showSuccessAlert(
    title: String,
    message: String,
    okTapped: (() -> Void)? = nil
  ) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: Strings.Global.ok, style: .default) { _ in
      okTapped?()
    })
    present(alert, animated: true, completion: nil)
  }
}
