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

##Synchronizing big .ipa files over Cloud services like Dropbox
Adhoc .ipa files are simply .zip files. Due to the compressed nature of zip files, they perform poorly
with Cloud synchronization. In most cases, 99% of the file need to be sent each time even if only a
small part of the files contained in the archive have been really modified.
When the archive is a few megabytes of data, it’s not a big problem, but when you’re dealing with big
archives (tens of MB), a workaround embedded in AppStaller can greatly improve the synchronization time.
Rather than dropping your archive on Dropbox (or any other service you use), follow these steps:

* Rename your .ipa archive into .zip
* Extract the contents of the .zip
* Drop the app located in Payload (just the app, not the Payload directory itself) into Dropbox

Then, of the other side, when the synchronization is done, rather than dropping the .ipa archive in the
same directory where AppStaller is installed, your tester will just have to drop this received app.
AppStaller will then repack a working .ipa archive for you. He then follows the same steps for the
installation on the device. Btw, no need to have any certificate neither any provisioning profile as
long as the app file received in Dropbox is kept untouched. Hope this will save your time as it saves mine!

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

