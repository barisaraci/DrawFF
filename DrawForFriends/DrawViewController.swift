//
//  DrawViewController.swift
//  DrawForFriends
//
//  Created by Baris Araci on 4/30/17.
//  Copyright © 2017 Baris Araci. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController {
    
    var userId : String = ""
    
    var lastPoint = CGPoint.zero
    var swiped = false
    
    var red:CGFloat = 0.0
    var green:CGFloat = 0.0
    var blue:CGFloat = 0.0
    var brushSize:CGFloat = 3.0
    var opacityValue:CGFloat = 1.0
    var isDrawing = true
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    @IBOutlet weak var buttonDone: UIButton!
    @IBOutlet weak var buttonClean: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        userId = (tabBarController as! HomeViewController).userId
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onClickDone(_ sender: Any) {
        if (imageView.image != nil) {
            buttonDone.isHidden = true
            buttonClean.isHidden = true
            progressBar.startAnimating()
            sendImage()
        }
    }
    
    func sendImage() {
        /*let parameters = ["userId": "test"] // MULTI PART REQUEST
        let boundary = generateBoundaryString()
        let url = URL(string: "http://www.barisaraci.com/drawff/query.php?action=postImage")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createRequestBodyWith(parameters: parameters, filePathKey: "file", boundary: boundary)*/
        
        let image = UIImageJPEGRepresentation(imageView.image!, 0.5)?.base64EncodedString()
        let json: [String: Any] = ["userId": userId, "image": image!]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://www.barisaraci.com/drawff/query.php?action=post")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                DispatchQueue.main.async {
                    self.buttonDone.isHidden = false
                    self.buttonClean.isHidden = false
                    self.progressBar.stopAnimating()
                    
                    self.showToast(message: "There is a problem connecting to server")
                }
                return
            }
            
            let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
            self.processResponse(result: response)
        }
        
        task.resume()
    }
    
    func processResponse(result: String) {
        let response = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        DispatchQueue.main.async {
            self.buttonDone.isHidden = false
            self.buttonClean.isHidden = false
            self.progressBar.stopAnimating()
            if (response == "1") {
                self.showToast(message: "You have successfully posted the image")
                self.imageView.image = nil
            } else {
                self.showToast(message: "An error has occurred during posting")
            }
        }
        
        if (response == "1") {
            let timer = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: timer) {
                self.tabBarController?.selectedIndex = 0;
            }
        }
    }
    
    // MULTI PART REQUEST
    
    /*func createRequestBodyWith(parameters: [String: String], filePathKey: String, boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(string: "\(value)\r\n")
        }
        
        let mimetype = "image/jpg"
        let defFileName = "test.jpg"
        let imageData = UIImageJPEGRepresentation(imageView.image!, 1)
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(defFileName)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageData!)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }*/
    
    @IBAction func onClickClean(_ sender: Any) {
        self.imageView.image = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    func drawLines(fromPoint:CGPoint,toPoint:CGPoint) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushSize)
        context?.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: opacityValue).cgColor)
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            drawLines(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLines(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }
    
}
