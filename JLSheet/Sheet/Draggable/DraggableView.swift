//
//  DraggableView.swift
//  JLSheet
//
//  Created by Julian Lima on 30/01/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

class DraggableView: UIView {
    
    private let handleView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(handleView)
        
        handleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            handleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            handleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            handleView.heightAnchor.constraint(equalToConstant: 5),
            handleView.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        handleView.layer.cornerRadius = 2
        handleView.backgroundColor = UIColor.gray
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(roundedRect:bounds,
                                byRoundingCorners:[.topRight, .topLeft],
                                cornerRadii: CGSize(width: 20, height:  20))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
