SteamServerQuery - A small Windows commandline utility that outputs Steam game server query request data to a CSV file
- Latest version: SteamServerQuery_v1.0 (2020-06-28)
- By Phoenix125 | http://www.Phoenix125.com | http://discord.gg/EU7pzPs | kim@kim125.com

----- FEATURES -----
- Writes a CSV file containing all output data from a Steam Game Server Query Request
- Data includes number of online players, max players, and server name

----- INSTRUCTIONS -----
- In Windows command prompt, execute SteamServerQuery "ip:port"
ex:
SteamServerQuery "127.0.0.1:30001"
- NOTICE! For most servers, use the server's assigned query port +1
	Ex: If your server's query port is 30000, use 30001

----- OUTPUT -----
Creates a simple CSV file containing the entire reponse from a query request.
- Note: Output from servers vary depending on server.  Many fields will be blank.
- Visit https://developer.valvesoftware.com/wiki/Server_queries for details of reponse.

Sample SteamServerQuery.csv file:
=================================
Raw,0xFFFFFFFF49115078313235205465737420536572766572000045475300456D707972696F6E202D2047616C616374696320537572766976616C00000000080064770000333433343131323000B14E7500140667CD3A4001303B313B300090D8050000000000
Name,Px125 Test Server
Map,
Folder,EGS
Game,Empyrion - Galactic Survival
ID,
Players,0
Max Players,8
Bots,0
Server Type,d
Environment,w
Visibility,0
VAC,0
Version,34341120
Extra Data Field,Nu~g�:@0;1;0~��~~~~~
Note,In the Extra Data Field only: all hex characters [nul] 0x00 replaced with [~] 0x7E
Comment,Thank you. Visit https://github.com/phoenix125 for updates and/or more programs.
=================================

Thank you!

----- DOWNLOAD LINKS -----
Direct Download Link: http://www.phoenix125.com/share/7dtdMapFileAnalyzer/7dtdMapFileAnalyzer.zip
Source Code (AutoIT): https://github.com/phoenix125/7dtdMapFileAnalyzer
GitHub:	              https://github.com/phoenix125/7dtdMapFileAnalyzer

Website: http://www.Phoenix125.com
Discord: http://discord.gg/EU7pzPs
Forum:   https://phoenix125.createaforum.com/index.php

----- VERSION HISTORY -----
(2020-06-28) v1.0.0 Initial release
