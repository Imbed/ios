# imbed

[![Join the chat at https://gitter.im/Imbed/ios](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Imbed/ios?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is a starting point for using web content in an iOS app, complete with rake tasks and pre-written handlers for common iOS tasks. See [our announcement post](http://dojo4.com/blog/announcing-imbed-the-best-way-to-use-web-content-in-an-i-os-app).

## Required Reading

If you're completely new to iOS development, follow this tutorial from Apple:

[Start Developing iOS Apps Today](https://developer.apple.com/library/IOS/referencelibrary/GettingStarted/RoadMapiOS/index.html)

and then read

[WebViewJavascriptBridge README](https://github.com/marcuswestin/WebViewJavascriptBridge/blob/master/README.md).

You'll then have the knowledge to understand the architecture and purpose of this project.


### Architecture

Instead of learning a third party framework like Phonegap and hoping they have support for the features we wanted, we decided to use a simple open source framework to bridge JS in the webview and native code, so we could write the features we wanted in Objective C in the way Apple recommends. We're using Marcus Westin's great [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge) as our bridge to allow function calls between the two environments.

### Usage

1. `pod install`
2. Follow examples to use [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge) in your JS and ObjC code.
3. Put your web content in Imbed/www
4. Run through Xcode (always open the workspace, not the project) or the rake tasks below

(When you make changes to your web content, either test it in Chrome and then setup a `rake build_static` task to remove all files and copy yours back into the project, or do a `Clean` in Xcode before building again.)

### Rake tasks

1. `bundle install`
2. `bundle exec rake -T`
3. Edit your web content in the `/static` directory.
3. `bundle exec rake build_static`
4. Launch through Xcode or `bundle exec sim`

Lots of automation here:

```
rake build            # Build the application
rake build_static     # Builds content from /static and copies it into the iOS app
rake clean            # Clean the build
rake deploy           # Upload ipa to testflight
rake next_version     # Bumps the bundle version in preparation of the build
rake notify_campfire  # Notify campfire of the Testflight release
rake re_ship          # Re-compiles and ships current version of the app
rake release_build    # Build the release config of the app
rake ship_it          # Performs all the tasks for a deployment to Testflight
rake sign             # Signs the app with the provisioning profile
rake sim              # Runs the app in the iOS simulator TODO
rake tag              # Tag the build
```
