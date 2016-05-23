#Share Sheet Debugger

Share Sheet Debugger (SSD for short) is a project built with the aim of aiding the development of sharing content within iOS applications. It does this by providing in-depth information about the data being shared, allowing developers to see how iOS shares the data provided by the application, and also allows developers to see how others have formatted their shared data.

![Example GIF](Assets/GitHub/demo.gif)

##Features

 - [X] Support for multiple shared items
 - [X] Support for multiple data types per item (e.g., an image and it description as text)
 - [ ] Detect and display various data types:
 	- [X] Images
 	- [X] Text
 	- [X] Videos
 	- [X] Contact Cards
 	- [ ] Locations (via contact cards)
 - [ ] Provide a method of displaying the raw data/text of a shared item
 - [ ] Add some example items to the iOS application
 	- [ ] An image
 	- [ ] An image with a preview
 	- [ ] A contact card
 	- [ ] A piece of text
	- [ ] A video
	- [ ] A website
- [ ] Allow for various cells across the extension to offer their data to be copied via a long tap on the cell

##Running

SSD requires iOS 8.0 or higher. Some features, such as the use of the `SFSafariViewController` are restricted to later version of iOS.

There are no external dependencies, so the use of Carthage/CocoaPods/SPM is not required.

##Contributing

Pull requests are welcome (if not encouraged). If you find the project useful, give [the repo](https://github.com/JosephDuffy/Share-Sheet-Debugger) a star. If you find any issues an don't want to/can't find a solution, [submit an issue on GitHub](https://github.com/JosephDuffy/Share-Sheet-Debugger/issues/new).
