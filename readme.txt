SteamServerQuery - A small Windows commandline utility that outputs Steam game server query request data to screen, CSV, or text file.
- Latest version: SteamServerQuery_v1.4 (2020-08-11)
- By Phoenix125 | http://www.Phoenix125.com | http://discord.gg/EU7pzPs | kim@kim125.com

----- FEATURES -----
- Run via command line
- Gets the response of a Steam Game Server Query.
- Data aquired includes: number of online players, max players, server name, map name, and more.
- Outputs the data to any of the following:
	- CSV with or without labels
	- Text File with or without labels
	- Command line output with or without labels

----- INSTRUCTIONS -----
- Run in Command Prompt

Use: SteamServerQuery {options} IP:port
  or: SteamServerQuery {options} URL:port

-h = Displays this help text
-pw = Print output to commandline with labels
-po = Print output to commandline WITHOUT labels
-tw = Write output to txt file with labels to [E:\\SteamServerQueryLabel.txt]
-to = Write output to txt file WITHOUT labels to [E:\\SteamServerQueryNOLabel.txt]
-cw = Write output to csv file with Labels to [E:\\SteamServerQueryLabel.csv]
-co = Write output to csv file WITHOUT labels to [E:\\SteamServerQueryNOLabel.csv]

Example 1: SteamServerQuery -pw -co 127.0.0.1:26500
Example 2: SteamServerQuery -to phoenix125.com:26500

NOTICE! For many servers, use Query Port +1
   Ex: If query port is 30000, use 30001

Thank you. Visit https://github.com/phoenix125 for updates and/or more programs.

- NOTICE! For many servers, use the server's assigned query port +1
	Ex: If your server's query port is 30000, use 30001

----- OUTPUT -----
Creates a simple CSV file containing the entire response from a Steam query request.
- Note: Output from servers vary depending on server.  Many fields will be blank.
- Visit https://developer.valvesoftware.com/wiki/Server_queries for details of reponse.

==========================
Sample Output with Labels
==========================
Raw,0xFFFFFFFF49115078313235205465737420536572766572000045475300456D707972696F6E202D2047616C616374696320537572766976616C00000000080064770000333433343131323000B14E7500140667CD3A4001303B313B300090D8050000000000
Name,Px125 Test Server
Map,
Folder,EGS
Game,Empyrion - Galactic Survival
ID,0
Players,0
Max Players,8
Bots,0
Server Type,d
Environment,w
Visibility,0
VAC,0
Version,34341120
Extra Data Field,Nu~��g�:@�0;1;0~���~~~~~
Note,In the Extra Data Field only: all hex characters [nul] 0x00 replaced with [~] 0x7E
Comment,Thank you. Visit https://github.com/phoenix125 for updates and/or more programs.
=================================

Thank you!

----- DOWNLOAD LINKS -----
Direct Download Link: http://www.phoenix125.com/share/steamserverquery/SteamServerQuery.zip
Source Code (AutoIT): http://www.phoenix125.com/share/steamserverquery/SteamServerQuery.au3
GitHub:	              https://github.com/phoenix125/SteamServerQuery

Website: http://www.Phoenix125.com
Discord: http://discord.gg/EU7pzPs
Forum:   https://phoenix125.createaforum.com/index.php

----- VERSION HISTORY -----
(2020-08-11) v1.4 Fixed Error
- Fixed: Line 2667 error (Thanks to Linebeck for reporting)

(2020-07-08) v1.3 Added many more options
- Added: URL or IP can now be used.
- Added: Help information added.
- Added: Optional output data to TXT CSV and commandline, with or without header data.
- Fixed: Several minor bug fixes.

(2020-06-30) v1.2 Bugfix
- Fixed: The online/max player counts and gameID were not properly being converted to decimal.

(2020-06-28) v1.1 Bugfix
- Fixed: When the Pipe symbol | is in title, it would cause an error.

(2020-06-28) v1.0 Initial release