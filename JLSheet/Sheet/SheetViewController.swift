//
//  SheetViewController.swift
//  JLSheet
//
//  Created by Julian Lima on 30/01/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

/**
 TODO LIST
 - fix stretching to pan gesture
 */

class SheetViewController: UIViewController {
    
    private(set) var viewController: UIViewController
    
    @objc dynamic private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let draggableView: UIView = {
        let view = DraggableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contentWrapperView: UIView = {
       let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private let animationContext: DraggableAnimationContext
    
    var draggableViewObservation: NSKeyValueObservation?
    
    init(rootViewController: UIViewController, animationConfiguration: DraggableAnimationConfiguration = DraggableAnimationConfiguration()) {
        
        animationContext = DraggableAnimationContext(animationConfiguration)
        
        viewController = rootViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        draggableViewObservation?.invalidate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewControler Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        calculateInitialValues()
        
        initialAnimation()
    }
    
    // MARK: The initial setup

    private func setup() {
        view.backgroundColor = UIColor.clear
        
        addChild(viewController)
        
        view.addSubview(containerView)
        
        containerView.addSubview(draggableView)
        containerView.addSubview(contentWrapperView)
        containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        
        contentWrapperView.backgroundColor = viewController.view.backgroundColor
        contentWrapperView.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.didMove(toParent: self)
        
        observePositionInContainer()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            draggableView.topAnchor.constraint(lessThanOrEqualTo: containerView.topAnchor),
            draggableView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            draggableView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            draggableView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            contentWrapperView.topAnchor.constraint(equalTo: draggableView.bottomAnchor),
            contentWrapperView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            contentWrapperView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            contentWrapperView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: contentWrapperView.topAnchor),
            viewController.view.leftAnchor.constraint(equalTo: contentWrapperView.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: contentWrapperView.rightAnchor),
        ])
        
        // al mover la constraint del bottom del viewcontroller no se esta escondiendo la draggableView
        animationContext.bottomConstraint = viewController.view.bottomAnchor.constraint(lessThanOrEqualTo: contentWrapperView.bottomAnchor)
        animationContext.bottomConstraint?.isActive = true
    }
    
    private func calculateInitialValues() {
        containerView.setNeedsLayout()
        
        let viewHeight = containerView.frame.height
        let screenHeight = animationContext.screenSize.height
        let spaceToTop = screenHeight - viewHeight
        let minimumDistanceToTop = animationContext.minimumDistanceToTop
        
        let distanceToTop = spaceToTop >= minimumDistanceToTop ? spaceToTop : minimumDistanceToTop
        
        animationContext.initialDistanceToTop = distanceToTop
        
        animationContext.initialHeightContainerView = viewHeight
    }
    
    private func initialAnimation() {
        // TODO: avoid this change
        animationContext.bottomConstraint?.constant = animationContext.initialHeightContainerView
        view.layoutIfNeeded()
        
        animationContext.bottomConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1.0,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
                        self.view.layoutIfNeeded()
        })
        
    }
    
    private func observePositionInContainer() {
        draggableViewObservation = observe(\.containerView.center, options: [.new]) { (_, center) in
            guard let yPosition = self.containerView.superview?.convert(self.containerView.frame.origin, to: nil).y
                else { return }
            
            let percentageAlpha = self.getAlphaPercentage(yPosition)
                
            self.view.backgroundColor = UIColor.black.withAlphaComponent(percentageAlpha)
        }
    }
}

// MARK: Handle Pan Gesture

extension SheetViewController {
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: draggableView).y
        let locationOnScreen = draggableView.superview?.convert(draggableView.frame.origin, to: nil).y ?? 0
        
        if gestureRecognizer.state == .ended {
            let bottomPosition = animationContext.bottomConstraint?.constant ?? 0
            var shouldDismiss = false
            
            // dismiss case
            if bottomPosition > animationContext.collapseThreshold * animationContext.initialHeightContainerView {
                animationContext.bottomConstraint?.constant += animationContext.initialHeightContainerView
                shouldDismiss = true
            } else { // return case
                animationContext.bottomConstraint?.constant = 0
            }
            
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 1.0,
                           options: [.curveEaseInOut, .allowUserInteraction],
                           animations: {
                            self.view.layoutIfNeeded()
            }) { _ in
                    if shouldDismiss {
                            self.dismiss(animated: false)
                    }
                }
        } else if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {

            if locationOnScreen < animationContext.minimumDistanceToTop && translation < 0 {
                    animationContext.bottomConstraint?.constant += logValueForVerticalTranslation(translation)
                } else {
                    animationContext.bottomConstraint?.constant += translation
            }
        }
        
        gestureRecognizer.setTranslation(.zero, in: draggableView)
    }
    
    private func logValueForVerticalTranslation(_ translation: CGFloat) -> CGFloat {
        let sign = getSign(translation)
        
        let initialContainerHeight: CGFloat = animationContext.initialHeightContainerView
        let verticalLimit: CGFloat = animationContext.minimumDistanceToTop
        let actualContainerHeight: CGFloat = containerView.frame.height
        
        let startHeight: CGFloat = abs(verticalLimit - initialContainerHeight/2)
        let newHeight: CGFloat = abs(translation - actualContainerHeight/2)

        return log10( 1 + startHeight/newHeight ) * sign
    }
    
    private func getSign(_ value: CGFloat) -> CGFloat {
        return value > 0 ? 1 : -1
    }
    
    private func getAlphaPercentage(_ yPosition: CGFloat) -> CGFloat {
        let percentageAlpha = self.getPercentageOfScreen(yPosition)
        
        return percentageAlpha > 0.4 ? 0.4 : percentageAlpha
    }
    
    private func getPercentageOfScreen(_ position: CGFloat) -> CGFloat {
        return 1 - (position)/(animationContext.screenSize.height)
    }
}

private class DraggableAnimationContext {
    let minimumDistanceToTop: CGFloat
    
    var initialHeightContainerView: CGFloat {
        set {
            if _initialHeightContainerView == -1 && newValue > -1 {
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
            if _initialDistanceToTop == -1 && newValue > -1 {
                _initialDistanceToTop = newValue
            }
        }
        
        get{
            return _initialDistanceToTop
        }
    }
    
    private var _initialDistanceToTop: CGFloat = -1
    
    var bottomConstraint: NSLayoutConstraint?
    
    // TODO: rethink this var
    let screenSize: CGSize = UIScreen.main.bounds.size
    
    let collapseThreshold: CGFloat
    
    init(_ configuration: DraggableAnimationConfiguration) {
        self.minimumDistanceToTop = configuration.minimumDistanceToTop
        self.collapseThreshold = configuration.collapseThreshold
    }
}
