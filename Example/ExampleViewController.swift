//
//  ExampleViewController.swift
//  JLSheet
//
//  Created by Julian Lima on 30/01/2020.
//  Copyright © 2020 Julian Lima. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        title = "JLSHEET"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let button = UIButton(type: .system)
        button.frame = CGRect(origin: .zero, size: CGSize.init(width: 100, height: 100))
        button.setTitle("Test", for: .normal)
        button.addTarget(self, action: #selector(self.presentSheet), for: .touchUpInside)
        
        view.addSubview(button)
        
        button.center = view.center
    }
    
    @objc func presentSheet() {
        let sheet = SheetViewController(rootViewController: DummyStackViewController())
        sheet.modalPresentationStyle = .overCurrentContext
        UIApplication.shared.windows.first?.rootViewController?.present(sheet, animated: false, completion: nil)
    }

}
