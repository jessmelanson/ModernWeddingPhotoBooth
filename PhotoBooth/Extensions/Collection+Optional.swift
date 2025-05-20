//
//  Collection+Optional.swift
//  PhotoBooth
//
//  Created by Jess Melanson on 1/1/25.
//

import Foundation

extension Collection {
  subscript(safe index: Index) -> Iterator.Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
