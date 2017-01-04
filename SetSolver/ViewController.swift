//
//  ViewController.swift
//  SetSolver
//
//  Created by Lucy Chai on 12/30/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

import UIKit

class ViewController:  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var i = 0
    var startup = true
    var cardsArr : [String] = []
    
    @IBOutlet weak var row1col1: UIButton!
    @IBOutlet weak var row1col2: UIButton!
    @IBOutlet weak var row1col3: UIButton!
    @IBOutlet weak var row2col1: UIButton!
    @IBOutlet weak var row2col2: UIButton!
    @IBOutlet weak var row2col3: UIButton!
    @IBOutlet weak var row3col1: UIButton!
    @IBOutlet weak var row3col2: UIButton!
    @IBOutlet weak var row3col3: UIButton!
    @IBOutlet weak var row4col1: UIButton!
    @IBOutlet weak var row4col2: UIButton!
    @IBOutlet weak var row4col3: UIButton!
    @IBOutlet weak var hintImg: UIImageView!
    @IBOutlet weak var solutionLabel: UILabel!

    
    var buttons : [UIButton] = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (startup) {
            buttons = [row1col1, row1col2, row1col3, row2col1, row2col2, row2col3, row3col1, row3col2, row3col3, row4col1, row4col2, row4col3]
            OpenCVWrapper.train(UIImage(named: "setgame1"), andImg2: UIImage(named: "SetCards"))
            setupCards(img: UIImage(named:"SetCards2")!)
            setupButtons()
            startup = false
        } else {
            // set up card based on selection
            buttons = [row1col1, row1col2, row1col3, row2col1, row2col2, row2col3, row3col1, row3col2, row3col3, row4col1, row4col2, row4col3]
            setupButtons()
        }
    }
    
    func setupCards(img: UIImage) {
        let cards = OpenCVWrapper.test(img)

        // handle error in detecting cards
        if (cards == "") {
            let alertController = UIAlertController(title: "iOScreator", message:
                "Error in detecting cards", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        cardsArr = (cards?.components(separatedBy: " "))!
        cardsArr.removeLast()
    }
    
    func setupButtons() {
        let minlength = min(cardsArr.count, buttons.count)
        for i in 0..<minlength {
            buttons[i].setImage(UIImage(named: cardsArr[i]), for: UIControlState.normal)
        }
    }

    // helper function to compute combinations of items
    func permute(list: Set<Set<String>>, appendElements: Set<String>) -> Set<Set<String>> {
        var newSet = Set<Set<String>>()
        for elem in list {
            for app in appendElements {
                if (!elem.contains(app)) {
                    newSet.insert(elem.union(Set<String>([app])))
                }
            }
        }
        return newSet
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // show a hint
    @IBAction func hintButton(_ sender: UIButton) {
        let cardSet = Set<String>(cardsArr)
        if (cardSet.count < 12) {
            // there is a duplicate card
            let alertController = UIAlertController(title: "iOScreator", message:
                "There is a duplicate card.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let answers = solve(cardsArr: self.cardsArr)
        
        if (answers.count == 0) {
            hintImg.image = UIImage(named: "none")
        }
        else {
            hintImg.image = UIImage(named: (answers.first?.first)!)
        }
    }
    
    @IBAction func showSolution(_ sender: UIButton) {
        let cardSet = Set<String>(cardsArr)
        if (cardSet.count < 12) {
            // there is a duplicate card
            let alertController = UIAlertController(title: "iOScreator", message:
                "There is a duplicate card.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let answers = solve(cardsArr: self.cardsArr)
        let str : NSMutableString = ""
        for comb in answers{
            for elt in comb {
                str.append(elt + "; ")
            }
            str.append("\n")
        }
        solutionLabel.text = str as String
        
    }
    
    func solve(cardsArr: [String]) -> Set<Set<String>> {
        var set = Set<Set<String>>()
        for card in cardsArr {
            set.insert(Set<String>([card]))
        }
        
        
        let combs1 = permute(list: set, appendElements: Set<String>(cardsArr))
        let combs2 = permute(list: combs1, appendElements: Set<String>(cardsArr))
        
        
        var answers = Set<Set<String>>()
        for comb in combs2 {
            let arr = Array(comb)
            let card1 = arr[0].characters.map { String($0) }
            let card2 = arr[1].characters.map { String($0) }
            let card3 = arr[2].characters.map { String($0) }
            
            for i in 0..<4 {
                let features = Set([card1[i], card2[i], card3[i]])
                if features.count == 2 {
                    break;
                }
                if i == 3 {
                    answers.insert(comb)
                }
            }
        }
        return answers
    }
    
    // transfer data to picker view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destViewController : ViewTwo = segue.destination as! ViewTwo
        for i in 0..<buttons.count {
            if (sender as? UIButton === buttons[i]) {
                destViewController.button = i
            }
        }
        destViewController.cardsArr = cardsArr;
    }
    
    @IBAction func openCameraPicker(_ sender: UIButton) {
        self.launchCameraPicker()
    }
    
    @IBAction func openImagePicker(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func launchCameraPicker() {
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerControllerCameraDevice.rear) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // called after image has been picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String :
        Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            //let img = UIImage(named: "Image")
            let img = pickedImage
            
            // run OCR in background
            backgroundThread(background: {
                    self.setupCards(img: img)
                },
                completion: {
                    LoadingIndicatorView.hide()
                    self.setupButtons()
                    
            })
            LoadingIndicatorView.show()
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    // create a background thread and callback
    func backgroundThread(background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        
        DispatchQueue.global(qos: .background).async {
            if(background != nil){ background!(); }
            
            DispatchQueue.main.async {
                if(completion != nil){ completion!(); }
            }
        }
    }
    
    
}

