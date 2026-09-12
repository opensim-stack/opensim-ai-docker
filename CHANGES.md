# Changes

This document changes between releases. At this early stage, these are more notes than anything else, but may be useful to others.

## Version 20260912

*Big* changes in how containers and configuration are managed. *After* upgrading spawner having let it run once ... 

 * Remove the spawner container again (and remove volumes)
 * Rename the volume `opensim-ai_spawner-data` to `opensim-ai_opensim-spawner-data`
 * Edit `/data/grids.json` in opensim-spawner container.
 * Set `containerIds: "[opensim-ai-mariadb]"`
 * Set `level: "STACK"`
 * Set`initialized: true`
 * Set `consoleUser` and `consolePass`.
 * Add `global` entries. `"MARIADB_HOST" : "%cfg.projectName-mariadb%-1"`, `"MARIADB_DATABASE" : "opensim"` and  `"MARIADB_USER" : "opensim"`.
 * Restart spawner container.
 * Disable all existing add-ons and re-enable.
 * Check Stacks page for any updates that need doing.