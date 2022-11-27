# LiteraryClockScreenSaver
MacOS screen saver to display time via literary quotes. Based on the way cooler 
https://www.instructables.com/id/Literary-Clock-Made-From-E-reader/ project created by 
[tjaap](https://www.instructables.com/member/tjaap/).

## !! NOTE: Broken on modern MacOS 😞 !!
Starting with (I think) MacOS 11 / Big Sur, there does not seem to be a way to run an unsigned screen saver application due to increased restrictions by  Gatekeeper. However, I also haven't figured out how to create a signed screen saver with my Apple developer certificate because there's almost no documentation on creating or distributing mac screen savers these days. If you're somebody out there who can help, please comment on [Issue #1](https://github.com/mmattozzi/LiteraryClockScreenSaver/issues/1)!

## Screenshot
![Screenshot](https://github.com/mmattozzi/LiteraryClockScreenSaver/raw/master/litclocksaver-screenshot.jpg)

## Installation
* Download DMG from [Releases page](https://github.com/mmattozzi/LiteraryClockScreenSaver/releases/latest)
* Open DMG
* Right click on `LiteraryClockScreenSaver.saver`
* Choose `Open With...` :arrow_right: `System Preferences`
* Select whether you want to install the screen saver for the current user or for all users

## Data Sources
Source of literary quotes also by *tjaap* from link on https://www.instructables.com/id/Literary-Clock-Made-From-E-reader/ 
-- *litclock_annotated.csv*. So far, I've made some minor tweaks to this data to get each quote onto one line. Oddly, this is a pipe separated file, not comma separated as the name might imply. License appears to be [CC BY-NC-SA 2.5](https://creativecommons.org/licenses/by-nc-sa/2.5/), the material of which can be used within a GPLv3 licensed program.

Images were retrieved from flickr and listed in LICENSE.txt. All images used were licensed with the Creative Commons license:
[Attribution-NonCommercial-ShareAlike 2.0 Generic (CC BY-NC-SA 2.0)](https://creativecommons.org/licenses/by-nc/2.0/) at the time they were sourced. Images are also credited in "Screen Saver Options..." section of System Preferences. 
