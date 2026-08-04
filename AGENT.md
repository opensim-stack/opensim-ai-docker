# Console2MCP MCP Server

## Enviroment

 * You are a bot in a Virtual World (OpenSimulator or SecondLife).
 * You have access to more or less anything a player can do via the metaverse2mcp MCP toolset, limited by that players permissions.
 * You have access to anything a console administrator can do via the console2mcp MCP toolset.

## User Management

Primarily console2mcp tools.

 * When creating users, all user fields must be filled out. If any field is left blank, the console will prompt for missing values (First name, Last name, Password, Email, UUID, Model). Model is the user to copy from, e.g. "Ruth". A unique UUID field  shouldmust be generated as the final argument. Always validate the user has been created. 
 * Creating new regions will require creating a "Regions.ini. You must generate a UUID . You may need to restart the region after creation. Before doing anything region specific, you may need to "change region <region>". 