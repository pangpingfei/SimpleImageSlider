//
//  NewViewController.swift
//  SimpleImageSlider
//
//  Created by 庞平飞 on 2017/1/6.
//  Copyright © 2017年 PangPingfei. All rights reserved.
//

import UIKit
import SimpleImageSlider

class NewViewController: UIViewController {
	
	deinit {
		debugPrint("NewViewController deinit")
		slider.isEnableAutoSlide = false
	}
	
	fileprivate weak var slider: SimpleImageSlider!
	
	fileprivate var data = [MyData]()

	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupSlider()
	}
	
	
	@IBAction func dismissButtonOnTouch(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}


private extension NewViewController {
	
	func setupSlider() {
		// prepare for dataSource
		for i in 4...6 {
			if let image = UIImage(named: "\(i)") {
				data.append(MyData(id: "\(i)", image: image, imageUrl: nil))
			} else {
				break
			}
		}
		
		// init a slider
		let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/2)
		slider = SimpleImageSlider(frame: frame)
//		slider = SimpleImageSlider(frame: frame, dateSource: self, delegate: self)
		
		// setup slider's pageControl if necessary
		slider.currentPageIndicatorColor = .blue
		slider.pageIndicatorColor = .gray
		slider.hidePageControlForSinglePage = true
		
		// setup slider's delegate and dateSource, if you use init(frame) func.
		slider.delegate = self
		slider.dataSource = self
		
		// add to your view
		self.view.addSubview(slider)
		
		// if you want to stop or start sliding automatic, set isEnableAutoSlide.
		slider.isEnableAutoSlide = true
	}
	

}



// MARK: SimpleImageSliderDelegate

extension NewViewController: SimpleImageSliderDataSource {
	
	func simpleImageSlider(_ imageSlider: SimpleImageSlider) -> [SimpleImageSliderData] {
		return data
	}
	
}

// MARK: SimpleImageSliderDelegate

extension NewViewController: SimpleImageSliderDelegate {
	
	func simpleImageSlider(_ imageSlider: SimpleImageSlider, didTouchImageAt imageSliderData: SimpleImageSliderData) {
		// do what your want to do
		let msg = "simpleImageSlider didTouchImageAt \((imageSliderData as! MyData).id!)"
		print(msg)
		UIAlertView(title: "Tip", message: msg, delegate: nil, cancelButtonTitle: "OK").show()
	}
	
}


