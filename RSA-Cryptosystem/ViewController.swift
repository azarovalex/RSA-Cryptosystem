//
//  ViewController.swift
//  RSA-Cryptosystem
//
//  Created by Alex Azarov on 27/11/2017.
//  Copyright © 2017 Alex Azarov. All rights reserved.
//

import Cocoa

func dialogError(question: String, text: String) {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .critical
    alert.addButton(withTitle: "OK")
    alert.runModal()
}

func browseFile() -> String {
    let dialog = NSOpenPanel();
    dialog.title                   = "Choose a file";
    dialog.showsResizeIndicator    = true;
    dialog.showsHiddenFiles        = false;
    dialog.canCreateDirectories    = true;
    dialog.allowsMultipleSelection = false;
    
    if (dialog.runModal() == NSApplication.ModalResponse.OK) {
        let result = dialog.url
        
        if (result != nil) {
            return result!.path
        }
    } else { return "" }
    return ""
}

func isPrime(_ number: Int) -> Bool {
    return number > 1 && !(2..<number).contains { number % $0 == 0 }
}


class ViewController: NSViewController {

    @IBOutlet weak var p_textbox: NSTextField!
    @IBOutlet weak var q_textbox: NSTextField!
    @IBOutlet weak var d_textbox: NSTextField!
    @IBOutlet weak var r_label: NSTextField!
    @IBOutlet weak var euler_label: NSTextField!
    @IBOutlet weak var e_label: NSTextField!
    
    @IBOutlet var msg: NSTextView!
    @IBOutlet var cipher: NSTextView!
    
    var filePath = ""
    
    var msg_bytes = [UInt8]()
    var ciphered_bytes = [Int]()
    var p = 0
    var q = 0
    var e = 0
    var d = 0
    var r = 0
    var euler = 0
    
    func EncodeMsg(exponent: Int) {
        ciphered_bytes = msg_bytes.map { Int($0) }
        for index in 0..<ciphered_bytes.count {
            ciphered_bytes[index] = fast_exp(a: ciphered_bytes[index], z: e, n: r)
        }
        cipher.string = ""
        for byte in ciphered_bytes {
            cipher.string.append(String(byte) + " ")
        }
    }
    
    func DecodeMsg(exponent: Int) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func inverse(n: Int, modulus: Int) -> Int{
        var a = n, b = modulus
        var x = 0, y = 1, x0 = 1, y0 = 0, q = 0, temp = 0
        while (b != 0) {
                q = a / b
                temp = a % b
                a = b
                b = temp
                temp = x; x = x0 - q * x; x0 = temp;
                temp = y; y = y0 - q * y; y0 = temp;
        }
        if(x0 < 0) { x0 += modulus }
        return x0
    }
    
    @IBAction func Encode(_ sender: NSButton) {
        switch sender.tag {
        case 0:
            guard msg.string.lengthOfBytes(using: .ascii) > 0 else {
                dialogError(question: "Error!", text: "Please, open a file to encipher.")
                return
            }
        case 1:
            guard cipher.string.lengthOfBytes(using: .ascii) > 0 else {
                dialogError(question: "Error!", text: "Please, open a file to decipher.")
                return
            }
        default:
            return
        }
        
        guard Int(p_textbox.stringValue) != nil && Int(p_textbox.stringValue) != nil else {
            dialogError(question: "Error!", text: "P is not a prime number.")
            return
        }
        p = Int(p_textbox.stringValue)!
        
        guard Int(q_textbox.stringValue) != nil && isPrime(Int(q_textbox.stringValue)!) else {
            dialogError(question: "Error!", text: "Q is not a prime number.")
            return
        }
        q = Int(q_textbox.stringValue)!
        
        guard Int(d_textbox.stringValue) != nil else {
            dialogError(question: "Error!", text: "D is not a number.")
            return
        }
        d = Int(d_textbox.stringValue)!
        
        euler = (p - 1) * (q - 1)
        euler_label.stringValue = "Euler(r) = \(euler)"
        r = p * q
        r_label.stringValue = "r = \(r)"
        e = inverse(n: d, modulus: euler)
        e_label.stringValue = "e = \(e)"
        switch sender.tag {
        case 0:
            EncodeMsg(exponent: e)
            let pointer = UnsafeBufferPointer(start:ciphered_bytes, count:ciphered_bytes.count)
            let data = Data(buffer:pointer)
            try! data.write(to: URL(fileURLWithPath: filePath + ".ciphered"))
        case 1:
            DecodeMsg(exponent: d)
            
            
        default:
            break
        }
        
    }
    
    // a^z mod n
    func fast_exp(a: Int ,z: Int, n: Int) -> Int {
        var a1 = a
        var z1 = z
        var x = 1
        while (z1 != 0) {
            while ((z1 % 2) == 0) {
                z1 = z1 / 2
                a1 = (a1*a1) % n
            }
        z1 = z1 - 1
        x = (x * a1) % n
        }
        return x
    }
    
    @IBAction func OpenFile(_ sender: Any) {
        filePath = browseFile()
        
        // Represent the file as a sequence of numbers
        if let data = NSData(contentsOfFile: filePath) {
            var buffer = [UInt8](repeating: 0, count: data.length)
            data.getBytes(&buffer, length: data.length)
            msg_bytes = buffer
        }
        
        msg.string = ""
        for byte in msg_bytes {
            msg.string.append(String(byte) + " ")
        }
    }
    
    @IBAction func OpenCipheredFile(_ sender: Any) {
        let cipherPath = browseFile()
        
        if let data = NSData(contentsOfFile: cipherPath) {
            var buffer = [Int](repeating: 0, count: data.length / 8)
            data.getBytes(&buffer, length: data.length)
            ciphered_bytes = buffer
        }
        
        cipher.string = ""
        for byte in ciphered_bytes {
            cipher.string.append(String(byte) + " ")
        }
    }
    
}

