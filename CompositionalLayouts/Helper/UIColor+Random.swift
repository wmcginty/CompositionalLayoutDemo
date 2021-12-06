//
//  UIColor+Random.swift
//  CompositionalLayouts
//
//  Created by Will McGinty on 10/15/21.
//

import UIKit

extension UIColor {

    static var random: UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    }
}
