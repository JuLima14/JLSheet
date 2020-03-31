//
//  DummyViewController.swift
//  JLSheet
//
//  Created by Julian Lima on 30/01/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

class DummyStackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        let stackView = createDummyStackView(createDummyRandomListViews())
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func createDummyRandomListViews(_ qty: Int = 50) -> [UIView] {
        var views = [UIView]()
        
        for _ in 0..<qty {
            let view = UIView(frame: .zero)
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTap(_:))))
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 50).isActive = true
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
            view.backgroundColor = UIColor.random
            views.append(view)
        }
        
        return views
    }
    
    private func createDummyStackView(_ views: [UIView]) -> UIView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        return stackView
    }
    
    @objc private func didTap(_ gestureRecognizer: UITapGestureRecognizer) {
        sheetViewController?.pushViewController(DummyStackViewController(), animated: true)
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
