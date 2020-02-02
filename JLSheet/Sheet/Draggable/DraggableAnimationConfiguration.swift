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
    
    init(minimumDistanceToTop: CGFloat = 50, collapseThreshold: CGFloat = 0.2) {
        self.minimumDistanceToTop = minimumDistanceToTop
        self.collapseThreshold = collapseThreshold
    }
}
