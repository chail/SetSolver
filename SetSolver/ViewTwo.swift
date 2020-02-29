//
//  ViewTwo.swift
//  SetSolver
//
//  Created by Lucy Chai on 1/2/17.
//  Copyright © 2017 Lucy Chai. All rights reserved.
//

import Foundation
import UIKit



class ViewTwo:  UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    let pickerData = [["1", "2", "3"],
                      ["oval", "squiggle", "diamond"],
                      ["red", "green", "violet"],
                      ["fill", "open", "hatch"]]

    var selection = "1orf"
    var cardsArr : [String] = []
    var button = 0
    
    @IBOutlet weak var randomize: UIButton!
    @IBOutlet weak var select: UIButton!
    
    var currRow = [0, 0, 0, 0]

    override func viewDidLoad() {
        // Connect data:
        picker.delegate = self
        picker.dataSource = self
        
        self.picker.reloadAllComponents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destViewController : ViewController = segue.destination as! ViewController
        destViewController.startup = false
        if (sender as? UIButton == select) {
            self.cardsArr[button] = selection
        } else {
            var cards = Set<String>()
            while (cards.count < 12) {
                for i in 0..<4 {
                    currRow[i] = Int(arc4random_uniform(3))
                }
                let arr = [pickerData[0][currRow[0]].first!,
                           pickerData[1][currRow[1]].first!,
                           pickerData[2][currRow[2]].first!,
                           pickerData[3][currRow[3]].first!]
                let card = arr.map({"\($0)"}).joined(separator: "")
                cards.insert(card)
            }
            self.cardsArr = Array(cards)
        }
        destViewController.cardsArr = self.cardsArr
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currRow[component] = row
        let arr = [pickerData[0][currRow[0]].first!,
                                pickerData[1][currRow[1]].first!,
                                pickerData[2][currRow[2]].first!,
                                pickerData[3][currRow[3]].first!]
        selection = arr.map({"\($0)"}).joined(separator: "")
    }

}
