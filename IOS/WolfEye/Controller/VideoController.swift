//
//  VideoController.swift
//  WolfEye
//
//  Created by Object Yan on 2018/4/18.
//  Copyright © 2018年 Object Yan. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoController2: UIViewController , AVCaptureFileOutputRecordingDelegate {
    let captureSession = AVCaptureSession()
    let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
    let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    let fileOutput = AVCaptureMovieFileOutput()
    var startButton, stopButton : UIButton!
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoInput = try! AVCaptureDeviceInput(device: self.videoDevice!)
        self.captureSession.addInput(videoInput)
        let audioInput = try! AVCaptureDeviceInput(device: self.audioDevice!)
        self.captureSession.addInput(audioInput);
        
        self.captureSession.addOutput(self.fileOutput)

        let videoLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
        
        self.setupButton()
        
        self.captureSession.startRunning()
    }
    
    func setupButton(){
        self.startButton = UIButton(frame: CGRect(x:0,y:0,width:120,height:50))
        self.startButton.backgroundColor = UIColor.red
        self.startButton.layer.masksToBounds = true
        self.startButton.setTitle("Start", for: .normal)
        self.startButton.layer.cornerRadius = 20.0
        self.startButton.layer.position = CGPoint(x:self.view.bounds.width/2 - 70,
                                                  y:self.view.bounds.height-50)
        self.startButton.addTarget(self, action: #selector(onClickStartButton(_:)),
                                   for: .touchUpInside)
        
        self.stopButton = UIButton(frame: CGRect(x:0,y:0,width:120,height:50))
        self.stopButton.backgroundColor = UIColor.gray
        self.stopButton.layer.masksToBounds = true
        self.stopButton.setTitle("Stop", for: .normal)
        self.stopButton.layer.cornerRadius = 20.0
        
        self.stopButton.layer.position = CGPoint(x: self.view.bounds.width/2 + 70,
                                                 y:self.view.bounds.height-50)
        self.stopButton.addTarget(self, action: #selector(onClickStopButton(_:)),
                                  for: .touchUpInside)
        
        self.view.addSubview(self.startButton)
        self.view.addSubview(self.stopButton)
    }
    
    @objc func onClickStartButton(_ sender: UIButton){
        if !self.isRecording {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                            .userDomainMask, true)
            let documentsDirectory = paths[0] as String
            let filePath = "\(documentsDirectory)/temp.mp4"
            NSLog(filePath)
            let fileURL = URL(fileURLWithPath: filePath)
            fileOutput.startRecording(to: fileURL, recordingDelegate: self)
            self.isRecording = true
            self.changeButtonColor(target: self.startButton, color: .gray)
            self.changeButtonColor(target: self.stopButton, color: .red)
        }
    }
    
    @objc func onClickStopButton(_ sender: UIButton){
        if self.isRecording {
            fileOutput.stopRecording()
            self.isRecording = false
            self.changeButtonColor(target: self.startButton, color: .red)
            self.changeButtonColor(target: self.stopButton, color: .gray)
        }
    }
    
    func changeButtonColor(target: UIButton, color: UIColor){
        target.backgroundColor = color
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {
        var message:String!
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }, completionHandler: { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                message = "Success!"
            } else{
                message = "Failed：\(error!.localizedDescription)"
            }
            
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: message, message: nil,
                                                        preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Sure", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
}
