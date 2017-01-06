//
//  FirstViewController.swift
//  SimpleImageSliderDemo
//
//  Created by 庞平飞 on 2017/1/5.
//  Copyright © 2017年 PangPingfei. All rights reserved.
//

import UIKit
import SimpleImageSlider

class FirstViewController: UIViewController {

	fileprivate var slider: SimpleImageSlider!
	
	fileprivate var data = [MyData]()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupSlider()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		slider.isEnableAutoSlide = true
		addNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self)
		slider.isEnableAutoSlide = false
	}
	
	@IBAction func reloadButtonOnTouch(_ sender: Any) {
		// if your datasource updated, call this function.
		slider.reloadData()
	}
	
}


private extension FirstViewController {
	
	func setupSlider() {
		// prepare for dataSource
		for i in 1...3 {
			if let image = UIImage(named: "\(i)") {
				data.append(MyData(id: "\(i)", image: image, imageUrl: nil))
			} else {
				break
			}
		}
		
		// init a slider
		let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/2)
		slider = SimpleImageSlider(frame: frame, dateSource: self, delegate: self)
		
		// setup slider's pageControl if necessary
		slider.currentPageIndicatorColor = nil //.black
		slider.pageIndicatorColor = nil //.gray
		slider.hidePageControlForSinglePage = true
		
		// setup slider's delegate and dateSource, if you use init(frame) func.
		//		slider.delegate = self
		//		slider.dataSource = self
		
		// add to your view
		self.view.addSubview(slider)

		// if you want to stop or start sliding automatic, set isEnableAutoSlide.
		//		slider.isEnableAutoSlide = false
	}
	
	func addNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
	}
}


extension FirstViewController {
	
	func appDidBecomeActive(_ notify: Notification) {
		slider.isEnableAutoSlide = true
	}
	
	func appWillResignActive(_ notify: Notification) {
		slider.isEnableAutoSlide = false
	}

}



// MARK: SimpleImageSliderDelegate

extension FirstViewController: SimpleImageSliderDataSource {
	
	func simpleImageSlider(_ imageSlider: SimpleImageSlider) -> [SimpleImageSliderData] {
		return data
	}
	
}

// MARK: SimpleImageSliderDelegate

extension FirstViewController: SimpleImageSliderDelegate {
	
	func simpleImageSlider(_ imageSlider: SimpleImageSlider, didTouchImageAt imageSliderData: SimpleImageSliderData) {
		// do what your want to do
		let msg = "simpleImageSlider didTouchImageAt \((imageSliderData as! MyData).id!)"
		print(msg)
//		UIAlertView(title: "Tip", message: msg, delegate: nil, cancelButtonTitle: "OK").show()
		performSegue(withIdentifier: "ToNewViewController", sender: nil)
	}
	
}

// Your own class
struct MyData {
	var id: String?
	var image: UIImage?
	var imageUrl: String?
}

extension MyData: SimpleImageSliderData {
	public func setImage(for imageView: UIImageView) {
		imageView.image = self.image
		// in this func you can also load a network image
	}
}


