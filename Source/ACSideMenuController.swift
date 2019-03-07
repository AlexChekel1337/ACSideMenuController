/*
    v1.1
    Available at https://github.com/AlexChekel1337/ACSideMenuController
*/

import UIKit

//MARK: - ACSideMenuController

class ACSideMenuController: UIViewController {
    
    //MARK: - NotificationCenter support
    
    struct NotificationName {
        static let didOpenMenu = Notification.Name("ACSideMenuController.didOpenMenu")
        static let didCloseMenu = Notification.Name("ACSideMenuController.didCloseMenu")
        static let willChangeState = Notification.Name("ACSideMenuController.willChangeState")
    }
    
    //MARK: - Overrides
    
    @IBInspectable public var bottomViewControllerIdentifier: String?
    @IBInspectable public var bottomViewControllerStoryboardName: String = "Main"
    
    @IBInspectable public var topViewControllerIdentifier: String?
    @IBInspectable public var topViewControllerStoryboardName: String = "Main"
    
    public var animationDuration: TimeInterval = 0.5
    @IBInspectable public var openedMenuInset: CGFloat = 80.0
    @IBInspectable public var shouldRecognizeMultipleGestures: Bool = false
    @IBInspectable public var blocksInteractionWhileOpened: Bool = false
    
    @IBInspectable public var shadowEnabled: Bool = true {didSet {updateShadow()}}
    @IBInspectable public var shadowColor: UIColor = UIColor.black {didSet {updateShadow()}}
    @IBInspectable public var shadowRadius: CGFloat = 10.0 {didSet {updateShadow()}}
    @IBInspectable public var shadowOpacity: Float = 0.5 {didSet {updateShadow()}}
    @IBInspectable public var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {didSet {updateShadow()}}
    
    //MARK: - Properties
    
    private var bottomViewContainer: UIView!
    private var bottomContainerXConstraint: NSLayoutConstraint!
    
    private var topViewContainer: UIView!
    private var topContainerXConstraint: NSLayoutConstraint!
    
    private var stubView: UIView!
    private var stubTapRecognizer: UITapGestureRecognizer!
    private var stubPanRecognizer: UIPanGestureRecognizer!
    
    public var bottomViewController: UIViewController? {get {return bottomVC}}
    private var bottomVC: UIViewController?
    
    public var topViewController: UIViewController? {get {return topVC}}
    private var topVC: UIViewController?
    
    public var gestureRecognizer: UIPanGestureRecognizer {get {return panGestureRecognizer}}
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    public var isMenuOpened: Bool {get {return isSideMenuOpened}}
    private var isSideMenuOpened: Bool = false
    
    //MARK: - Initialization
    
    init(bottomViewController aBottomVC: UIViewController, topViewController aTopVC: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        
        bottomVC = aBottomVC
        topVC = aTopVC
        commonInit()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        print("init() called when using UIStoryboard")
        if topViewControllerIdentifier != nil { print("topVC identifier is \(topViewControllerIdentifier!)") }
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - UIStoryboard workflow
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if bottomViewControllerIdentifier != nil {
            let sbName = bottomViewControllerStoryboardName
            let vcName = bottomViewControllerIdentifier!
            let storyboard = UIStoryboard(name: sbName, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: vcName)
            
            bottomVC = viewController
        }
        
        if topViewControllerIdentifier != nil {
            let sbName = topViewControllerStoryboardName
            let vcName = topViewControllerIdentifier!
            let storyboard = UIStoryboard(name: sbName, bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: vcName)
            
            topVC = viewController
        }
        
        commonInit()
    }
    
    //MARK: - Setup and layout
    
    private func commonInit() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        stubTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleMenu(_:)))
        stubPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        
        bottomViewContainer = UIView()
        bottomViewContainer.backgroundColor = UIColor.clear
        bottomViewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomViewContainer)
        
        let bContainerWidth = NSLayoutConstraint(item: bottomViewContainer, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let bContainerHeight = NSLayoutConstraint(item: bottomViewContainer, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0)
        let bContainerYConstraint = NSLayoutConstraint(item: bottomViewContainer, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        bottomContainerXConstraint = NSLayoutConstraint(item: bottomViewContainer, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        view.addConstraints([bContainerWidth, bContainerHeight, bContainerYConstraint, bottomContainerXConstraint])
        
        topViewContainer = UIView()
        topViewContainer.backgroundColor = UIColor.clear
        topViewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topViewContainer)
        
        let tContainerWidth = NSLayoutConstraint(item: topViewContainer, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let tContainerHeight = NSLayoutConstraint(item: topViewContainer, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0)
        let tContainerYConstraint = NSLayoutConstraint(item: topViewContainer, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        topContainerXConstraint = NSLayoutConstraint(item: topViewContainer, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        view.addConstraints([tContainerWidth, tContainerHeight, tContainerYConstraint, topContainerXConstraint])
        
        stubView = UIView()
        stubView.backgroundColor = UIColor.clear
        stubView.isUserInteractionEnabled = false
        stubView.translatesAutoresizingMaskIntoConstraints = false
        stubView.addGestureRecognizer(stubTapRecognizer)
        stubView.addGestureRecognizer(stubPanRecognizer)
        topViewContainer.addSubview(stubView)
        
        stubView.topAnchor.constraint(equalTo: topViewContainer.topAnchor).isActive = true
        stubView.leftAnchor.constraint(equalTo: topViewContainer.leftAnchor).isActive = true
        stubView.rightAnchor.constraint(equalTo: topViewContainer.rightAnchor).isActive = true
        stubView.bottomAnchor.constraint(equalTo: topViewContainer.bottomAnchor).isActive = true
        
        setBottomViewController(bottomVC)
        setTopViewController(topVC)
        updateShadow()
    }
    
    private func updateShadow() {
        guard let container = topViewContainer else {return}
        
        container.clipsToBounds = false
        
        if shadowEnabled {
            container.layer.shadowPath = UIBezierPath(rect: topViewContainer.bounds).cgPath
            container.layer.shadowColor = shadowColor.cgColor
            container.layer.shadowRadius = shadowRadius
            container.layer.shadowOpacity = shadowOpacity
            container.layer.shadowOffset = shadowOffset
        } else {
            container.layer.shadowPath = nil
            container.layer.shadowColor = nil
            container.layer.shadowRadius = 0.0
            container.layer.shadowOpacity = 0.0
        }
    }
    
    //MARK: Status bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let controller = topVC else {return .default}
        
        return controller.preferredStatusBarStyle
    }
    
    //MARK: - Gesture handling
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        func move() {
            let translation = recognizer.translation(in: view)
            var newCenter = CGPoint(x: topViewContainer.center.x + translation.x, y: topViewContainer.center.y)
            if newCenter.x < view.center.x {
                newCenter = view.center
            }
            topViewContainer.center = newCenter
            
            topContainerXConstraint.constant = newCenter.x - view.center.x
            recognizer.setTranslation(.zero, in: view)
        }
        
        func toggle() {
            let velocity = recognizer.velocity(in: view).x
            
            switch velocity {
            case 1...:
                openMenu()
                break
            case ..<1:
                closeMenu()
                break
            default:
                break
            }
        }
        
        func notifyObserver() {
            let notificationName = ACSideMenuController.NotificationName.willChangeState
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
        
        switch recognizer.state {
        case .began:
            notifyObserver()
            break
        case .changed:
            move()
            break
        case .ended:
            toggle()
            break
        default:
            break
        }
    }
    
    private func openMenu() {
        topContainerXConstraint.constant = (view.center.x * 2) - openedMenuInset
        isSideMenuOpened = true
        
        if blocksInteractionWhileOpened == true {stubView.isUserInteractionEnabled = true}
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            NotificationCenter.default.post(name: ACSideMenuController.NotificationName.didOpenMenu, object: nil)
        }
    }
    
    private func closeMenu() {
        topContainerXConstraint.constant = 0.0
        isSideMenuOpened = false
        
        if blocksInteractionWhileOpened == true {stubView.isUserInteractionEnabled = false}
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            NotificationCenter.default.post(name: NotificationName.didCloseMenu, object: nil)
        }
    }
    
    //MARK: - Actions
    
    public func setBottomViewController(_ viewController: UIViewController?) {
        guard let controller = viewController else {return}
        
        //remove previous bottomVC
        if let previousVC = bottomVC {
            previousVC.willMove(toParent: nil)
            previousVC.removeFromParent()
            previousVC.view.removeFromSuperview()
        }
        
        //add new bottomVC
        addChild(controller)
        bottomViewContainer.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.topAnchor.constraint(equalTo: bottomViewContainer.topAnchor).isActive = true
        controller.view.leftAnchor.constraint(equalTo: bottomViewContainer.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: bottomViewContainer.rightAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: bottomViewContainer.bottomAnchor).isActive = true
        controller.didMove(toParent: self)
        bottomViewContainer.layoutIfNeeded()
    }
    
    public func setTopViewController(_ viewController: UIViewController?) {
        guard let controller = viewController else {return}
        
        //remove previous topVC
        if let previousVC = topVC {
            previousVC.willMove(toParent: nil)
            previousVC.removeFromParent()
            previousVC.view.removeFromSuperview()
        }
        
        //add new topVC
        addChild(controller)
        topViewContainer.insertSubview(controller.view, belowSubview: stubView)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.topAnchor.constraint(equalTo: topViewContainer.topAnchor).isActive = true
        controller.view.leftAnchor.constraint(equalTo: topViewContainer.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: topViewContainer.rightAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: topViewContainer.bottomAnchor).isActive = true
        controller.didMove(toParent: self)
        topViewContainer.layoutIfNeeded()
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc public func toggleMenu(_ sender: Any) {
        if (isSideMenuOpened) {
            closeMenu()
        } else {
            openMenu()
        }
    }
}

//MARK: - UIViewController extension

extension UIViewController {
    var sideMenuController: ACSideMenuController? {
        var parentController: UIViewController? = parent
        while parentController as? ACSideMenuController == nil {
            parentController = parentController?.parent
        }
        if let controller = parentController as? ACSideMenuController {
            return controller
        }
        
        return nil
    }
}

//MARK: - UIGestureRecognizerDelegate

extension ACSideMenuController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return shouldRecognizeMultipleGestures
    }
}
