# imbed

This is a starting point for using web content in an iOS app, complete with rake tasks and pre-written handlers for common iOS tasks.

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
3. `bundle exec rake build`

Lots of automation here:

```
rake ios:build                   # Build the application
rake ios:build_static            # Builds content from /static and copies it into the iOS app
rake ios:clean                   # Clean the build
rake ios:deploy                  # Upload ipa to testflight
rake ios:next_version            # Bumps the bundle version in preparation of the build
rake ios:notify_campfire         # Notify the dojo4 campfire of the Testflight release
rake ios:re_ship                 # Re-compiles and ships current version of the app
rake ios:release_build           # Build the release config of the app
rake ios:ship_it                 # Performs all the tasks for a deployment to Testflight
rake ios:sign                    # Signs the app with the provisioning profile
rake ios:sim                     # Runs the app in the iOS simulator
rake ios:tag                     # Tag the build
```
