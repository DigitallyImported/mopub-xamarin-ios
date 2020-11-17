//
//  QRCodeCameraInterfaceViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import AVFoundation

class QRCodeCameraInterfaceViewController: UIViewController {
    
    static let defaultMediaType = AVMediaType.video
    
    /**
     This view encapsulates the camera feed.
     */
    @IBOutlet weak var cameraFeedView: UIView!
    
    /**
     The AVCaptureSession object used in capturing the camera feed.
     */
    let captureSession: AVCaptureSession
    
    /**
     The `AVCaptureVideoPreviewLayer` object used to display the camera feed. `AVCaptureVideoPreviewLayer` subclasses
     `CALayer`, and `videoPreviewLayer` is attached to `cameraFeedView` by `setUpCamera()`.
     */
    let videoPreviewLayer: AVCaptureVideoPreviewLayer
    
    /**
     The dispatch queue used for `metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)` delegate method calls
     */
    let cameraDispatchQueue = DispatchQueue(label: "Camera Dispatch Queue")
    
    /**
     The shared app delegate. This is used to access deep linking functionality contained in app delegate when
     `metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)` is called.
     */
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    // Always leave the status bar hidden because this is a fullscreen camera feed.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Lock to portrait. While the camera feed view will not rotate with the phone, the camera feed will rotate
    // with the phone, and QR codes will read regardless of orientation.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    required init?(coder aDecoder: NSCoder) {
        captureSession = AVCaptureSession()
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start setting up the camera feed
        requestCameraAccess(authorized: setUpCamera, denied: {
            self.dismissCamera(completion: nil)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the camera feed layer when autolayout kicks in
        layoutVideoPreviewLayer()
    }
    
    /**
     When the close button is pressed, dismiss the camera.
     */
    @IBAction func closeButtonAction(_ sender: Any) {
        dismissCamera(completion: nil)
    }
    
    /**
     If needed, requests access to camera, and then calls the `authorized` block or the `denied` block depending on
     whether access was granted or denied. If access has already been granted or denied, `authorized` or `denied` are
     called immediately.
     */
    fileprivate func requestCameraAccess(authorized: (() -> Void)?, denied: (() -> Void)?) {
        // Call `authorized` block if access has already been authorized
        if AVCaptureDevice.authorizationStatus(for: QRCodeCameraInterfaceViewController.defaultMediaType) == .authorized {
            authorized?()
            return
        }
        
        // Call `denied` block if access has already been denied
        if AVCaptureDevice.authorizationStatus(for: QRCodeCameraInterfaceViewController.defaultMediaType) == .denied {
            denied?()
            return
        }
        
        // If access is `notDetermined`, request access
        guard AVCaptureDevice.authorizationStatus(for: QRCodeCameraInterfaceViewController.defaultMediaType) == .notDetermined else {
            return
        }
        
        AVCaptureDevice.requestAccess(for: QRCodeCameraInterfaceViewController.defaultMediaType) { granted in
            DispatchQueue.main.async {
                if granted {
                    authorized?()
                } else {
                    denied?()
                }
            }
        }
    }
    
    /**
     Starts up the camera. If the camera cannot be set up successfully, `dismissCamera` is called.
     */
    fileprivate func setUpCamera() {
        // Get the default video capture device object
        guard let captureDevice = AVCaptureDevice.default(for: QRCodeCameraInterfaceViewController.defaultMediaType) else {
            dismissCamera(completion: nil)
            return
        }
        
        // Make an input stream with the capture device
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            dismissCamera(completion: nil)
            return
        }
        // Add the input to the capture session
        captureSession.addInput(input)
        
        // Make an output stream to capture QR codes
        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: cameraDispatchQueue)
        output.metadataObjectTypes = [.qr]
        
        // Set up the video preview layer in the camera feed view
        videoPreviewLayer.videoGravity = .resizeAspectFill
        layoutVideoPreviewLayer()
        cameraFeedView.layer.addSublayer(videoPreviewLayer)
        
        // Start the capture session
        captureSession.startRunning()
    }
    
    /**
     Lays out the `videoPreviewLayer` layer within `cameraFeedView`
     */
    fileprivate func layoutVideoPreviewLayer() {
        videoPreviewLayer.frame = cameraFeedView.bounds
    }
    
    /**
     Ends the capture session if a capture session is running, then dismisses the view controller.
     - Parameter completion: completion closure called after the view controller dismisses.
     */
    fileprivate func dismissCamera(completion: (() -> Void)?) {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        dismiss(animated: true, completion: completion)
    }

}

extension QRCodeCameraInterfaceViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        for metadataObject in metadataObjects {
            // We do not care about metadata objects that cannot be converted to URLs or that are not QR codes, and we
            // do not care about URLs that cannot be validated into ad units.
            guard let metadataObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let urlString = metadataObject.stringValue,
                let url = URL(string: urlString),
                let adUnit = AdUnit(url: url),
                let appDelegate = appDelegate,
                metadataObject.type == .qr else {
                continue
            }
            
            // If we find a usable URL, open it, close the camera, and break the loop.
            DispatchQueue.main.async {
                self.dismissCamera(completion: {
                    // Open `adUnit` via the same path that deep linking uses
                    _ = appDelegate.openMoPubAdUnit(adUnit: adUnit,
                                                    onto: appDelegate.savedAdSplitViewController,
                                                    shouldSave: true)
                })
            }
            break
        }
    }
    
}
