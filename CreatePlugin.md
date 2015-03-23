## Purpose ##
This section will show you how to setup and build a Xcode project to create a CarFrontEnd plugin, then install it.

The complete example project that is discussed here is available in the Plugins directory of the source tree as "SamplePlugin".

## Prerequisites ##
You must have the CarFrontEndAPI framework installed on your development host. For the purposes of this discussion, it will be assumed that you have installed it as _/Library/Frameworks/CarFrontEndAPI.framework_.

You should also be using the latest version of [Xcode](http://developer.apple.com/tools/xcode/) which is available from Apple's developer website.

## Project Creation ##
  1. Start XCode (_/Developer/Applications/Xcode_)
  1. Create a new Project (_File->New Project..._)
  1. Select **Cocoa Bundle** as the project type.
  1. Give your project a name and location.
  1. Edit the Project Settings (_Project->Edit Project Settings..._)
    * General Tab
      1. Set the Cross-Development _Target to 10.4 (Universal)_.
  1. Edit the Active Target Settings (_Project->Edit Active Target_).
    * Build Tab
      1. Set the _Configuration_ to "All Configurations".
      1. Set _Show_ to "All Settings" if it is not already.
      1. Set the _Architectures_ to "ppc i386". (Universal build)
      1. Set _Mach-O Type_ to "Bundle".
      1. Set _Wrapper Extension_ to "cfep".
  1. Add the CarFrontEndAPI framework to your project.
    1. Right click on _Frameworks_ in the "Groups & Files".
    1. Select "Add->Existing Frameworks...".
    1. Navigate to where you installed CarFrontEndAPI (the default location is _/Library/Frameworks/CarFrontEndAPI.framework_) and select it.
    1. Click the "ADD" button with no other changes.
  1. Add your primary class to the Project
    1. Right click on _Classes_ in the "Groups & Files" area.
    1. Select "Add->New File...".
    1. Select "Objective-C Class"
    1. Give the new class a name.
  1. Edit your header file.
    1. Add the import for `<CarFrontEndAPI/CarFrontEndAPI.h>`
    1. Update the `@interface` line to include the _CarFrontEndProtocol_ designation.
    1. Add the required methods to conform to the protocol.
    1. Go ahead and add an action so we can add a button.
    * You header should look something like:
```
#import <Cocoa/Cocoa.h>
#import <CarFrontEndAPI/CarFrontEndAPI.h>

@interface SamplePlugin : NSObject <CarFrontEndProtocol> {
    id                  owner;
    IBOutlet NSView     *samplePluginView;
}

- (id) initWithPluginManager: (id) pluginManager;
- (NSString *) name;
- (void) initalize;
- (NSImage *) pluginButtonImage;
- (NSView *) contentViewForSize: (NSSize) size;
- (void) removePluginFromView;

- (IBAction) buttonClicked: (id) sender;

@end
```
  1. Edit the class file
    1. Add a static variable outside the _@implementation_ section.
      * This will allow you to apply the Singleton pattern to the object.
      * The init method will be called twice. Once when the plugin is loaded and once when you load your NIB file.
    1. Add an init method to setup your object.
      * Make sure to use your static variable so that there is only ever one instance of your object.
    1. Add the protocol methods to the _@implementation_.
    1. Add the code for your action method.
    * Your object file should look something like:
```
#import "SamplePlugin.h"

static SamplePlugin *sharedSP = nil;

@implementation SamplePlugin

- (id) init {
    return([self initWithPluginManager:nil]);
}

- (id) initWithPluginManager: (id) pluginManager {
    if (sharedSP != nil) {
        [self release];
        return(sharedSP);
    }
    
    [super init];
    owner = [pluginManager retain];
    
    // Setup for a single instance.
    sharedSP = self;
    
    return(self);
}

- (NSString *) name {
    return(@"Sample Plugin");
}

- (void) initalize {
    // No-op for this example.
    //  Should generate the button image here rather than on demand.
}

- (NSImage *) pluginButtonImage {
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    [attributes setObject:[NSFont fontWithName:@"Helvetica" size:26]
                   forKey:NSFontAttributeName];
	[attributes setObject:[NSColor whiteColor]
                   forKey:NSForegroundColorAttributeName];
    
    NSSize          size = [[self name] sizeWithAttributes:attributes];
    NSImage         *image = [[[NSImage alloc] initWithSize:size] autorelease];
    
    [image lockFocus];
    [[self name] drawAtPoint:NSZeroPoint withAttributes:attributes];
    [image unlockFocus];
    
    return(image);
}

- (NSView *) contentViewForSize: (NSSize) size {
    // We are ignoring the size value, but it is there incase you have differnt
    //  views based on the size that CarFrontEnd sends you.
    if (samplePluginView == nil) {
        [NSBundle loadNibNamed:@"SamplePlugin" owner:self];
    }
    
    return(samplePluginView);
}

- (void) removePluginFromView {
    // No-op
    //  If you need to do something when your view is no longer displayed,
    //  add the code here.
}

- (IBAction) buttonClicked: (id) sender {
    if ([[sender stringValue] isEqualToString:@"Click"]) {
        [sender setStringValue:@"Clock"];
    } else if ([[sender stringValue] isEqualToString:@"Clock"]) {
        [sender setStringValue:@"Click"];
    }
}

@end
```
  1. Add a NIB file to your project and make sure that it uses the name that you used in your _-contentViewForSize:_ method ("SamplePlugin" in the example).
    1. Read your object's header file into the NIB file.
    1. Instantiate your object.
    1. Add a NSView to your NIB file and link it to your NSView outlet.
    1. Add a NSButton to your NSView.
      1. Set it's string value to "Click".
      1. Set it's action to the _-buttonClick:_ method of you object.
  1. Edit your project's _Info.plist_
    1. Set the "NSPrincipalClass" value to the name of your object.
  1. Build your project and fix any compiler errors.

## Installation ##
Copy the built plugin to your _~/Library/Application Support/CarFrontEnd/Plugins_ directory and launch CarFrontEnd. If everything went according to plan, your new plugin should be available.