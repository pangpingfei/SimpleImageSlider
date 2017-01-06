//
//  SimpleImageSlider.swift
//  SimpleImageSlider
//
//  Created by 庞平飞 on 2017/1/5.
//  Copyright © 2017年 PangPingfei. All rights reserved.
//

import Foundation

// MARK: SimpleImageSliderData
public protocol SimpleImageSliderData {
	func setImage(for imageView: UIImageView)
}

// MARK: SimpleImageSliderDataSource
public protocol SimpleImageSliderDataSource: class {
	func simpleImageSlider(_ imageSlider: SimpleImageSlider) -> [SimpleImageSliderData]
}

// MARK: SimpleImageSliderDelegate
public protocol SimpleImageSliderDelegate: class {
	func simpleImageSlider(_ imageSlider: SimpleImageSlider, didTouchImageAt imageSliderData: SimpleImageSliderData)
}
public extension SimpleImageSliderDelegate {
	func simpleImageSlider(_ imageSlider: SimpleImageSlider, didTouchImageAt imageSliderData: SimpleImageSliderData) { }
}



fileprivate let cellIdentifier = "SimpleImageSliderCell"


// MARK: SimpleImageSlider

public class SimpleImageSlider: UIView {

	deinit {
		removeSlideTimer()
		#if DEBUG
			debugPrint("SimpleImageSlider deinit")
		#endif
	}


	// MARK: public properties

	public weak var dataSource: SimpleImageSliderDataSource? {
		didSet { reloadData() }
	}
	public weak var delegate: SimpleImageSliderDelegate?

	public var pageIndicatorColor: UIColor? {
		set { pageControl.pageIndicatorTintColor = newValue }
		get { return pageControl.pageIndicatorTintColor }
	}
	public var currentPageIndicatorColor: UIColor? {
		set { pageControl.currentPageIndicatorTintColor = newValue }
		get { return pageControl.pageIndicatorTintColor }
	}

	public var hidePageControlForSinglePage: Bool {
		set { pageControl.hidesForSinglePage = newValue }
		get { return pageControl.hidesForSinglePage }
	}

	// default is false, if you change to true, you must set it false when you want to deinit it.
	public var isEnableAutoSlide = false {
		didSet { if isEnableAutoSlide { addSlideTimer() } else { removeSlideTimer() } }
	}

	public var slideTimeInterval: TimeInterval = 3 // default is 3


	// MARK: private properties

	fileprivate var collectionViewData: [SimpleImageSliderData]? // Stored processed data, if reload, set it nill first.
	fileprivate var data: [SimpleImageSliderData] {
		if let data = collectionViewData { return data }
		if let d = dataSource?.simpleImageSlider(self) { return processDataSource(d) } else {
			debugPrint("SimpleImageSliderDataSource->'func simpleImageSlider(_ imageSlider: SimpleImageSlider) -> [SimpleImageSliderData]' has not been implemented")
			return [SimpleImageSliderData]()
		}
	}

	fileprivate weak var slideTimer: Timer?

	fileprivate lazy var collectionView: UICollectionView = { [unowned self] in
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = UICollectionViewScrollDirection.horizontal
		layout.itemSize = self.frame.size
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0
		let view = UICollectionView(frame: self.frame, collectionViewLayout: layout)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.dataSource = self
		view.isPagingEnabled = true
		view.showsHorizontalScrollIndicator = false
		view.showsVerticalScrollIndicator = false
		view.register(SimpleImageSliderCell.self, forCellWithReuseIdentifier: cellIdentifier)
		self.addSubview(view)
		return view
	}()

	fileprivate lazy var pageControl: UIPageControl = { [unowned self] in
		let view = UIPageControl(frame: CGRect.zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isEnabled = false
		self.addSubview(view)
		return view
	}()


	// MARK: Init

	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupSubviews()
	}
	
	public convenience init(frame: CGRect, dateSource: SimpleImageSliderDataSource, delegate: SimpleImageSliderDelegate?) {
		self.init(frame: frame)
		self.dataSource = dateSource
		self.delegate = delegate
		reloadData()
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}


// MARK: public functions

public extension SimpleImageSlider {

	public func reloadData() {
		collectionViewData = nil
		collectionView.reloadData()
		scrollToFirstPage()
	}

}


// MARK: timer

extension SimpleImageSlider {

	fileprivate func addSlideTimer() {
		if !isEnableAutoSlide { removeSlideTimer(); return }
		if let timer = slideTimer, timer.isValid { return }
		if data.isEmpty { return }
		slideTimer = Timer.scheduledTimer(timeInterval: slideTimeInterval, target: self, selector: #selector(slideTimerAction(timer:)), userInfo: nil, repeats: true)
	}

	fileprivate func removeSlideTimer() {
		guard let timer = slideTimer else { return }
		timer.invalidate()
		slideTimer = nil
	}


	func slideTimerAction(timer: Timer) {
		if !timer.isValid { return }
		if collectionView.contentOffset.y > self.frame.width * 0.5 { return }
		let index = Int(collectionView.contentOffset.x / self.frame.width)
		let nextIndex = index + 1
		let indexPath = IndexPath(item: nextIndex, section: 0)
		collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
	}

}


// MARK: private functions

private extension SimpleImageSlider {

	func setupSubviews() {
		self.addConstraints(nil, "|[collectionView]|", metrics: nil, views: ["collectionView": collectionView])
		self.addConstraints("H", "|[pageControl]|", metrics: nil, views: ["pageControl": pageControl])
		self.addConstraint(with: pageControl, attribute: .bottom)
	}

	func processDataSource(_ data: [SimpleImageSliderData]) -> [SimpleImageSliderData] {
		var d = data
		if !d.isEmpty {
			let firstInfo = d.first!
			let lastInfo = d.last!
			d.insert(lastInfo, at: d.startIndex)
			d.insert(firstInfo, at: d.endIndex)
		}
		self.collectionViewData = d
		return d
	}

	// Scroll to index 1
	func scrollToFirstPage() {
		if data.isEmpty { return }
		let indexPath = IndexPath(item: 1, section: 0)
		collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
		addSlideTimer()
	}

}


// MARK: UICollectionViewDataSource

extension SimpleImageSlider: UICollectionViewDataSource {

	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		pageControl.numberOfPages = data.count - 2
		return data.count
	}

	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! SimpleImageSliderCell
		cell.loadImage(from: data[indexPath.row])
		return cell
	}

}


// MARK: UICollectionViewDelegate

extension SimpleImageSlider: UICollectionViewDelegate {

	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.simpleImageSlider(self, didTouchImageAt: data[indexPath.row])
	}

}


// MARK: UICollectionViewDelegateFlowLayout

extension SimpleImageSlider: UICollectionViewDelegateFlowLayout {

	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
	{
		return CGSize(width: self.frame.width, height: self.frame.height)
	}

}


// MARK: UIScrollViewDelegate

extension SimpleImageSlider: UIScrollViewDelegate {

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {

		let index = Int(scrollView.contentOffset.x / self.frame.width)
		var currentPage = index - 1
		// when scroll to the last index, auto scroll to the first page
		if (index == data.count - 1) {
			let indexPath = IndexPath(item: 1, section: 0)
			collectionView.scrollToItem(at: indexPath, at: .right, animated: false)
			currentPage = 0
		} else if scrollView.contentOffset.x <= 0 { // when scroll to the zero index, auto scroll to the last page
			let indexPath = IndexPath(item: data.count - 2, section: 0)
			collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
			currentPage = data.count - 3
		}
		pageControl.currentPage = currentPage

	}

	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		removeSlideTimer()
	}

	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		addSlideTimer()
	}

}


// MARK: (private) SimpleImageSliderCell

private class SimpleImageSliderCell: UICollectionViewCell {

	fileprivate override var reuseIdentifier: String? { return cellIdentifier }

	fileprivate lazy var imageview: UIImageView = { [unowned self] in
		let view = UIImageView()
		view.contentMode = .scaleAspectFill
		view.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(view)
		return view
	}()

	override init(frame: CGRect) {
		super.init(frame: CGRect.zero)
		setupSubviews()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupSubviews() {
		self.contentView.addConstraints(nil, "|[imageview]|", metrics: nil, views: ["imageview": imageview])
	}

	func loadImage(from data: SimpleImageSliderData) {
		data.setImage(for: imageview)
	}
}



// MARK: - UIView extension

fileprivate extension UIView {

	// direction: "H" or "V", nil -> both
	func addConstraints(_ direction: String?, _ format: String, metrics: [String: Any]?, views: [String: Any]) {
		let noLayoutOptions = NSLayoutFormatOptions(rawValue: 0)
		var cs = [NSLayoutConstraint]()
		if let d = direction {
			cs += NSLayoutConstraint.constraints(withVisualFormat: d + ":" + format, options: noLayoutOptions, metrics: metrics, views: views)
		} else {
			cs += NSLayoutConstraint.constraints(withVisualFormat: "V:" + format, options: noLayoutOptions, metrics: metrics, views: views)
			cs += NSLayoutConstraint.constraints(withVisualFormat: "H:" + format, options: noLayoutOptions, metrics: metrics, views: views)

		}
		self.addConstraints(cs)
	}

	func addConstraint(with view: UIView, attribute: NSLayoutAttribute, relatedBy: NSLayoutRelation = .equal, constant: CGFloat = 0) {
		let constraint = NSLayoutConstraint(item: view, attribute: attribute, relatedBy: relatedBy, toItem: self, attribute: attribute, multiplier: 1, constant: constant)
		self.addConstraint(constraint)
	}
}


