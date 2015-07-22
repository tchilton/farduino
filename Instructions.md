farduino
=========

Far Away Arduino programming

Allows Arduino microcontrollers (uc) to be programmed remotely via an 
intermediate Linux computer such as a Raspberry Pi when its not practical to 
provide a direct USB connection to a device.

- Fully integrated to the Arduino IDE for programming activities 
  with normal programming progress showing in the IDE
  
- Secure and easy interface via standard PuTTY and WinSCP

- Configured via standard Arduino menus - different environments (live, test,
  etc) and different uc's examples are provided in the sample scripts
  
- Serial debugging available via standard Linux minicom, but this is not IDE
  integrated
  
- Supports Prod and Pre-Prod type environments

- Uses existing Ardiuno resources, so easy to maintain as the Arduino IDE 
  develops 

Background
==========

The Arduino framework is great as it allows people to go from a standing
start and get going with uc's without having to go deep into the inner
workings of the device before they can get any useful work done. 

This means that Arduino powered devices are popping up all over the place
doing all sorts of automation work. However, many of these are not close to
the machine used to develop them, which can make ongoing updates to the code
a little tricky.

My current spare-time project, the [Chicken Coop controller] (http://www.chicken-pi.co.uk) 
necessitated this project, since the target device is nowhere near the 
development PC and even if I could reliably run USB for more than 15 meters,
this is not practical either. An alternative method of connecting to the 
Arduino both for programming and for debugging was required, this project 
is the result.

I wanted to be able to sit in the Arduino framework and develop and test in a
normal manner. From a developer perspective, everything looks "normal" and I 
can see all the diagnostic output during the programming process. In addition, 
I can connect to the device for normal serial communication to view the debug
output. 

This method took a while to develop and has evolved over several versions of 
the IDE and was last tested with Arduino version 1.6.4. Importantly, the 
current version survives a re-install of the Arduino IDE.

This project is provided in the hope that it may help someone else who finds
themselves in the same situation. 

To use these scripts, you will need :

- To have a reasonable level of basic Linux administration, 

- To be able to read Windows and BASH scripts

- Be familiar with SSH and SCP and their windows equivalents PuTTY and WinSCP

If you do not have these skills, none of it is difficult to learn. 
There are many sites providing this information on-line that can help.

I do not have a lot of time to spend lots of time manually walking people 
through the install, so please follow the instructions.

Licence 
=======

You are free to use this process in your own projects and to refine it as you
desire, but you must not pass it off as your own work. You must provide a link
in source code and any documentation back to this project on [GitHub] (https://github.com/tchilton/farduino).

The exception is for the Arduino foundation, who are free to use or refine 
this code or the approach within future versions of the Arduino project if 
they desire as long as it is provided as an integral part of the Arduino 
framework. All I ask for is credit for it in the release notes - Call it my 
part of giving to the project, for all that I have taken.

Concepts of operation
=====================

The end-to-end process works as follows 

- The Arduino IDE is extended via standard configuration files to allow 
  another type of uc's to be programmed. This is just a clone of the standard 
  Arduino devices.

- Some new menus appear in the Arduino IDE that allow you to configure which
  programming interface (Linux computer) to use and which uc's type you want 
  to talk to
  
- You hit upload in the normal manner

- Different programming tools are called - this is a Windows script.

- The windows script copies the target .HEX file to the remote Linux computer

- The windows script executes a script on the remote Linux computer

- The remote Linux computer programs the Arduino

- Any log messages from the above come out in the Arduino IDE, so you can see
  what is happening

Optionally, you can SSH/ PuTTY into the remote Linux computer and run minicom
to get to the Serial output from the uc.

Installation
============

The install process assumes you are developing on Windows. If you are on 
Linux, then the same process is used, but you would use the built-in Linux 
ssh and scp tools instead of the downloaded ones. I expect that if you are 
on Linux, the you are already up for doing this and just want the script to 
hack around with ;-)

As you follow the steps, if something doesn't work, then stop and fix that,
don't move on as it will not work. Read the error message and fix the issues,
then move on.

You are advised to take a backup of your machine, particularly the Arduino
config files and any files you care about - in case you make an error when 
performing this install. You can recover the Arduino IDE by reinstalling it.

The install is a bit involved, but each step is easy, to take it steady and
do not rush, you should find that the scripts and concepts are easy to follow.

Installing the tools
--------------------

First, lets install all the tools you need

- Get and install the latest version of the [Arduino software](https://www.arduino.cc/en/Main/Software)
  from the main Arduino web site. Install this in the normal manner

- Test that you can program in the normal manner - for example can you compile
  and program blink and fade into the target controller
  
- Get and install [WinSCP] (http://winscp.net). This is a Secure Copy tool 
  that allows you to copy files like you would using scp on Linux. Just follow
  the installer.
  
- Get and install [PuTTY] (http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html), 
  This is a secure shell (ssh) tool for windows and it allows you to log into 
  systems that support ssh. You need the "installer" or the zip file. Put all
  the files in a directory and record where you put them for later i.e. 
  (c:\utils, c:\tools, etc.)

Connecting everything up
------------------------

- Plug in the Raspberry Pi so its close by

- Connect the Arduino serial programming interface into the Pi's USB port.
  Plug the other end into the Arduino Power everything up if you are using
  external power supplies

Configuring
-----------

Log into the Raspberry Pi using PuTTY. 
From the command line, create the farduino user and add it to the correct
groups with 

`useradd farduino -c "Arduino Firmware Update Account" -G spi,gpio,dialout`

This allows the user account to talk to the SPI interface, handle GPIO lines 
to reset the Arduino and dialout so you can talk serially to the Arduino both 
for programming and for debugging

Set the password on the account - choose something strong (upper case, lower 
case, numbers, symbols), you will not generally need this password except
when debugging connectivity

`passwd farduino`

Prepare for the ssh keys - create folders and set permissions 

```bash
cd /home/farduino
mkdir .ssh
chmod 700 .ssh
cd .ssh
touch authorized_keys
chmod 600 authorized_keys
```

- Create the RSA keys with PuTTYgen  from the PuTTY download

- Launch PuTTYgen and then click the Generate button. The program generates
  the keys for you.
  
- Save the public and private keys by clicking the Save public key and Save
  private key buttons. We do not want them protected.
  
- From the Public key for pasting into OpenSSH authorized_keys file field at
  the top of the window, copy all the text (starting with ssh-rsa and going
  to the end) to your clipboard by pressing Ctrl-C
  
- Install the key on the raspberry pi

`vi authorized_keys`

Paste the contents, save and exit.

###Testing certificate login with PuTTY

- Open PuTTY

- Enter the DNS name or the IP address of the Raspberry Pi in the hostname 
  field

- In connection, data, auto-login username, enter farduino

- In SSH,Auth, Private Key for Authentication, select the private key you 
  saved previously
  
- Scroll back up to session in the left window, Enter a Session name - perhaps
  your project name and then press Save. 
  
  Note this name is required later, so write it down somewhere safe. 
  The default used in the scripts is "Chicken Coop"
  
- Double-click the new session you just created and you should log in 
  automatically with no password prompt - you are using the certificate based 
  login.
  
  Note that the first time for each connection, you will be asked if you want
  to trust the server and its fingerprint will be displayed. You need to 
  select "yes"

If this did not work, then re-check the above taking special care to check the
authorized_keys section and the PuTTY session set up. Any changes to the key
will result in it not working.

###Testing certificate login with WinSCP

Now you have a working ssh configuration with private keys, we need to do the
same for WinSCP, this is used to download the firmware later.

- Open WinSCP

- Click on "New Site"

- Change the file protocol to SFTP

- Hostname - enter the DNS name or IP address of the Raspberry  Pi

- Username - enter farduino. Do not enter a password

- Click Environment, then directories. Enter /firmware in the remote 
  directory field.

- Click Advanced, Advanced, then navigate to SSH, then Authentication
  In the Private Key File, select the same private key used above
  
- Press OK to go back to the initial screen

- Save the session name. This cannot contain any spaces, as above your project
  name is a good choice. The default used in the script is "ChickenCoop"
  
  Note it appears that WinSCP does not support spaces in profile names
  
- Double click on the new profile and it should open with no password prompts
  or errors.

  Note that the first time for each connection, you will be asked if you want
  to trust the server and its fingerprint will be displayed. You need to 
  select "yes"

You now have a working SCP connection to the upload host.

###Setting up serial communication

First we need to know what the port name is, we can find this with

`ls -al /dev/ttyA*`

The /dev/ttyAMA0 device can be ignored, this is on the Raspberry Pi. Its 
likely that the device is called ttyACM0, if not, then substitute that for 
ACM0 in the following lines.

`minicom -s -D /dev/ttyACM0`

- navigate with the arrow keys down to "Serial Port Setup".

- Set the serial port speed / frame format to match what your sketch uses, 
  then press E to change it. 115200,8N1 is a good setting if you don't know
  what to choose. This should match the Serial.begin(115200); line in your
  sketch, or if you have not specified the speed, then the number shown 
  bottom right on the serial monitor in the Arduino IDE. The only important
  thing is they are both the same.

- Press Enter a couple of times until you get to the main menu

- Now select "save as dfl" which means save as default

- Then choose "Exit from minicom"

minicom is now configured, you can now start it with just `minicom` and no 
arguments and it will connect to the Arduino. Note that you must close the 
minicom session to be able to program the Arduino, this is checked for in 
the script and you will see warnings in the Arduino IDE. You can exit minicom
with Ctrl-A, X

Reset on serial connection
--------------------------------------

By default on the PC, When you connect to an Arduino, it is reset. This may
be what you want or it may not. On Linux it is possible to control this 
behaviour under software. For example you may want to connect to you sketch 
for debug at the point it does something odd, so the last thing you want is
for it to be rebooted.

To prevent the reset on connection type

`stty -F /dev/ttyACM0 -clocal -hup`

To allow a reset on connection type

`stty -F /dev/ttyACM0 clocal hup`

**Note this mode is required to perform serial firmware uploads** as entry to 
the bootloader is only available just after a reset occurs

Then in either case, start minicom as normal using

`minicom`

You now have full remote debugging capabilities like the "serial monitor" 
provides in the standard IDE

Note that you must close this connection to program the Arduino, exactly
as the normal IDE does, since its shared between programming and firmware 
upload. 

The above setting is not permanent, so you will need to re-enter it if you 
restart the Raspberry Pi

Configuring the farduino module
===============================

Download the repository for this project from [GitHub] (https://github.com/tchilton/farduino) 
 
You are now ready to download the Far away Arduino (farduino) remote upload 
sample code from GitHub. Obtain the zip file and download it to your PC and
extract its contents (or clone the git repository if you prefer)
There are two folders in the zip file. One folder contains the files that go 
onto your development PC, the others go onto the Raspberry PI. 

You can transfer the Raspberry Pi files to the Pi using the WinSCP tool.
Login with the farduino account and its password or certificate and drag and drop
the files to the /firmware directory

PC configuration
----------------
In the PC folder, first review the farduino-install.cmd script to ensure you
are happy with it
Change the three SET statements to reflect your system, these relate to :

- SOURCEDRIVE - The drive that contains the Arduino software, which will 
  normally be C:

- SOURCE - The folder where the Arduino AVR files live, this will normally be
  the default provided by the script
  
- SCRIPTS - The scripts folder, this is where the scripts will be created on 
  your machine. The default is c:\scripts\farduino
  
- Open a command prompt with start, cmd
  cd to where the farduino files were downloaded
  start the script with `farduino-Install`
  
- Ensure that no errors are reported

- You should now have the scripts in c:\scripts\farduino and in your 
  my documents\arduino\hardware folder there should be a "my boards" folder 
  with a number of files and folders in them.

- Now you need to edit the SET statements in the top of each script to match your environment
  - HOST is the DNS hostname or IP address of your Raspberry Pi
  - USER is the user name for logging into the system, normally this is farduino
  - CERT is the private key use to log into the Raspberry Pi, its the same one you use in PuTTY and WinSCP.
  - SCPPROFILE is the name of the SCP profile you created earlier

You now need to edit the boards.txt file that is in the my 
documents\Arduino\hardware\my boards\avr folder to match the type of Arduino 
board you want to use. I can only provide the direction here, since I don't 
know what Arduino device you are using. The sample script includes the 
Arduino Mega 2560 and the Arduino Pro / Mini Pro to give you a pointer.

You will see that there are two parts highlighted in this file "Standard
Arduino Mega 2560" and "Customisation for Mega 2560".

The standard content is just copied and pasted from the reference Arduino file
with the same name, this is found in 
c:\Program Files (x86)\Arduino\hardware\arduino\avr\boards.txt

You do not need to make any changes to the reference file, so take care when
copying content, Taking a backup is a good thing to do before you start doing 
this. Repeat this step for each type of Arduino you want to remotely program.

You need to repeat the above copy and paste after upgrading the Arduino IDE 
to ensure that any updated settings are carried across to the cloned 
"my boards" class of devices

Raspberry Pi configuration
--------------------------

Having already copied the files to the Raspberry Pi in the instructions above,
we now need to log into the Raspberry Pi and perform some configuration.

- Open PuTTY

- Double-click on the profile for your device "Chicken coop" is the default 
  name to log into the Raspberry Pi

- Perform the following commands. This sets the files to be owned by farduino 
  on your system

```bash
cd /firmware
chown -R farduino:farduino /firmware/*
```

There are two folders present here, one is called "main" and one is called 
"rotator". These are example folders for you to customise.

upload is the script you need to review, this includes the capability to 
upload via serial or SPI.

If you wish to use SPI programming, then check out the Arduino hadware SPI 
add-on in Kevin Cuzner's fork of avrdude, this is available here [kcuzner AVRDUDE install] (https://github.com/kcuzner/avrdude). Note that this is not necessary if you only want ordinary serial programming.

The other scripts in this folder are examples of how to do other avrdude 
commands such as reading the fuses, resetting the fuses. Only do this if you 
really know what you are doing, or you will brick your device.

The resetarduino script allows you to peform a reset on your device by
wiggling a GPIO pin that is connected to the reset of the arduino. Note this 
must be driven by an open collector NPN transistor NOT directly from the 
Raspberry Pi, since the Pi is 3.3V and the Arduino is generally 5V. i.e. it 
is connected GPIO pin via a 330R resistor to the base of transistor. 
The emitter goes to ground, collector to reset pin.

You might also choose to update this script to use the DTR reset pin trick
with stty that is detailed above as this will do the same thing. This is 
left as an exercise for the reader.

You are now fully configured and ready to test.

Testing
-------

OK, so you have done all the above and everything should work, so lets test
and make sure its working properly

- Go into the Arduino IDE

- Choose the correct board under Tools, Board, "My Arduino Boards"

- If you have more than one uc type, choose the correct board

- If you have more than one environment - i.e. a production and a development
  system, then choose the right Upload via Host from tools menu
  
- Upload in the normal manner - Press the Upload button in the IDE. 
  
- Log into the Raspberry Pi

- Open Minicom and see if your sketch will talk to you (assumes your sketch
  actually does serial IO)

Note - to close minicom  use Ctrl-A, X, then select Yes.

I hope you now have a working platform and can have a lot of fun with your 
design and its related sketch. I also hope that you find this tool useful
and that you now have a better understanding of the Arduino framework and 
its extensibility.

Please feel free to suggest improvements via GitHub.

Fixing Problems
===============

OK, so you're here because something doesn't work.

This section is not going to do step by step fixes where you don't know why
you are doing what you are, its going to use the tried and tested approach of 
"binary chop" where you take the problem, and chop it in half by performing a
single, simple test. Then you work out which half now has the problem. After
repeating this 3-4 times, you will be right on top of the problem and can
then fix it. This is a really powerful way to break a complex problem down and
sort out issues and it works on anything as long as you can decide what the
next sensible test for the next "chop" is. Unfortunately this bit comes with 
experience.

In the following steps, if something doesn't work or generates and error, then
read the first error message and fix that, then move to the next one. Often
the first error will cause a cascading effect of further failures.

- First, re-check that you have completed each step listed above and that no 
  errors were reported in any step. If they were, then fix that first before
  continuing.

- Have you got the tools installed properly - Can you open each tool 
  successfully and without error ? If not, then re-install the tools again.

- Can you connect to the Raspberry Pi via SSH and get a $ or # prompt ? 
  If not, then check that the Pi has been correctly configured - use the setup
  instructions on the Raspberry Pi web site to do this.

- Can you connect via PuTTY using the SSH Key that you generated. No password
  needs to be entered at this point. If not, then check the keys you created 
  and that they are installed in the right place.

- Can you connect via a pre-configured WinSCP to the Raspberry PI using the
  same certificate

- Can you see the new menu objects in the Arduino IDE for the new devices ? 
  If not, then the custom .txt files are not correctly installed.

- Can you compile your sketch successfully when the new menu options are 
  selected ? If not, then the script that runs on the PC was not successful.
  check the mklink lines have successfully created the links to the standard
  Arduino IDE. Also verify you can compile successfully if you change back to
  the standard board types. Verbose compile  helps here (see below)
  
- What happens when you attempt to program the device - what error messages 
  does it give What is the output on the screen in the Arduino IDE ?
  Verbose upload helps here (see below)
  
- does the firmware.hex file get transferred to the Raspberry Pi 
  (in /firmware/main/firmware.hex). The presence of this indicates that the
  WinSCP process was successful. You can check the timestamp on the file 
  to ensure its "fresh" 
    
 - Turn on verbose mode in the Arduino IDE to get more information on whats
   going on. This is available in File, Preferences, then by ticking the 
   "Show verbose output" tick boxes. Remember to turn this off again 
   afterwards so you can see the more concise upload status
   
-  Did you remember to close minicom before starting the upload ? The upload
   process will warn if you forget, but its easy to do.