//
//  ViewController.swift
//  MessageBox
//
//  Created by Raysharp666 on 2020/12/10.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("ready")
//        view.backgroundColor = .red
    }

    var count = 0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        count += 1
        MessageBox.default.show(message: "message \(count)")
    }
}

