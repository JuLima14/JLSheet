//
//  DummyViewController.swift
//  JLSheet
//
//  Created by Julian Lima on 30/01/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

class DummyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        let stackView = createDummyStackView(createDummyRandomListViews())
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createDummyRandomListViews(_ qty: Int = 10) -> [UIView] {
        var views = [UIView]()
        
        for _ in 0..<qty {
            let view = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 50).isActive = true
            view.backgroundColor = UIColor.random
            views.append(view)
        }
        
        return views
    }
    
    private func createDummyStackView(_ views: [UIView]) -> UIView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        return stackView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("will appear animated: \(animated)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("did appear animated: \(animated)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("dissapear animated: \(animated)")
    }

}

private extension UIColor {
    static var random: UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

private extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
