//
//  UIScrollView+Extension.swift
//  JLSheet
//
//  Created by Julian Lima on 22/03/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

extension UIScrollView {
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset: CGFloat = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight: CGFloat = bounds.size.height
        let scrollContentSizeHeight: CGFloat = contentSize.height
        let bottomInset: CGFloat = contentInset.bottom
        let scrollViewBottomOffset: CGFloat = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}
