# ACSideMenuController
An easy way to integrate slide menu into your app
![Preview](/Images/Preview.png)

## Setup
Create instances of your view controllers and then initialize `ACSideMenuController` like this: <br>
```
let menuController = ACSideMenuController(bottomViewController: bottomVC, topViewContoller: topVC)
```
and make it a root view controller of app's window:
```
self.window = UIWindow(frame: UIScreen.main.bounds)
self.window!.rootViewController = menuController
self.window!.makeKeyAndVisible()
```

## Working with UIStoryboard
ACSideMenuController also supports a storyboard way. Here is how you do it using storyboard: <br>
First, add a view controller scene to your storyboard and mark it as initial. <br>
![View controller scene](/Images/Storyboard_0.png) <br>
With that being done, navigate to the Identity Inspector section in the right menu and set it's class to `ACSideMenuController` <br>
![Identity Inspector](/Images/Storyboard_2.png) <br>
Now it's time to set top & bottom view controllers. Navigate to the Attributes Inspector section in the right menu and insert a StoryboardID of your view controller into the appropriate field. <br>
![Attributes Inspector](/Images/Storyboard_1.png) <br>

As a bonus, ACSideMenuController supports different storyboards. If your view controller is stored inside of a storyboard, which name is not a "Main", you can set custom storyboard name for your view controller in the Attributes Inspector section.

## Replacing top & bottom view controllers
You can easily replace top and bottom view controllers just like this: <br>
```
menuController.setTopViewController(newTopViewController)
menuController.setBottomViewController(newBottomViewController)
```
Don't forget to call `menuController.toggleMenu()` after replacing top view controller.
## Adding gesture recognizer
You can add gesture recognizer to your view controller's view like this:
```
if let menuController = self.sideMenuController {
    view.addGestureRecognizer(menuController.gestureRecognizer)
}
```
## Customization
ACSideMenuController has a couple of behavior settings that you can change: <br>

### Behavior
- `var openedMenuInset: CGFloat` customizes top view controller's inset while menu is opened
- `var animationDuration: TimeInterval` customizes animation duration
- `var shouldRecognizeMultipleGestures: Bool` is just a toggle from `UIGestureRecognizerDelegate`
- `var blocksInteractionWhileOpened: Bool` disables user interaction while menu is opened

### Shadow
- `var shadowEnabled: Bool` is a global switch to enable/disable `topViewController`'s shadow with only one line of code
- `var shadowColor: UIColor` defines color of the shadow
- `var shadowRadius: CGFloat` defines radius of the shadow
- `var shadowOpacity: Float` defines opacity of the shadow
- `var shadowOffset: CGSize` defines offset of the shadow

## Stay notified
To notify you about state changes ACSideMenuController uses `NotificationCenter`. <br>
Here is a list of available notifications: <br>
- `ACSideMenuController.NotificationName.didOpenMenu`
- `ACSideMenuController.NotificationName.didCloseMenu`
- `ACSideMenuController.NotificationName.willChangeState`

You can subscribe to these notifications like this: <br>
```
let notificationName = ACSideMenuController.NotificationName.willChangeState
NotificationCenter.default.addObserver(self, selector: #selector(selectorToHandleChanges), name: notificationName, object: nil)
```

## Changelog
### v1.0
- Initial release

### v1.1
- Added support for `UIStoryboard`
- Added the ability to customize behavior and visuals using Interface Builder
- Fixed issue with shadow

## Author
Alexandr Chekel ([Twitter](https://twitter.com/alex_d1337))
