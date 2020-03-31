//
//  SheetViewController.swift
//  JLSheet
//
//  Created by Julian Lima on 30/01/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

public class SheetViewController: UIViewController {
    private(set) var viewControllers: [UIViewController] = []
    
    private var visibleViewController: UIViewController? {
        return viewControllers.last
    }

    @objc private dynamic let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let draggableView: DraggableView = .init(frame: .zero)

    private let contentWrapperView: ContentWrapperView = .init(frame: .zero)

    private let headerGradientView: GradientView = .init()

    private let animationContext: DraggableAnimationContext

    private var centerContainerViewObservation: NSKeyValueObservation?
    private var contentSizeContentScrollViewObservation: NSKeyValueObservation?

    init(rootViewController: UIViewController, animationConfiguration: DraggableAnimationConfiguration = .init()) {
        animationContext = DraggableAnimationContext(animationConfiguration)

        viewControllers.append(rootViewController)
        
        super.init(nibName: nil, bundle: nil)
        
        rootViewController.sheetViewController = self
    }

    deinit {
        removeObservers()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupConstraints()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        calculateInitialValues()

        initialAnimation()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        view.backgroundColor = UIColor.black.withAlphaComponent(0)

        super.viewWillDisappear(animated)
    }

    // MARK: The initial setup

    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.clear

        guard let presentedViewController = visibleViewController else { return }
        
        addChild(presentedViewController)

        view.addSubview(containerView)

        containerView.addSubview(draggableView)
        containerView.addSubview(contentWrapperView)
        containerView.addSubview(headerGradientView)

        let panGestureContainerView = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        containerView.addGestureRecognizer(panGestureContainerView)
        animationContext.containerViewPanGesture = panGestureContainerView
        containerView.backgroundColor = presentedViewController.view.backgroundColor
        
        contentWrapperView.setContent(view: presentedViewController.view)
        
        presentedViewController.didMove(toParent: self)

        if let childScrollView = loadChildScrollView() {
            contentWrapperView.updateContentScrollView(contentScrollView: childScrollView)
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(scrollViewHandlePan(_:)))
        panGesture.delegate = self
        contentWrapperView.contentScrollView.addGestureRecognizer(panGesture)
        animationContext.scrollViewPanGesture = panGesture

        addObservers()

        containerView.bringSubviewToFront(headerGradientView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            draggableView.topAnchor.constraint(lessThanOrEqualTo: containerView.topAnchor),
            draggableView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            draggableView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            draggableView.heightAnchor.constraint(equalToConstant: 44),
        ])

        NSLayoutConstraint.activate([
            headerGradientView.topAnchor.constraint(lessThanOrEqualTo: draggableView.bottomAnchor),
            headerGradientView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            headerGradientView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            headerGradientView.heightAnchor.constraint(equalToConstant: 2),
        ])

        NSLayoutConstraint.activate([
            contentWrapperView.topAnchor.constraint(equalTo: draggableView.bottomAnchor),
            contentWrapperView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            contentWrapperView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            contentWrapperView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        animationContext.heightContainerConstraint = containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        animationContext.heightContainerConstraint?.isActive = true

        animationContext.topConstraint = containerView.topAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor)
        animationContext.topConstraint?.isActive = true
        
        animationContext.heightScrollViewConstraint = contentWrapperView.contentScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        animationContext.heightScrollViewConstraint?.isActive = true
    }

    private func calculateInitialValues() {
        containerView.setNeedsLayout()
        
        let viewHeight = containerView.frame.height
        let screenHeight = animationContext.screenSize.height
        let spaceToTop = screenHeight - viewHeight
        let minimumDistanceToTop = animationContext.minimumDistanceToTop

        let distanceToTop = spaceToTop >= minimumDistanceToTop ? spaceToTop : minimumDistanceToTop

        animationContext.initialDistanceToTop = distanceToTop

        let maxSize = animationContext.screenSize.height - distanceToTop

        animationContext.initialHeightContainerView = viewHeight >= maxSize ? maxSize : viewHeight

        animationContext.heightContainerConstraint?.constant = animationContext.initialHeightContainerView
    }

    private func initialAnimation() {
        animationContext.topConstraint?.constant = -animationContext.initialHeightContainerView

        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1.0,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
                           self.view.layoutIfNeeded()
        })
    }

    @objc private func tapToDismiss() {
        dismissSheet()
    }

    private func dismissSheet() {
        animationContext.topConstraint?.constant = 0

        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1.0,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
                           self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    private func returnToOriginSheet() {
        animationContext.heightContainerConstraint?.constant = animationContext.initialHeightContainerView
        animationContext.topConstraint?.constant = -animationContext.initialHeightContainerView

        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1.0,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
                           self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func loadChildScrollView() -> UIScrollView? {
        if let scrollView = visibleViewController?.view.subviews.first as? UIScrollView { // First level
            return scrollView
        } else if let scrollView = visibleViewController?.view.subviews.first?.subviews.first as? UIScrollView { // Second Level
            return scrollView
        }
        
        return nil
    }

    override public func viewWillLayoutSubviews() {
        let path = UIBezierPath(roundedRect: containerView.bounds,
                                byRoundingCorners: [.topRight, .topLeft],
                                cornerRadii: CGSize(width: 8, height: 8))

        let maskLayer = CAShapeLayer()

        maskLayer.path = path.cgPath
        containerView.layer.mask = maskLayer
    }
}

// MARK: Observers methods

extension SheetViewController {
    private func addObservers() {
        centerContainerViewObservation = containerView.observe(\.center, options: .new) { _, _ in
            guard let yPosition = self.containerView.superview?.convert(self.containerView.frame.origin, to: nil).y
            else { return }

            let percentageAlpha: CGFloat = self.getAlphaPercentage(yPosition)

            self.view.backgroundColor = UIColor.black.withAlphaComponent(percentageAlpha)
        }

        contentSizeContentScrollViewObservation = contentWrapperView.contentScrollView.observe(\.contentSize, options: [.old, .new]) { _, _ in
                if self.animationContext.lastContentSizeHeight != self.contentWrapperView.contentScrollView.contentSize.height {
                    let screenSize: CGSize = self.animationContext.screenSize
                    let screenHeight: CGFloat = screenSize.height
                    let minimumDistanceToTop: CGFloat = self.animationContext.minimumDistanceToTop
                    let contentSize: CGFloat = self.contentWrapperView.contentScrollView.contentSize.height
                    let maxSize: CGFloat = screenHeight - minimumDistanceToTop

                    self.animationContext.heightScrollViewConstraint?.constant = contentSize > maxSize ? maxSize : contentSize
                }
                self.animationContext.lastContentSizeHeight = self.contentWrapperView.contentScrollView.contentSize.height
        }
    }

    private func removeObservers() {
        centerContainerViewObservation?.invalidate()
        contentSizeContentScrollViewObservation?.invalidate()
    }
}

// MARK: Handle Pan Gesture

extension SheetViewController {
    @objc private func scrollViewHandlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translationInView: CGFloat = gestureRecognizer.translation(in: draggableView).y
        let isDraggingDown: Bool = translationInView > 0

        if gestureRecognizer.state == .began && isDraggingDown {
            handlePan(gestureRecognizer)
        } else if gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            handlePan(gestureRecognizer)
        }
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translationInView: CGFloat = gestureRecognizer.translation(in: draggableView).y
        let locationInView: CGFloat = gestureRecognizer.location(in: containerView).y
        let velocity: CGFloat = gestureRecognizer.velocity(in: draggableView).y
        let locationOnScreen: CGFloat = draggableView.superview?.convert(draggableView.frame.origin, to: nil).y ?? 0
        let isDraggingDown: Bool = translationInView > 0
        let translation: CGFloat = (isDraggingDown && locationInView < 0.0) ? 0.0 : translationInView

        if gestureRecognizer.state == .ended {
            didEndDragging(with: velocity)
            animationContext.lastTranslationInView = 0.0
        } else if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            didChangeDragging(isDraggingDown: isDraggingDown, translation: translation, locationOnScreen: locationOnScreen)
            animationContext.lastTranslationInView = translation
        }

        gestureRecognizer.setTranslation(.zero, in: draggableView)
    }

    private func didEndDragging(with velocity: CGFloat) {
        let lastTranslationInView: CGFloat = animationContext.lastTranslationInView
        let isDraggingDown: Bool = lastTranslationInView > 0
        let topPosition: CGFloat = -(animationContext.topConstraint?.constant ?? 0)

        if topPosition < animationContext.collapseThreshold * animationContext.initialHeightContainerView ||
            ((lastTranslationInView > animationContext.translationDismissThreshold
                || velocity > animationContext.velocityCollapseThreshold)
                && isDraggingDown) {
            dismissSheet()
        } else {
            returnToOriginSheet()
        }
    }

    private func didChangeDragging(isDraggingDown: Bool, translation: CGFloat, locationOnScreen: CGFloat) {
        let offsetHeight: CGFloat = 4

        if locationOnScreen < animationContext.minimumDistanceToTop, !isDraggingDown {
            animationContext.topConstraint?.constant += logValueForVerticalTranslation(translation)
            animationContext.heightContainerConstraint?.constant -= logValueForVerticalTranslation(translation - offsetHeight)
        } else {
            animationContext.topConstraint?.constant += translation
            animationContext.heightContainerConstraint?.constant -= translation - offsetHeight
        }
    }

    private func logValueForVerticalTranslation(_ translation: CGFloat) -> CGFloat {
        let sign = getSign(translation)

        let initialContainerHeight: CGFloat = animationContext.initialHeightContainerView
        let verticalLimit: CGFloat = animationContext.minimumDistanceToTop
        let actualContainerHeight: CGFloat = containerView.frame.height

        let startHeight: CGFloat = abs(verticalLimit - initialContainerHeight / 2)
        let newHeight: CGFloat = abs(translation - actualContainerHeight / 2)

        return log10(1 + startHeight / newHeight) * sign
    }

    private func getSign(_ value: CGFloat) -> CGFloat {
        return value > 0 ? 1 : -1
    }

    private func getAlphaPercentage(_ yPosition: CGFloat) -> CGFloat {
        let percentageAlpha: CGFloat = getPercentageOfScreen(yPosition)
        return percentageAlpha > 0.6 ? 0.6 : percentageAlpha
    }

    private func getPercentageOfScreen(_ position: CGFloat) -> CGFloat {
        let initialPosition: CGFloat = animationContext.initialDistanceToTop
        let newPosition: CGFloat = position < initialPosition ? initialPosition : position
        return 1 - newPosition / animationContext.screenSize.height
    }
}

// MARK: Handle Pan Gesture of ScrollView

extension SheetViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer === animationContext.scrollViewPanGesture, contentWrapperView.contentScrollView.isAtTop {
            return true
        }

        if touch.view == view {
            return true
        }

        return false
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let translationInView: CGFloat = pan.translation(in: draggableView).y
            let isDraggingDown: Bool = translationInView > 0

            return isDraggingDown
        }

        if gestureRecognizer.view === view {
            return true
        }

        return false
    }
}

extension SheetViewController {
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewControllers.append(viewController)
        
        viewController.sheetViewController = self
        
        addChild(viewController)
        
        contentWrapperView.setContent(view: viewController.view, animated: animated, completion: {
            viewController.didMove(toParent: self)
        })
    }
}

public extension UIViewController {
    private static var _sheetViewController = [String:SheetViewController]()
    
    weak var sheetViewController: SheetViewController? {
        get {
            return UIViewController._sheetViewController[self.debugDescription]
        }
        set(newValue) {
            UIViewController._sheetViewController[self.debugDescription] = newValue
        }
    }
    
}

class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
      return nil
    }
}
