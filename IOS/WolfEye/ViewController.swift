//
//  ViewController.swift
//  WolfEye
//
//  Created by Object Yan on 2018/4/16.
//  Copyright © 2018年 Object Yan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(OpenCVWapper.openCVVersion())
        
        var img = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width,
                                            height: self.view.frame.height))
        img.image = UIImage(named: "launch");
        self.view.addSubview(img)
        
        OpenCVWapper.imageByCVMat(img)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

