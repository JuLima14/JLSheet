//
//  DraggableAnimationContext.swift
//  JLSheet
//
//  Created by Julian Lima on 22/03/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

internal class DraggableAnimationContext {
    weak var containerViewPanGesture: UIPanGestureRecognizer?
    weak var scrollViewPanGesture: UIPanGestureRecognizer?

    var lastContentSizeHeight: CGFloat = 0

    let minimumDistanceToTop: CGFloat

    var lastTranslationInView: CGFloat = 0.0

    var initialHeightContainerView: CGFloat {
        set {
            if _initialHeightContainerView == -1, newValue > -1 {
                _initialHeightContainerView = newValue
            }
        }

        get {
            return _initialHeightContainerView
        }
    }

    private var _initialHeightContainerView: CGFloat = -1

    var initialDistanceToTop: CGFloat {
        set {
            if _initialDistanceToTop == -1, newValue > -1 {
                _initialDistanceToTop = newValue
            }
        }

        get {
            return _initialDistanceToTop
        }
    }

    private var _initialDistanceToTop: CGFloat = -1

    var topConstraint: NSLayoutConstraint?

    var heightContainerConstraint: NSLayoutConstraint?

    var heightScrollViewConstraint: NSLayoutConstraint?

    let screenSize: CGSize

    let collapseThreshold: CGFloat

    let velocityCollapseThreshold: CGFloat
    
    let translationDismissThreshold: CGFloat

    init(_ configuration: DraggableAnimationConfiguration) {
        self.minimumDistanceToTop = configuration.minimumDistanceToTop
        self.collapseThreshold = configuration.collapseThreshold
        self.velocityCollapseThreshold = configuration.velocityCollapseThreshold
        self.translationDismissThreshold = configuration.translationDismissThreshold
        self.screenSize = configuration.screenSize
    }
}

