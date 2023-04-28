//
//  AllDealApp.swift
//  AllDeal
//
//  Created by Ethan Kim on 2023/04/04.
//

import Foundation
import SwiftUI
import WebKit
import AVFoundation
import Photos

struct WebView: UIViewRepresentable{
    let url: URL
    @Binding var showLoading: Bool
    
    func makeUIView(context: Context) -> some UIView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        webView.allowsBackForwardNavigationGestures = true //history back(loading problem.....)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    //Handle URL scheme TEST.............
    func handleURLScheme(_ url: URL) -> Bool{
        if url.scheme == "kakaologin"{
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url)
            }
            return true
        }
        return false
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(didStart: {
            //showLoading=true
        }, didFinish: {
            //showLoading=false
        })
    }
}

class WebViewCoordinator: NSObject, WKNavigationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var didStart: () -> Void
    var didFinish: () -> Void
    var showImagePicker: (() -> Void)?
    var selectedImage: ((UIImage?) -> Void)?
    
    init(didStart:@escaping () -> Void, didFinish: @escaping () -> Void){
        self.didStart = didStart
        self.didFinish = didFinish
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        didStart()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinish()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        @unknown default:
            completion(false)
        }
    }
    
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                completion(status == .authorized)
            }
        @unknown default:
            completion(false)
        }
    }
    
    func showImagePickerWithPermissionCheck(completion: @escaping (UIImage?) -> Void) {
        checkCameraPermission { granted in
            if granted {
                DispatchQueue.main.async {
                    self.showImagePicker?()
                }
                self.selectedImage = completion
            } else {
                // show an alert to inform the user that camera access is required
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        selectedImage?(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        selectedImage?(nil)
        picker.dismiss(animated: true, completion: nil)
    }
}
