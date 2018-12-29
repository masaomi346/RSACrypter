//
//  ViewController.swift
//  RSACrypter
//
//  Created by tsit.st2 on 2018/07/12.
//  Copyright © 2018年 s162164. All rights reserved.
//

import UIKit
import Foundation
import BigInt

class ViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    
    var p:BigInt = 0
    var q:BigInt = 0
    var r:BigInt = 0
    
    var sample:String = "11111"
    
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var textView2: UITextView!
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textView1.delegate = self
        textView2.delegate = self
        textView1.text = ""
        textView2.text = ""
        p = PrimeNumber(bit: 512)
        q = PrimeNumber(bit: 512)
        r = PrimeNumber(bit: 512)
        while true {
            if CheckCrypt(p: p, q: q, r: r) {
                break
            } else {
                p = PrimeNumber(bit: 512)
                q = PrimeNumber(bit: 512)
                r = PrimeNumber(bit: 512)
            }
        }
        textField1.text = String(p)
        textField2.text = String(q)
        textField3.text = String(r)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //暗号ボタンを押した時の処理
    @IBAction func Encrypt(_ sender: UIButton) {
        let pq:BigInt = p * q
        let crypt:BigInt = Mod(num: BigInt(textView1.text)!, exp: BigInt(textField3.text!)!, a: pq)
        textView2.text = String(crypt)
    }
    
    //復号ボタンを押した時の処理
    @IBAction func Decrypt(_ sender: UIButton) {
        let key:BigInt = privateKey(a: BigInt(textField1.text!)!, b: BigInt(textField2.text!)!, c: BigInt(textField3.text!)!)
        let pq:BigInt = p * q
        let crypt:BigInt = Mod(num: BigInt(textView2.text)!, exp: key, a: pq)
        textView1.text = String(crypt)
    }
    
    //生成ボタンを押した時の処理
    @IBAction func Generate(_ sender: UIButton) {
        p = PrimeNumber(bit: 512)
        q = PrimeNumber(bit: 512)
        r = PrimeNumber(bit: 512)
        while true {
            if CheckCrypt(p: p, q: q, r: r) {
                break
            } else {
                p = PrimeNumber(bit: 512)
                q = PrimeNumber(bit: 512)
                r = PrimeNumber(bit: 512)
            }
        }
        textField1.text = String(p)
        textField2.text = String(q)
        textField3.text = String(r)
    }
    
    //素数生成
    func PrimeNumber(bit: Int) -> BigInt {
        while true {
            var random = BigUInt.randomInteger(withExactWidth: bit)
            random |= BigUInt(1)
            if random.isPrime() {
                return BigInt(random)
            }
        }
    }
    
    //最小公倍数の計算
    func Lcm(a: BigInt, b: BigInt) -> BigInt {
        var i:BigInt = a
        var j:BigInt = b
        var c:BigInt
        let ij:BigInt = i * j
        while i % j != 0 {
            c = j
            j = i % j
            i = c
        }
        return ij / j
    }
    
    //べき乗計算
    func Mod(num: BigInt, exp: BigInt, a: BigInt) -> BigInt {
        var res:BigInt = 1
        var number:BigInt = num
        var e:BigInt = exp
        while e > 0 {
            if (e & 1) > 0 {
                res = (res * number) % a
            }
            number = (number * number) % a
            e >>= 1
        }
        return res
    }
    
    //秘密鍵生成
    func privateKey(a: BigInt, b: BigInt, c: BigInt) -> BigInt {
        let lcm = Lcm(a: a - 1, b: b - 1)
        var a1:BigInt = 1
        var b1:BigInt = 0
        var c1:BigInt = lcm
        var a2:BigInt = 0
        var b2:BigInt = 1
        var c2:BigInt = c
        var a3:BigInt
        var b3:BigInt
        var c3:BigInt
        var d:BigInt = 1
        while c2 > 0 {
            d = BigInt(c1 / c2)
            a3 = a1 - d * a2
            b3 = b1 - d * b2
            c3 = c1 - d * c2
            a1 = a2
            b1 = b2
            c1 = c2
            a2 = a3
            b2 = b3
            c2 = c3
        }
        return (a1 > b1) ? a1 : b1
    }
    
    //複合できるか確認
    func CheckCrypt(p: BigInt, q: BigInt, r: BigInt) -> Bool {
        let pq:BigInt = p * q
        var crypt:BigInt = Mod(num: BigInt(sample)!, exp: r, a: pq)
        let key:BigInt = privateKey(a: p, b: q, c: r)
        crypt = Mod(num: crypt, exp: key, a: pq)
        if String(crypt) == sample {
            return true
        }
        return false
    }
    
    //textFieldでreturnキー押す時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //textViewでreturnキー押す時の処理
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

