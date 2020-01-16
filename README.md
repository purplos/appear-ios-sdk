![Header](https://raw.githubusercontent.com/purplos/appear-ios-sdk/master/Skjermbilde%202019-09-17%20kl.%2009.58.59.png)
# Appear iOS SDK

Appear is an app development platform with tools to help you build apps with dynamic Augmented Reality content. This framework allows you to upload Augmented Reality assets to a database and access them in your app whenever they are needed.

## Quick Overview
[![Object Detection Gif](https://media.giphy.com/media/ZEO80GmrjTqrcRwei7/giphy.gif)](https://media.giphy.com/media/ZEO80GmrjTqrcRwei7/giphy.gif)

✅ Image detection <br/>
✅ Object Detection <br/>
✅ Display usdz models <br/>
✅ Display .mov and mp4 videos
✅ .Reality support <br/>

## Install the SDK

### Prerequisites

Before you begin, you need a few things set up in your environment:
* Xcode 10.2 or later
* An Xcode project targeting iOS 12 or later
* Swift projects must use Swift 5.0 or later
* The bundle identifier of your app
* CocoaPods 1.4.0 or later

### Add the SDK

Sign in to the [Appear Console](https://appear-console.herokuapp.com/) and create a project.
Upload triggers and add assosiated Augmented Reality Media files.
Go to the Integrations tab and create an iOS client. Remember to enter the bundle identifier from your Xcode Project.
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

### Usage for Reality Projects
With the Appear Framework added to your project you can easly create a RealityFileViewController. Place this in a button click funcion or in your viewDidAppear to navigate to the camera view.

```swift
let vc = RealityFileViewController()
present(vc, animated: true, completion: nil)
```

### Usage for Trigger Projects

With the Appear Framework added to your project you can easly create a TriggerARViewController or use your own fully customizable UIViewController. 

### Quick and easy implementation

Initilize an instance of the TriggerARViewController  and present it. And thats it!

```swift
let triggerVC = TriggerARViewController()
present(triggerVC, animated: true, completion: nil)
```

You can also replace the default tutorial view with your own UIView. Just make sure to replace the tutorialView on the TriggerARViewController before you present it.

```swift
// create an instance of your own subclass of UIView
let customTutorialView = CustomTutorialView()

// create an instance of the TriggerARViewController
let triggerVC = TriggerARViewController()

// replace the tutorialView
triggerVC.tutorialView = customTutorialView

// present 
present(triggerVC, animated: true, completion: nil)
```

### Advanced implementation

Create an instance of AppearManager in your own ViewController and get access to all the project assets. 

Fetching the project: 

```swift
// create an instance of the AppearManager
let manager = AppearManager()

// fetch the project
manager.fetchProject { (result) in
    switch result {
    case .success(let project):
        print(project)
    case .failure(let error):
        // Handle error here
    }
}
```

After having fetched the project you can fetch the triggers and agumented media files using the AppearManager.

Fetching the triggers:
```swift
for item in project.items {
    manager.fetchTriggerArchiveUrl(from: item, completion: { (result) in
        switch result {
        case .success(let url):
            switch item.trigger.type {
            case .image:
                // create a reference image with the URL and add it to a set of ARReferenceImage
            case .object:
                // create a reference object with the URL and add it to a set of ARReferenceObject
            }
        case .failure(let error):
            fatalError(error.localizedDescription)
        }
    })
}
```

Fetching the Augmented Media: 
```swift
for media in item.media {
    manager.fetchMediaArchiveUrl(from: media, completion: { (result) in
        switch result {
        case .success(let url):
            switch media.type {
            case .model:
                let modelNode = AppearModelNode(archiveURL: url, modelMedia: media as! AppearProjectItem.ModelMedia)
                // do something with the modelNode.
            case .video:
                let videoNode = AppearVideoNode(videoArchiveURL: url, media: media as! AppearProjectItem.VideoMedia)
                // do something with the videoNode
            }
        case .failure(let error):
            fatalError(error.localizedDescription)
        }
    })
}
```

## Versioning

For the versions available, see the [tags on this repository](https://github.com/purplos/appear-ios-sdk/tags). 

## Author

Purpl, hei@purpl.no

## License

Appear iOS SDK is available under the MIT license. See the LICENSE file for more info.
