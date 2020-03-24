//
//  GradientView.swift
//  JLSheet
//
//  Created by Julian Lima on 22/03/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

internal class GradientView: UIView {

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear

        translatesAutoresizingMaskIntoConstraints = false
    }

    public override func draw(_: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let colors = [UIColor.white, UIColor.white.withAlphaComponent(0.1)].compactMap { $0.cgColor }

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let colorLocations: [CGFloat] = [0.0, 1.0]

        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!

        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])
    }

    public override func point(inside _: CGPoint, with _: UIEvent?) -> Bool {
        return false
    }
}

