## Notes

C Requirements and setup as follows:

PC Requirements:
A PC with an Nvidia 600 GPU or newer
GeForce Experience app

* You'll need to make sure your streaming PC and your rk3326 device with the supported linux distro are connected to the same network.
* When you launch Moonlight from the ports menu, you'll be presented with a menu with 2 options, Start Streaming and settings. You'll want to go to settings first and choose the pair option.
* You'll be presented with a screen asking for the name or IP address of your PC with the Nvidia Geforce Experience app installed.
* Once you hit the ok button, you should be presented with a pairing dialog box on your PC.
* Enter the 4 digit PIN displayed on your device into the pairing dialog box and click the Connect button.
* By default, Moonlight is setup to stream Steam from your PC. There are other options available such as Dolphin if you have that installed and configured on your PC.
* Notes:
* 
* To ensure that you have controls in your games while streaming, be sure to disconnect any game controllers from your PC and reboot your PC before you start your streaming session.
* More information about Moonlight is available here.
* If you experience issues with the setup and launching menu functioning correctly, hitting start may resolve it or simply force close the port using the usual exit hotkey on ArkOS or supported linux distro for your device (RGB10 = Minus + Start, RK2020/RG351P/M/V/MP = Select+Start, Chi = 1 + Start).
* For those that don't have an Nvidia vide card, there's an alternative PC client called Sunshine. I haven't tested it so I don't know how well it will work but there's been reports that it seems to work well.
* To exit Moonlight when complete, you can press Select+Start+L1+R1 or simply use the exit hotkey for your device to get out of the app.
* If you experience issues reconnecting to your PC, go to settings in the Moonlight app and unpair the PC then do another pair again.
* There has been an instance where Moonlight would not work with a PC unless the HDMI connection was removed from the PC to a TV.
* You can add more apps for streaming by editing the Moonlight.sh file and adding more apps between lines 167 and 173. Be aware that the entries are case sensitive.
* Mouse control is only possible using the Rockchip platform in settings. That is only possible on the OGA, OGS, RGB10, and the RK2020 at this time. Holding start for about 2 - 3 seconds while using the Rockchip platform will switch to mouse mode. Hold Start for about 2 - 3 seconds again to switch back to gamepad controls.



Thanks to the [moonlight-stream](https://github.com/moonlight-stream/moonlight-embedded) team for creating this solution that makes it possible.  Also thanks to [AreaScout](https://github.com/AreaScout/moonlight-embedded) for the necessary modifications that make this possible to run on portmaster.



