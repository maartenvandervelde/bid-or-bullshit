//
//  SlotCondition.swift
//  actr
//
//  Created by Niels Taatgen on 3/21/15.
//  Copyright (c) 2015 Niels Taatgen. All rights reserved.
//

import Foundation

struct SlotCondition: CustomStringConvertible {
    let model: ModelPlayer
    let slot: String
    let value: Value
    let op: String?
    
    var description: String {
        get {
            let op2 = (op != nil ? op! : " ")
            return "    \(op2) \(slot) \(value)"
        }
    }
    
init(op: String?, slot: String, value: Value, model: ModelPlayer) {
    self.model = model
    self.value = value
    self.slot = slot
    self.op = op
    }
    
    func opTest(op: String?, val1: Double, val2: Double) -> Bool {
        if op == nil {
            return val1 == val2
        }
        switch op! {
            case "-": return val1 != val2
            case ">": return val1 <= val2
            case "<": return val1 >= val2
            case ">=": return val1 < val2
            case "<=": return val1 > val2
        default: return false
        }
    }
    
    func opTest(op: String?, val1: String, val2: String) -> Bool {
      //  println("Testing \(op) on \(val1) and \(val2)")
        let numval1 = NumberFormatter().number(from: val1)?.doubleValue
        let numval2 = NumberFormatter().number(from: val2)?.doubleValue
        if numval1 != nil && numval2 != nil {
            return opTest(op: op, val1: numval1!, val2: numval2!)
        }
        if op == nil {
//            println("Result equality test between \(val1) and \(val2)")
            return val1 == val2
        } else {
            return val1 != val2
        }
    }
}

