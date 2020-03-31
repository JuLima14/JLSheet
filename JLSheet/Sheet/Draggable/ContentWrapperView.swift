//
//  ContentWrapperView.swift
//  JLSheet
//
//  Created by Julian Lima on 24/03/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

class ContentWrapperView: UIView {
    private(set) weak var contentView: UIView?
    
    @objc dynamic private(set) var contentScrollView: UIScrollView
    
    private var contentScrollViewConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        contentScrollView = UIScrollView(frame: .zero)
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentScrollView)
        
        updateContentScrollViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(view: UIView, animated: Bool = false, completion: (()->())? = nil) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        contentScrollView.addSubview(view)
        
        view.frame = contentScrollView.frame
        view.center = contentScrollView.center.applying(CGAffineTransform(translationX: bounds.width, y: 0))
        
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       delay: 0,
                       options: animated ? [.allowUserInteraction] : [],
                       animations: {
                        view.center = self.contentScrollView.center
        }, completion: { _ in
            completion?()
            
            self.contentView?.removeFromSuperview()
            self.contentView = view
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: self.contentScrollView.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.contentScrollView.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: self.contentScrollView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.contentScrollView.trailingAnchor),
            ])
            
            self.contentScrollView.setContentOffset(.zero, animated: false)
        })
    }
    
    func updateContentScrollView(contentScrollView: UIScrollView) {
        self.contentScrollView.removeFromSuperview()
        
        self.contentScrollView = contentScrollView
        
        addSubview(contentScrollView)
        
        updateContentScrollViewConstraints()
    }
    
    private func updateContentScrollViewConstraints() {
        contentScrollViewConstraints = [
            contentScrollView.topAnchor.constraint(equalTo: topAnchor),
            contentScrollView.leftAnchor.constraint(equalTo: leftAnchor),
            contentScrollView.rightAnchor.constraint(equalTo: rightAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(contentScrollViewConstraints)
    }
}
