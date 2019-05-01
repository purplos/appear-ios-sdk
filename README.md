# Appear iOS SDK

Appear is an app development platform with tools to help you build apps with dynamic Augmented Reality content. More information about Appear can be found at [https://ar.purpl.dev](https://ar.purpl.dev)

## Install the SDK

Go to the [Appear Console](https://ar.purpl.dev) and create a project. 

### Prerequisites

Before you begin, you need a few things set up in your environment:
* Xcode 10.2 or later
* An Xcode project targeting iOS 12 or later
* Swift projects must use Swift 5.0 or later
* The bundle identifier of your app
* CocoaPods 1.4.0 or later

### Add the SDK

Go to the [Appear Console](https://ar.purpl.dev) and create a project, then enter a Project name.
Enter the bundle identifier from your XCode Project and upload pictures and models.
Download the plist file and drag it into your XCode Project

### Add The Appear Framwork to your project

Appear is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Appear'
```

### Initilize Appear in your app

Import the Appear module in your UIApplicationDelegate:

```
import Appear
```

Configure a AppearApp shared instance, typically in your application's application:didFinishLaunchingWithOptions: method:

```swift
AppearApp.configure()
```

Remember to add a NSCameraUsageDescription to your project if you havent already done so. Add the following code into your info.plist file

```xml
<key>NSCameraUsageDescription</key>
<string>{YOUR APP NAME} requires access to your phone’s camera.</string>
```

## Usage

With the Appear Framework added to your project you can easly create a SimpleARViewController or use your own fully customizable UIViewController. 

### Quick and easy implementation

Initilize an instance of the SimpleARViewController  and present it. And thats it!

```swift
let simpleVC = SimpleARViewController()
present(simpleVC, animated: true, completion: nil)
```

You can also replace the default tutorial view with your own UIView. Just make sure to replace the tutorialView on the SimpleARViewController before you present it.

```swift
// create an instance of your own subclass of UIView
let customTutorialView = CustomTutorialView()

// create an instance of the SimpleARViewController
let simpleVC = SimpleARViewController()

// replace the tutorialView
simpleVC.tutorialView = customTutorialView

// present 
present(simpleVC, animated: true, completion: nil)
```

### Advanced implementation

Create an instance of AppearManager in your own ViewController and get access to the model, tracking image and image width.


The AppearManager class also has methods for getting the model and the tracking image information separately.

## Versioning

For the versions available, see the [tags on this repository](https://github.com/purplos/appear-ios-sdk/tags). 

## Author

Purpl, hei@purpl.no

## License

Appear iOS SDK is available under the MIT license. See the LICENSE file for more info.
