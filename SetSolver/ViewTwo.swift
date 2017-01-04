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
        cardsArr[button] = selection
        destViewController.startup = false
        destViewController.cardsArr = cardsArr
        destViewController.button = button
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
        let arr = [pickerData[0][currRow[0]].characters.first!,
                                pickerData[1][currRow[1]].characters.first!,
                                pickerData[2][currRow[2]].characters.first!,
                                pickerData[3][currRow[3]].characters.first!]
        selection = arr.map({"\($0)"}).joined(separator: "")
    }
}
