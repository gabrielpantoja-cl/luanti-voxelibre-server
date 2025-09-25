

# **Luanti Server Administration: A Deep Dive into Performance Tuning and Community Management**

## **Introduction**

The Luanti game engine, formerly known as Minetest, represents a powerful and highly extensible platform for creating and hosting voxel-based worlds.1 Its open-source nature and robust Lua modding API have fostered a vibrant ecosystem of games, mods, and dedicated server communities.1 For a server administrator, the engine offers a profound level of control over nearly every aspect of its operation. This control is primarily exercised through a central configuration file,

minetest.conf, which acts as the server's nervous system, dictating everything from its public identity to the most granular details of its performance characteristics.3

This report provides an exhaustive, expert-level analysis of three critical domains of Luanti server administration: managing world complexity through object density limits, optimizing server performance via memory and resource management, and implementing community policies for player activity. These topics are not merely isolated settings but interconnected components of a stable, high-performance, and well-managed server environment. The objective is to move beyond default configurations and empower administrators with the nuanced understanding required to proactively tune their servers for optimal stability, resource utilization, and player experience. The following sections will deconstruct the server's configuration framework, provide deep analysis of key performance parameters, and detail the implementation of essential community management tools.

## **Section 1: Mastering the Server Configuration Framework**

Before manipulating specific performance variables, it is essential to possess a comprehensive understanding of the Luanti configuration architecture. The engine employs a hierarchical system of configuration files, where settings can be defined at multiple levels. Misunderstanding this hierarchy is a common source of administrative error, leading to settings that do not apply as expected. This section details the location, purpose, and precedence of these critical files.

### **1.1. The minetest.conf File: The Server's Central Nervous System**

The primary configuration file for a Luanti server is minetest.conf.3 This plain text file is read by the engine every time the server starts, and it contains key-value pairs that define the server's behavior. While many settings can be adjusted through the in-game "Advanced Settings" menu (which then writes to this file), direct manual editing remains a fundamental skill for any serious administrator.3

#### **Locating the File**

The location of minetest.conf is determined by the server's installation method, a frequent point of confusion for new administrators. There are three primary locations:

* **System-wide Installations:** For servers installed via a package manager on a Linux distribution like Debian or Ubuntu (e.g., using sudo apt install minetest-server), the configuration file is typically located at /etc/minetest/minetest.conf.4 This is the standard location for system services.  
* **User-specific System-wide Builds:** When Luanti is installed system-wide but runs on behalf of a specific user, it looks for the configuration file in that user's home directory at \~/.minetest/minetest.conf.3  
* **Portable ("Run-in-place") Builds:** For servers run from a self-contained directory (common for compiled-from-source or downloaded zip archives), the engine searches for the file in a relative path, typically ../minetest.conf.3

#### **The minetest.conf.example File as Primary Documentation**

Included with every Luanti distribution is a file named minetest.conf.example. This file is not merely a template; it is the most complete and authoritative documentation for all available engine settings, with each parameter commented to explain its purpose, type, and default value.3 The standard procedure for modifying the server's configuration is to find the desired setting in

minetest.conf.example, copy the line into the active minetest.conf file, and remove the leading hash symbol (\#) to uncomment and activate it.9

#### **Command-Line Overrides**

For advanced server management, such as running multiple server instances from a single Luanti installation, the engine provides a command-line argument to specify a custom configuration file path. Using the \--config /path/to/your/custom.conf option when launching the server will force it to load settings from the specified file, overriding the default locations.3

### **1.2. The Configuration Hierarchy: Understanding Precedence**

The Luanti configuration framework is not monolithic; it is a federated, hierarchical system. Settings in a lower-level, more specific file can silently override those in a higher-level, more general file. Understanding this order of precedence is critical for effective troubleshooting.

1. **Global Engine Settings (minetest.conf):** This is the base layer of configuration, containing the settings that apply to the entire engine instance as described above.6  
2. **Game-Specific Settings:** Individual "games" (which are essentially large, cohesive modpacks like Minetest Game or MineClone2) can include their own minetest.conf or minetest.conf.example file within their directory (e.g., games/minetest\_game/minetest.conf.example).6 These files provide default settings or overrides that are specific to that game. A prime example is the  
   give\_initial\_stuff setting, which is documented and controlled by Minetest Game, not the core engine.12 An administrator attempting to change a game-related setting in the global  
   minetest.conf may find their changes have no effect if a game-specific configuration takes precedence.  
3. **World-Specific Settings (world.mt):** The final layer of configuration resides within each world's specific directory (e.g., /var/games/minetest-server/.minetest/worlds/world/world.mt). This file's primary purpose is to define which mods are enabled or disabled for that particular world.7  
4. **Mod Settings:** Many mods introduce their own configurable parameters. They can expose these settings to the in-game "Advanced Settings" menu by including a settingtypes.txt file. When a user changes one of these settings in the menu, the value is written to the primary minetest.conf file, effectively integrating mod configuration into the global settings.6

This layered model means that an administrator must be aware of where a setting is being defined. If a parameter seems unresponsive, the cause is often an override in a more specific configuration file.

### **1.3. Essential First Steps: Initial Server Setup**

Before diving into performance tuning, several foundational settings should be configured in minetest.conf to establish the server's identity and grant administrative control.

* **Server Identity:** Define the server's public presence with three key settings:  
  * server\_name: The name that appears in the public server list.  
  * server\_description: A longer description of the server's theme, rules, or features.  
  * motd: The "Message of the Day" that is displayed to players in chat when they log in.4  
* **Administrator Privileges:** The most critical initial step is to grant administrative privileges. This is done by setting the name variable in minetest.conf. When a player connects with a username that matches this value, they are automatically granted all server privileges.4 For example:  
  name \= your\_admin\_username.  
* **Public Visibility:** To have the server appear on the public server list, the server\_announce setting must be set to true: server\_announce \= true.15

## **Section 2: Managing World Complexity with max\_objects\_per\_block**

One of the most common sources of confusion for administrators of modded servers is a recurring log message warning of a "suspiciously large amount of objects." This section provides an exhaustive analysis of the max\_objects\_per\_block parameter, explaining its purpose as a data integrity safeguard rather than a performance-tuning lever, and detailing the correct diagnostic and resolution procedures.

### **2.1. Anatomy of a Map Block: Nodes vs. Static Objects**

To understand this setting, one must first understand the basic composition of a Luanti world. The world is divided into 16x16x16 cubic chunks called "Map Blocks." Within these blocks, there are two fundamental types of content:

* **Nodes:** These are the simple, fundamental blocks that make up the terrain and structures, such as dirt, stone, or wood. They are computationally inexpensive.  
* **Static Objects (Entities):** These are more complex items that occupy a space within the world and have associated data and behaviors. Examples include chests (which must store inventory data), signs (which store text), and many mod-added items like complex machinery, pipes, or furniture. These are more resource-intensive than simple nodes.

### **2.2. The max\_objects\_per\_block Parameter**

The max\_objects\_per\_block setting in minetest.conf serves a single, critical function: it acts as a sanity check and safety limit on the number of individual static objects that can be saved within a single map block.16

* **Purpose:** Its primary role is to prevent situations that could lead to extreme, localized server lag or potential world database corruption. Such situations can arise from malfunctioning mods or player actions that create an extraordinary number of objects in a very small area. The server engine flags this as "suspicious" because it is an anomalous condition that deviates significantly from normal gameplay.17  
* **Default Value:** The default value for this parameter is 64\.16 For gameplay with the default Minetest Game or a light selection of mods, this limit is rarely, if ever, reached.  
* **Performance Impact:** It is crucial to understand that this setting itself does not directly impact server performance. The server's performance is affected by the *actual number of objects* it has to process. max\_objects\_per\_block is merely a threshold that, when crossed, triggers a diagnostic warning in the server logs. Treating it as a variable to be maximized in the hopes of improving performance is a misunderstanding of its function.

### **2.3. Diagnosing Density Issues: The "Suspiciously Large Amount of Objects" Warning**

The key symptom an administrator will encounter is a recurring error message in the server log or console that reads: ERROR\[...\] suspiciously large amount of objects detected: \[number\] in (\[X\],,\[Z\]).16

Decoding this message is the first step in diagnosis. The \[number\] indicates how many objects were found, and the coordinates (\[X\],,\[Z\]) specify the location. However, these are **map block coordinates**, not in-game node coordinates. To find the physical location in the world, these coordinates must be multiplied by 16\. For example, an error in map block (17, 1, 52\) corresponds to the 16x16x16 world area centered around the node coordinates (272, 16, 832).18 This is a non-obvious but vital piece of information for pinpointing the source of the issue.

### **2.4. Root Cause Analysis: How Mods Exceed Object Limits**

In nearly all cases, exceeding the default object limit is a direct consequence of using specific mods that are designed to place a high density of static objects in a small area.

* **Case Study: Storage Drawers:** The drawers mod is a classic and well-documented example.18 This popular storage mod allows players to build large walls of individual drawers. Each drawer, even a 4-slot variant, is a separate static object that must store its item data. A player building a large storage room can easily place over 100 of these drawer objects within the volume of one or two map blocks, reliably triggering the warning when the server attempts to save that area.18  
* **Other Potential Causes:** Other types of mods can also cause this issue. These include mods that add complex, multi-block machinery, extensive piping or logistics systems, or mods that result in a large number of dropped items on the ground.

### **2.5. Strategic Adjustments: Recommendations for Modifying the Limit**

Once the cause is understood to be legitimate mod usage rather than a bug, the solution is to adjust the limit. This is done by adding or modifying the following line in minetest.conf:  
max\_objects\_per\_block \= \<new\_value\>.16  
The recommended approach is not to set an arbitrarily high value, but to increase it strategically.

* **Incremental Increases:** Observe the number of objects reported in the error message and set the new limit to a value comfortably above it. For instance, if the server reports 121 objects, setting the limit to 256 is a reasonable and safe adjustment that provides headroom for future expansion.16 This method silences the warning for legitimate use cases without completely disabling this important safety check.

### **2.6. Advanced Diagnostics: Pinpointing Problematic Areas**

For administrators who wish to investigate further or manage world complexity proactively, several advanced tools are available.

* **Teleportation and Inspection:** Using the calculated node coordinates (map block coordinates \* 16), an administrator can teleport to the affected area to visually inspect the object density and confirm the cause.  
* **Analysis Mods:** The Luanti community has developed mods specifically for this purpose. Mods like "Admin Toolbox" can render the boundaries of a map block in-game, while "Advanced Rangefinder" can be used to list all entities within a specified radius, providing a precise count.16  
* **Direct Database Analysis:** For the most technically advanced administrators, it is possible to directly query the world's database file (map.sqlite). Using a Lua script with a library like maplib, one can iterate through all map blocks in the database and programmatically identify those with the highest object counts, allowing for proactive management of world complexity.16

## **Section 3: Advanced Memory and Performance Optimization**

A common misconception among server administrators, particularly those coming from other platforms, is that allocating more RAM is a universal solution to performance problems.19 In Luanti, server performance is a more nuanced interplay between CPU, RAM, and disk I/O. Effective optimization requires understanding this relationship and using the engine's configuration options to balance these resources according to the server's specific hardware and workload.

### **3.1. The Luanti Performance Triangle: CPU, RAM, and Disk I/O**

Luanti server performance is fundamentally constrained by three hardware components, each with a distinct role.

* **CPU (Single-Thread Performance):** The Luanti server is predominantly a single-threaded application. Critically, all Lua code—which includes nearly all mod logic, Active Block Modifiers (ABMs), and entity behaviors—runs within a single main thread.20 This has a profound implication for hardware selection: a CPU with very high single-core clock speed and instructions-per-clock (IPC) will yield better performance than a CPU with many slower cores. The primary exception to this rule is map generation. The C++-based map generator can be configured to use multiple threads via the  
  num\_emerge\_threads setting, but the core gameplay loop remains single-threaded.20  
* **RAM (Cache and Headroom):** The server's RAM is used to hold all loaded mod data, player data, and, most importantly, to act as a cache for world data.20 When a player enters an area, the corresponding map blocks are loaded from the disk into RAM. Keeping frequently accessed blocks in RAM significantly reduces the need for slow disk reads. Therefore, the role of RAM is less about raw capacity and more about providing sufficient headroom for this caching mechanism to function effectively.  
* **Disk I/O (Database Operations):** A Luanti world is stored in a database file, typically map.sqlite.16 Every time a new map block is loaded or an existing one is saved, the server must perform a disk read or write operation. Server performance is therefore highly sensitive to the random read/write speed of the storage drive. A slow hard disk drive (HDD) can become a major bottleneck, causing stuttering and lag as the server struggles to load world data quickly enough for exploring players.20 This makes a solid-state drive (SSD) one of the most impactful hardware upgrades for a Luanti server.

### **3.2. Configuring the Server's Memory Cache: The Role of server\_unload\_unused\_data\_timeout**

The single most important memory-related setting for performance tuning is server\_unload\_unused\_data\_timeout. This parameter directly controls the trade-off between RAM usage and disk I/O.

* **Function:** This setting defines, in seconds, how long the server will keep an unused map block in RAM before unloading it to free up memory.  
* **Tuning for Performance:** This setting allows an administrator to leverage their hardware's strengths.  
  * **High RAM, Slow Disk:** If a server has a large amount of RAM (e.g., 16 GB or more) but is running on a slower HDD, this value should be increased significantly. Setting it to 600 (10 minutes), 1000, or even 86400 (24 hours) effectively transforms the spare RAM into a massive, persistent disk cache.20 This dramatically reduces disk reads, as map blocks for frequently visited areas will almost always be served from fast RAM instead of the slow disk.  
  * **Low RAM:** Conversely, on a memory-constrained system (e.g., a small VPS with 2-4 GB of RAM), this value should be kept low (or at its default). This will cause the server to unload data more aggressively, freeing up precious RAM at the cost of more frequent disk access.

### **3.3. A Comprehensive Guide to Performance-Critical Settings**

Beyond memory caching, several other parameters in minetest.conf are critical for fine-tuning server performance. The following table provides a reference for these key settings.

| Parameter Name | Purpose | Default Value | Tuning Considerations & Impact |
| :---- | :---- | :---- | :---- |
| server\_unload\_unused\_data\_timeout | Time in seconds to keep unused map blocks in RAM cache. | 28 | **Primary memory tuning lever.** Increase significantly on servers with high RAM and slow disks to reduce disk I/O. Decrease on low-RAM servers to free memory faster.20 |
| active\_block\_range | Radius (in map blocks) around a player where entities are active and ABMs run. | 3 | Reducing this (e.g., to 2 or 1\) can **significantly lower CPU load** from mods, especially with many players. The trade-off is that mobs and machines will "freeze" closer to the player.22 |
| num\_emerge\_threads | Number of CPU threads dedicated to map generation. | 1 | On multi-core CPUs, increasing this (e.g., to 2 or 4\) can **speed up new chunk generation** during exploration, reducing lag spikes. This is one of the few multi-threaded operations.20 |
| max\_block\_send\_distance | Maximum distance (in map blocks) the server sends new terrain to clients. | 9 | Lowering this (e.g., to 6\) **reduces server upload bandwidth usage** and can alleviate network-related lag, at the cost of a shorter client-side view distance.22 |
| max\_simultaneous\_block\_sends\_server\_total | Total number of map blocks the server can send across all clients simultaneously. | (Varies) | Increasing this can allow the world to load faster for many players on a high-bandwidth connection. Decreasing it can prevent network saturation on slower connections.20 |
| sqlite\_synchronous | Controls the safety level of database writes. | 2 (Full) | **High-risk setting.** Changing to 0 (Off) disables certain write-to-disk confirmations, which can dramatically increase database write speed but carries a risk of data corruption on a server crash. Use with extreme caution and robust backup procedures.23 |

### **3.4. Diagnosing Performance Issues**

Effective tuning requires accurate diagnosis. Luanti provides essential built-in tools for this purpose.

* **The Debug HUD (F5):** By pressing the F5 key, players can access a debug screen. The most important metric for a server administrator is max\_lag. This value represents the maximum time the server took to process a single step in the last few seconds. A healthy, responsive server will have a max\_lag value near 0.1. If this value is consistently above 1.0, the server is experiencing significant server-side lag. Values above 10.0 indicate a critically overloaded server.20  
* **System Monitoring Tools:** On Linux, using a command-line tool like htop is invaluable. By observing the CPU usage of the minetestserver process, an administrator can quickly identify a CPU bottleneck. Because the main loop is single-threaded, if a single CPU core is pegged at or near 100% utilization, the server is CPU-bound, and further optimization should focus on reducing mod-induced load (e.g., by lowering active\_block\_range).20

### **3.5. Advanced Technique: Implementing a RAM Disk**

For administrators managing high-performance servers with a large amount of RAM, the ultimate method to eliminate the disk I/O bottleneck is to run the world database from a RAM disk. This advanced technique involves creating a ramfs or tmpfs filesystem that resides entirely in the system's RAM. The server's world folder is then mounted to this RAM disk.24

This requires careful implementation of startup and shutdown scripts. On server start, the script must copy the world data from persistent storage (the SSD/HDD) into the RAM disk. During operation, all reads and writes happen at RAM speed. Crucially, on server shutdown, the script must copy the world data from the RAM disk back to persistent storage to save all changes. This method offers unparalleled performance but carries the significant risk of data loss in the event of a power outage or ungraceful server crash.24

## **Section 4: Implementing Automated Player Activity Policies**

Managing idle or "Away From Keyboard" (AFK) players is a common requirement for public servers, whether to free up player slots, reduce passive resource consumption, or prevent players from dying while inactive. Unlike some other game server platforms, the core Luanti engine does not provide any built-in functionality for managing AFK players. This capability is handled exclusively through server-side mods.

### **4.1. Engine Limitations: No Built-in AFK Management**

It is important to state clearly that no setting in minetest.conf can be used to automatically disconnect idle players.25 Administrators seeking this functionality must install one or more mods designed for this purpose. The Luanti modding community has produced several solutions, with the ecosystem evolving from simple, monolithic mods to a more sophisticated, API-driven approach.

### **4.2. Survey of AFK Management Solutions**

The modern, recommended method for AFK management in Luanti is a modular system. This approach separates the task of *detecting* AFK status from the task of *acting* on that status, providing greater flexibility and interoperability between mods. Instead of every mod needing to invent its own method for tracking player inactivity, they can all rely on a single, authoritative API.

* **AFK Indicator (The API):** This mod is the foundation of the modern ecosystem. Its sole purpose is to monitor player actions (movement, digging, chatting, etc.) and maintain an accurate record of how long each player has been idle. It performs no actions itself but provides a clean, reliable API for other mods to query a player's AFK status and duration.26 This is a dependency mod; it must be installed for the other "action" mods to function.  
* **AFK Kick (AFK Indicator) (The Action Mod):** This is the primary mod for administrators who want to automatically disconnect idle players. It uses the AFK Indicator API to check player idle times and will kick any player who exceeds a configurable threshold.26  
* **AFK Protective Kick (A Specialized Action Mod):** This mod showcases the power of the modular system. It also uses the AFK Indicator API, but for a different purpose. It will only kick a player who is both AFK *and* in a dangerous situation, such as taking damage from lava, drowning in water, or starving.27 This prevents players from logging back in to find they have died while away, without kicking players who are safely idle.

This API-driven architecture allows for novel combinations. For example, the Interest for Unified Money mod also uses the AFK Indicator API, likely to prevent AFK players from earning passive income.26

### **4.3. In-Depth Guide: Installation and Configuration**

Implementing an AFK kick policy requires installing and enabling the appropriate mods.

1. **Installation:** Mods are installed by downloading their folders and placing them into the server's mods directory. For a system-wide installation on Linux, this is often /var/games/minetest-server/.minetest/mods/.8 For a portable build, it is the  
   mods folder within the main server directory.28 To implement a standard AFK kick system, an administrator would need to install both the  
   AFK Indicator mod and the AFK Kick (AFK Indicator) mod.  
2. **Enabling the Mods:** After the files are in place, the mods must be enabled for the specific world. This is typically done by editing the world.mt file in the world's directory and setting the corresponding load\_mod\_\* entries to true.7 For example:

   load\_mod\_afk\_indicator \= true  
   load\_mod\_afk\_indicator\_kick \= true  
3. **Configuration:** Configuration for these mods is **not** handled within minetest.conf. Each mod will have its own configuration method, which should be detailed in its README.md file or on its ContentDB page.25 While the specific settings for the modern mods are not detailed in the available research, based on common features and requests, administrators should expect to find options for:  
   * **Kick Timer:** The duration of inactivity, in seconds, before a player is kicked. A common default is 300 seconds (five minutes).25  
   * **Kick Message:** A customizable message that is shown to the player as the reason for their disconnection.  
   * **Privilege Exemption:** The ability to specify a privilege (e.g., afk\_exempt) that prevents players who have it (such as administrators and moderators) from being kicked.  
   * **Conditional Kicking:** A frequently requested feature is the ability to only kick AFK players when the server is at or near its maximum player capacity, ensuring that idle players are not removed unless their slot is needed by an active player.25

## **Conclusion**

Effective Luanti server administration is an exercise in informed, strategic management rather than the application of a single set of "best" settings. The analysis of object density, memory utilization, and player activity policies reveals a highly configurable engine that rewards a deep understanding of its core mechanics.

The max\_objects\_per\_block parameter should be viewed not as a performance knob, but as a valuable diagnostic tool signaling areas of high world complexity, typically driven by specific mods. Its adjustment should be a deliberate response to these signals, not a preemptive, arbitrary increase.

True performance optimization hinges on mastering the Luanti Performance Triangle—the interplay of single-threaded CPU speed, RAM used as a dynamic cache, and the random-access speed of disk I/O. The server\_unload\_unused\_data\_timeout setting is the primary lever for balancing these resources, allowing an administrator to mitigate their hardware's specific bottlenecks. Continuous monitoring of server health, primarily through the max\_lag metric, is essential for diagnosing issues and validating the impact of configuration changes.

Finally, community management features, such as policies for idle players, are not native to the engine but are capably handled by a sophisticated and evolving modding ecosystem. The modern, API-driven approach to AFK management exemplifies the community's trend towards creating flexible, interoperable, and powerful tools.

Ultimately, a successful Luanti server is the product of a continuous cycle: monitoring performance, diagnosing the root causes of issues through logs and in-game tools, and making precise, data-driven adjustments to the configuration. By embracing this methodology, an administrator can move beyond reactive problem-solving and proactively cultivate a server environment that is both stable and responsive to the needs of its player base.

#### **Obras citadas**

1. Luanti | Open source voxel game engine, fecha de acceso: septiembre 25, 2025, [https://www.luanti.org/](https://www.luanti.org/)  
2. Luanti Documentation: Main Page, fecha de acceso: septiembre 25, 2025, [https://docs.luanti.org/](https://docs.luanti.org/)  
3. Minetest.conf | Luanti Documentation, fecha de acceso: septiembre 25, 2025, [https://docs.luanti.org/for-players/minetest-conf/](https://docs.luanti.org/for-players/minetest-conf/)  
4. Setting Up and Managing a Minetest Mineclone2 Server on Debian-based Systems, fecha de acceso: septiembre 25, 2025, [https://habitus.blog/minetest-mineclone2-server-on-debian-based-systems](https://habitus.blog/minetest-mineclone2-server-on-debian-based-systems)  
5. minetest.conf, fecha de acceso: septiembre 25, 2025, [https://wiki.minetest.org/Minetest.conf](https://wiki.minetest.org/Minetest.conf)  
6. List of all available options for "minetest.conf"? \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=29603](https://forum.luanti.org/viewtopic.php?t=29603)  
7. Minetest Server Setup Thread \- FreedomBox Forum, fecha de acceso: septiembre 25, 2025, [https://discuss.freedombox.org/t/minetest-server-setup-thread/2738](https://discuss.freedombox.org/t/minetest-server-setup-thread/2738)  
8. Setting up a server/Debian \- Minetest, fecha de acceso: septiembre 25, 2025, [https://wiki.minetest.org/Setting\_up\_a\_server/Debian](https://wiki.minetest.org/Setting_up_a_server/Debian)  
9. what's the use of minetest.conf.example \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=21547](https://forum.luanti.org/viewtopic.php?t=21547)  
10. Configuring a Server \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=7278](https://forum.luanti.org/viewtopic.php?t=7278)  
11. How to use systemd units to run multiple Minetest server instances on one node, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=29993](https://forum.luanti.org/viewtopic.php?t=29993)  
12. Settings in minetest.conf \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=15656](https://forum.luanti.org/viewtopic.php?t=15656)  
13. Best practice: Mod configuration \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=18150](https://forum.luanti.org/viewtopic.php?t=18150)  
14. minetest.settings \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=22810](https://forum.luanti.org/viewtopic.php?t=22810)  
15. Setting up a server \- Minetest, fecha de acceso: septiembre 25, 2025, [https://wiki.minetest.org/Setting\_up\_a\_server](https://wiki.minetest.org/Setting_up_a_server)  
16. suspiciously large amount of objects detected \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=17649](https://forum.luanti.org/viewtopic.php?t=17649)  
17. \[Mod\] Micronodes \[0.1.0\] \[micronode\] \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=9003](https://forum.luanti.org/viewtopic.php?t=9003)  
18. \[Mod\] \[MTG/MCL2\] Storage Drawers \[0.6.2\] \[drawers\] \- Page 5 \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=17134\&start=100](https://forum.luanti.org/viewtopic.php?t=17134&start=100)  
19. Why Forcing Your Minecraft Server to Use More RAM Won't Fix Performance Issues \- Knowledgebase | Bananaservers, fecha de acceso: septiembre 25, 2025, [https://bananaservers.ca/index.php?rp=/knowledgebase/95/Why-Forcing-Your-Minecraft-Server-to-Use-More-RAM-Wonandsharp039t-Fix-Performance-Issues.html](https://bananaservers.ca/index.php?rp=/knowledgebase/95/Why-Forcing-Your-Minecraft-Server-to-Use-More-RAM-Wonandsharp039t-Fix-Performance-Issues.html)  
20. Optimised settings for \>100 concurrent users? \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=27463](https://forum.luanti.org/viewtopic.php?t=27463)  
21. Minetest Forums • View topic \- Advanced MT Server performance settings: Hardware, fecha de acceso: septiembre 25, 2025, [https://sorcerykid.github.io/minetest-forums/pages/10\_22561.htm](https://sorcerykid.github.io/minetest-forums/pages/10_22561.htm)  
22. Reducing Server lag \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.minetest.net/viewtopic.php?t=8736](https://forum.minetest.net/viewtopic.php?t=8736)  
23. Server performance settings \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=1825](https://forum.luanti.org/viewtopic.php?t=1825)  
24. Minetest on Ubuntu as service (with RAMDISK and backups) \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=9588](https://forum.luanti.org/viewtopic.php?t=9588)  
25. \[Mod\] Afk Kick \[afkkick\] – Automatically kick afk players \- Luanti Forums, fecha de acceso: septiembre 25, 2025, [https://forum.luanti.org/viewtopic.php?t=10919](https://forum.luanti.org/viewtopic.php?t=10919)  
26. AFK Indicator \- ContentDB, fecha de acceso: septiembre 25, 2025, [https://content.luanti.org/packages/Emojiminetest/afk\_indicator/](https://content.luanti.org/packages/Emojiminetest/afk_indicator/)  
27. AFK Protective Kick \- ContentDB, fecha de acceso: septiembre 25, 2025, [https://content.luanti.org/packages/Emojiminetest/afk\_protective\_kick/](https://content.luanti.org/packages/Emojiminetest/afk_protective_kick/)  
28. Getting Started \- Luanti / Minetest Modding Book \- rubenwardy, fecha de acceso: septiembre 25, 2025, [https://rubenwardy.com/minetest\_modding\_book/en/basics/getting\_started.html](https://rubenwardy.com/minetest_modding_book/en/basics/getting_started.html)