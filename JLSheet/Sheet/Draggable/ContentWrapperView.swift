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
    
    func setContent(view: UIView) {
        contentView?.removeFromSuperview()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView = view
        
        contentScrollView.addSubview(view)
        
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
        ])
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
