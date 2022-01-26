//
//  GradientButton.swift
//  WeatherBrick
//
//  Created by Vitaly Khryapin on 26.01.2022.
//

import Foundation
import UIKit


class GradientButton: UIButton {
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 1, green: 0.6, blue: 0.375, alpha: 1).cgColor,
            UIColor(red: 0.977, green: 0.315, blue: 0.106, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.75)
        return gradientLayer
    }()
}
