![Header](https://raw.githubusercontent.com/purplos/appear-ios-sdk/master/Skjermbilde%202019-09-17%20kl.%2009.58.59.png)
# Appear iOS SDK

Appear is an app development platform with tools to help you build apps with dynamic Augmented Reality content. This framework allows you to upload Augmented Reality assets to a database and access them in your app whenever they are needed.

Read more about The Appear Framework on our [website](https://appear-landingpage.netlify.com/)

## Install the SDK

### Prerequisites

Before you begin, you need a few things set up in your environment:
* Xcode 11 or later
* An Xcode project targeting iOS 13 or later
* Swift projects must use Swift 5.0 or later
* The bundle identifier of your app
* CocoaPods 1.4.0 or later

### Add the SDK

Sign in to the [Appear Console](https://appear-console.herokuapp.com/) and create a project.
Create a project
Create a client
Upload .Reality files
Download the plist file and drag it into your Xcode Project.

### Add The Appear Framwork to your project

Appear is available through [CocoaPods](https://cocoapods.org/pods/Appear). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Appear'
```

### Initilize Appear in your app

Import the Appear module in your UIApplicationDelegate:

```
import Appear
```

Configure AppearApp, typically in your application's application:didFinishLaunchingWithOptions: method. Optionally add options like enabling debugging:

```swift
// without options
AppearApp.configure()

// with options
AppearApp.configure([.enableDebugging]) 
```

Remember to add a NSCameraUsageDescription to your project if you havent already done so. Add the following code into your info.plist file

```xml
<key>NSCameraUsageDescription</key>
<string>{YOUR APP NAME} requires access to your phone’s camera.</string>
```

Download the Appear-info.plist file from the appear console website and drag it into your project

## Usage

### Quick and easy implementation of a Reality Projects

With the Appear Framework added to your project you can easly create a RealityFileViewController. Place this in a button click function or in your viewDidAppear to navigate to the camera view.

```swift
let vc = RealityFileViewController()
present(vc, animated: true, completion: nil)
```

You can also replace the default tutorial view with your own UIView. Just make sure to replace the tutorialView on the RealityFileViewController before you present it.

```swift
// create an instance of your own subclass of UIView
let customTutorialView = CustomTutorialView()

// create an instance of the RealityFileViewController
let vc = RealityFileViewController()

// replace the tutorialView
vc.tutorialView = customTutorialView

// present 
present(vc, animated: true, completion: nil)
```

The RealityFileViewController will by default fetch all the active .reality files that have been uploaded. If you want to spesify which .reality file that should be used you can simply configure the RealityFileViewController with the identifier.

```swift
// create an instance of the RealityFileViewController
let vc = RealityFileViewController()
// configure with the identifier of the .reality file that should be displayed 
vc.configure(withIdentifier: "") 
```

You can run code whenever an alert is being received from a behavior. For example you can run a network request when the user clicks on a 3D model, detects a plane/image/object, etc..

```swift
let vc = RealityFileViewController()
vc.onAction { (identifier, entity) in
    if identifier == "your_identifier" {
        // Do something
    }
}
```

### Advanced implementation of a Reality Projects

Create an instance of AppearManager in your own ViewController and get access to all uploaded assets. 

Fetching the project: 

```swift
// create an instance of the AppearManager
let manager = AppearManager()

// fetch the project
manager.fetchRealityProject { (result) in
    switch result {
    case .success(let project):
        print(project)
    case .failure(let error):
        // Handle error here
    }
}
```

This project object contains an array of RealityMedia objects. These are the uploaded reality files. 

If you dont want to fetch the project but just want to load a reality file uploaded with a spesific identifier you can also do that.

```swift
manager.fetchMedia(withID: "c7dc2f20-2330-4b59-b5c2-379d55a860a7") { (result) in
        switch result {
        case .success(let media):
            
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
```

In order to place these reality files to a scene we currently need to store the reality file locally so it can be loaded through RealityKit.

```swift
// fetching the reality file, storing it file with URL.
manager.fetchRealityFileArchiveUrl(from: media) { (result) in
    switch result {
    case .success(let url):
        // load Entity with URL
    case .failure(let error):
        // Handle error here
    }
}
```

In order to handle the recieved alerts from the reality file make sure the ViewController comforms to AppearManagerDelegate. This delegate has a function that can be implemented to handle incoming alerts.

```swift
func didReceiveActionNotification(withIdentifier identifier: String, entity: RealityKit.Entity?)
```

## Versioning

For the versions available, see the [tags on this repository](https://github.com/purplos/appear-ios-sdk/tags). 

## Author

Purpl, hei@purpl.no

## License

Appear iOS SDK is available under the MIT license. See the LICENSE file for more info.
