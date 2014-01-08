#AppStaller

##What is it for
This is a humble replacement of the Apple’s iPhone Utility for installing Adhoc apps on iOS devices.  
iPhone Utility is broken (at least for the app installation feature) when ran on OS X Mavericks.

##Requirements
* Python located at `/usr/bin/python` (which should be the default on OS X, can be changed in source code)
* No need for Apache or any other web server, it’s python that will do the trick
* Free TCP port 8000 (can be changed in source code)

##Usage
I won’t go through the steps required to build Adhoc ipa files, many tutos are available on the Web.  
If don’t feel comfortable with Adhoc, ipa, Organizer etc., chances are that this tool is not useful for you.  
Steps you will need to export your ipa file:

* XCode Organizer > Distribute > Save for Enterprise & Adhoc
* Check [X] Save for Entreprise Distribution
* No need to fill the Application URL neither the Title. Even stated as « required » those fields will
  be filled by AppStaller automagically later
* Generate your ipa file **in the same directory** where AppStaller resides (This is important)

That’s it. All you need to do now is simply start AppStaller and click GO.  
You will then be able to install your app directly from your device by opening on Mobile Safari
the URL displayed in AppStaller. Wait for the install to complete and then quit AppStaller.

Of course, only devices listed in the adhoc provisioning profile can install the app unless you
are using an Enterprise provisioning profile.

##Known bugs and subtleties
If AppStaller dies or you kill it, the Python process may still be running and will prevent it to run
again later on, so kill it from the Activity Monitor if this happens.

##Disclaimers
This fits my needs, no promise it will fit yours, but if it does, I will be glad to hear from you
especially if you fix bugs or improve some parts. You can also share ideas, but no promise I
will have time to improve it any time soon.

##Acknowledgment and Copyrights
Icons from http://www.tehkseven.net

##Author
Gildas Quiniou  
[Big Papoo Company](http://www.bigpapoo.com) / [Fabulapps Games](http://www.fabulapps.com)  
[gildas@bigpapoo.com](mailto:gildas@bigpapoo.com)

