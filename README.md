# Automation Scripts

### Bash

| Script              | Description                                                                                         | Latest Version |
| ------------------- | --------------------------------------------------------------------------------------------------- | -------------- |
| colors.sh           | Display some available styling for terminal outputs                                                 |                |
| file-backup.sh      | Create file copies using gzip. Automatically remove old backups. Useful for document/sqlite archive | B 0.2.3        |
| mysql-backup.sh     | Create mysql backups using mysqldump & gzip. Automatically remove old backups                       | 1.0.4          |
| php-sqlite-model.sh | Create db class model based on given sqlite database                                                | B 0.0.2        |

### PowerShell

| Script         | Description                                                                    | Latest Version |
| -------------- | ------------------------------------------------------------------------------ | -------------- |
| colors.ps1     | Display some available styling for terminal outputs                            |                |
| connect.ps1    | Shortcut for running remote connection commands like ssh                       | 1.0.0          |
| formatJson.ps1 | Convert JSON file between prettified and compressed                            |                |
| multi-php.ps1  | easily switch between php versions in cli                                      | 1.0.0          |
| ps-upgrade.ps1 | Manage Powershell version                                                      | 1.1.0          |
| spice.ps1      | Shortcut to spicetify scripts                                                  | 1.0.0          |
| winfind.ps1    | Recursively search for a filename in a directory                               |                |
| wingrep.ps1    | Recursively search for text in any file in a directory                         |                |
| vscode_ext.ps1 | Automate VSCode extension installation to sync extensions across installations | B 0.1.0        |

### Power User

- Windows: Add ability to run `.ps1` scripts from anywhere
  - Edit System Environment Variables
  - Add `.PS1` to `PATHEXT`
  - Add this directory to `PATH`
- Linux: Add ability to run `.sh` scripts from anywhere
  ```bash
  chmod +x ./*.sh
  echo -e "\nexport PATH=\"\$PATH:$(pwd)\"" >> ~/.bashrc
  source ~/.bashrc
  ```
