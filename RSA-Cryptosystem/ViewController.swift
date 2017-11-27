//
//  ViewController.swift
//  RSA-Cryptosystem
//
//  Created by Alex Azarov on 27/11/2017.
//  Copyright © 2017 Alex Azarov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var p: NSTextField!
    @IBOutlet weak var q: NSTextField!
    @IBOutlet weak var d: NSTextField!
    @IBOutlet weak var r_label: NSTextField!
    @IBOutlet weak var euler_label: NSTextField!
    @IBOutlet weak var e_label: NSTextField!
    @IBOutlet weak var msg: NSScrollView!
    @IBOutlet weak var cipher: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func encode(_ sender: Any) {
        r_label.stringValue = "r = \(Int(p.stringValue)! * Int(q.stringValue)!)"
        
    }
}

