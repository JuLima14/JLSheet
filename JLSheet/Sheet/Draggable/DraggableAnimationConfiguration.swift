//
//  DraggableAnimationConfiguration.swift
//  JLSheet
//
//  Created by Julian Lima on 01/02/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

public class DraggableAnimationConfiguration {
    let minimumDistanceToTop: CGFloat
    let collapseThreshold: CGFloat
    let velocityCollapseThreshold: CGFloat
    let translationDismissThreshold: CGFloat
    let screenSize: CGSize

    init(minimumDistanceToTop: CGFloat = UIScreen.main.bounds.size.height * 0.15,
         collapseThreshold: CGFloat = 0.6,
         velocityCollapseThreshold: CGFloat = 1500,
         translationDismissThreshold: CGFloat = 80,
         screenSize: CGSize = UIScreen.main.bounds.size) {
        self.minimumDistanceToTop = minimumDistanceToTop
        self.collapseThreshold = collapseThreshold
        self.velocityCollapseThreshold = velocityCollapseThreshold
        self.screenSize = screenSize
        self.translationDismissThreshold = translationDismissThreshold
    }
}

