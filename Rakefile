NAME='Imbed'
SIGNING_CERT='iPhone Distribution'

## ensure we're running under 'bundle exec'
unless ENV['BUNDLE_GEMFILE']
  command = "bundle exec rake #{ ARGV.join(' ') }"
  exec(command)
end

require 'tinder'

desc "Builds content from /static and copies it into the iOS app."
task :build_static do
  puts "Building the content from static and copying into the Xcode app..."
  system "cd \"#{NAME}/www\" && rm -rf *"
  system "cd static && cp -r * \"../#{NAME}/www/\""
  # the above line would usually have some sort of build command in between cd and cp commands.
end

desc "Runs the app in the iOS simulator TODO"
task :sim => :build do
  puts "Launching app in simulator..."
  system "ios-sim launch #{build_dir}/#{NAME}.app" 
end

desc "Bumps the bundle version in preparation of the build."
task :next_version do
  major, minor, patch = current_version =~ /(\d+)\.(\d+)\.(\d+)/ && [$1, $2, $3]
  `cd \"build/#{NAME}\" && agvtool new-version #{major}.#{minor}.#{patch.to_i + 1}`
  puts "Bumped version to #{current_version}"
end

desc "Tag the build"
task :tag do
  `git commit -am "Getting ready to ship to testflight"`
  `git tag -a v#{current_version} -m "Tagging v#{current_version} for deployment to testflight."`
  `git push origin master --tags`
end

desc "Clean the build"
task :clean do
  system "xcodebuild -scheme \"#{NAME}\" -workspace \"build/#{NAME}/#{NAME}.xcworkspace/\" clean CONFIGURATION_BUILD_DIR=\"#{build_dir}/Debug/\""
end

desc "Build the application."
task :build => :clean do
  system "xcodebuild -configuration Debug -scheme \"#{NAME}\" -workspace \"build/#{NAME}/#{NAME}.xcworkspace/\" CONFIGURATION_BUILD_DIR=\"#{build_dir}/Debug/\""
end

desc "Build the release config of the app."
task :release_build => :clean do
  system "xcodebuild -configuration Release -scheme \"#{NAME}\" -workspace \"build/#{NAME}/#{NAME}.xcworkspace/\" CONFIGURATION_BUILD_DIR=\"#{release_app_path}\""
end

desc "Signs the app with the provisioning profile"
task :sign do
  puts ENV["PWD"]
  system <<-EOC
    /usr/bin/xcrun -sdk iphoneos PackageApplication -v "#{release_app_path}/#{NAME}.app" \
                   -o "#{release_app_path}/#{NAME}.ipa" \
                   --sign "#{SIGNING_CERT}" \
                   --embed "#{provisioning_profile}"
    EOC
end

desc "Upload ipa to testflight."
task :deploy do
  zip_dsym
  uploader = Testflight.new do |config|
    config.ipa_path = "#{release_app_path}/#{NAME}.ipa"
    config.zipped_dsym_path = "#{release_app_path}/#{NAME}.app.dSYM.zip"
    config.distribution_lists = [ENV["dist"]]
    config.replace = ENV["replace"]
    config.notify_testers = ENV["notify"]
    config.user_notification = true
    config.verbose = true
    config.api_token = "xxxxxxx"
    config.team_token = "xxxxxxx"
  end
  uploader.deploy()
end

desc "Notify campfire of the Testflight release."
task :notify_campfire do
  puts "Notifying campfire..."
  user = `git config --global --get user.name 2>/dev/null`.strip
  if user.empty?
    user = ENV['USER']
  end
  campfire = Tinder::Campfire.new 'ORG_NAME', :token => 'xxxxxxxx'
  # room = campfire.find_room_by_name "Roboto's House of Wonders"
  room = campfire.find_room_by_guest_hash 'GUEST_HASH', "ROOM_NAME"
  room.speak "#{user} released version #{current_version} of #{NAME} to Testflight."
end

desc "Performs all the tasks for a deployment to Testflight"
task :ship_it => [:build_static, :next_version, :tag, :release_build, :sign, :deploy, :notify_campfire]

desc "Re-compiles and ships current version of the app."
task :re_ship => [:release_build, :sign, :deploy]

def current_version
  ` cd \"build/#{NAME}\" && agvtool vers` =~ /(\d+\.\d+\.\d+)/ && $1
end

def build_dir
  File.join(File.dirname(__FILE__), "../../build/#{NAME}/build/")
end

def release_app_path
  "#{build_dir}/Release/"
end

def zip_dsym
  puts "zipping the dsym..."
  system "ditto -c -k --sequesterRsrc --keepParent \"#{release_app_path}/#{NAME}.app.dSYM\" \"#{release_app_path}/#{NAME}.app.dSYM.zip\""
end

def provisioning_profile
  puts "getting provisioning profile"
  File.join(File.dirname(__FILE__), "../../build/", "adhoc.mobileprovision")
end
