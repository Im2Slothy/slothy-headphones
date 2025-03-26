# Headphones Music Radio for FiveM
A QB-Core script that lets players use "headphones" to listen to GTA radio stations anywhere in San Andreas—or play YouTube videos right through their headphones! Simple, lightweight, and easy to set up.

## Features
- **GTA Radio Anywhere**: Use headphones to enjoy all in-game radio stations on foot.
- **YouTube Playback**: Paste a YouTube link (e.g., `https://www.youtube.com/watch?v=F7KdQ8CTe5E`) and listen to it in-game.
- **Customizable**: Adjust volume and playback timeout in `config.lua`.
- **No Extra Tools Needed**: Just requires `xsound`.

## Installation
1. **Download the Script**:
   - Grab the latest version from this repository.

2. **Add to Resources**:
   - Drag the `slothy-headphones` folder into your FiveM `resources` directory.

3. **Install `xsound`**:
   - Download from: [Xogy/xsound](https://github.com/Xogy/xsound)
   - Place it in your `resources` folder.

4. **Update `server.cfg`**:
   - Add these lines (order matters):
     ```
     ensure xsound
     ensure slothy-headphones
     ```

5. **Add Item to QB-Core**:
   - Open `qb-core/shared/items.lua` and add:
     ```lua
     ["headphones"] = {
         ["name"] = "headphones",
         ["label"] = "Headphones",
         ["weight"] = 500,
         ["type"] = "item",
         ["image"] = "headphones.png",
         ["unique"] = true,
         ["useable"] = true,
         ["shouldClose"] = true,
         ["combinable"] = nil,
         ["description"] = "Listen to the best radio stations or YouTube videos in San Andreas!"
     },
     ```
   - Add an image (`headphones.png`) to `qb-inventory/html/images/` or your inventory’s image folder.

6. **Add to Shops (Optional)**:
   - Open `qb-core/server/shops.lua` (or your shop config) and add under a shop’s items:
     ```lua
     {name = "headphones", price = 2, amount = 50, info = {}, type = "item"},
     ```

7. **Start Your Server**:
   - Run your FiveM server, and you’re good to go!

## Usage
- **Equip Headphones**: Use the "headphones" item from your inventory.
- **Menu Options**:
  - **Turn On**: Start listening to the default radio station.
  - **Turn Off**: Stop all audio and remove headphones.
  - **Change Radio Station**: Pick from all GTA radio stations.
  - **YouTube Link**: Paste a YouTube URL (e.g., `https://www.youtube.com/watch?v=F7KdQ8CTe5E`) to play it.
- **Current Station**: Shows the radio station or YouTube video title currently playing.

## Configuration
Edit `config.lua` to tweak settings:
- `Config.EnableYouTubeLink`: Set to `false` to disable YouTube playback.
- `Config.DefaultVolume`: Volume for YouTube audio (0.0 to 1.0, default: 0.5).
- `Config.TimeoutSeconds`: How long YouTube audio plays before stopping (default: 300 seconds = 5 minutes).

## Script Showcase

Watch it in action: [![Watch the video](https://img.youtube.com/vi/ogaTHONHx-Q/maxresdefault.jpg)]([https://www.youtube.com/watch?v=jrWHAdN83g8](https://www.youtube.com/watch?v=ogaTHONHx-Q))

## Support
Found a bug? Got a suggestion? Join my Discord and let me know—I’ll fix it fast!
- **Discord**: [https://discord.gg/RQBhmWEzTx](https://discord.gg/RQBhmWEzTx)

## Credits
- **Author**: Im2Slothy#0
- **xsound**: Thanks to [xsound](https://github.com/Xogy/xsound) for being the backbone of the youtube side. 

Enjoy.
