# Setup OneDrive RClone Remote

Create new remote: `rclone config`

```bash
e/n/d/r/c/s/q> n     # Add new remote
name> OneDrive       # Enter name of remote
Storage> onedrive    # Enter cloud provider
client_id>           # Leave blank, unless you know what to do
client_secret>       # Leave blank, unless you know what to do
region> global       # Specify region
# Edit advanced config?
y/n>                 # Leave blank for No (default)
# Use web browser to automatically authenticate rclone with remote?
y/n>                 # Leave blank for Yes (default)
# Do the login on web browser that pops up
config_type>         # Leave blank for default (onedrive)
config_driveid>      # Leave blank for default (<id>)
# Drive OK?
y/n>                 # Leave blank for Yes (default)
# Keep this "<name>" remote?
y/e/d>               # Leave blank for Yes this is OK (default)
e/n/d/r/c/s/q> q     # To quit
```

# Test Mount the RClone Remotes

- Make the directories if they don't exist: `mkdir -p ~/mnt/OneDrive/`
- Test the following remotes: `rclone mount --vfs-cache-mode full OneDrive:/ ~/mnt/OneDrive/`
- Press Ctrl+C to exit and then run the following to unmount if needed: `fusermount -u ~/mnt/OneDrive/`

# Re-authenticate Cloud Services

- `rclone config reconnect OneDrive:`

# Debug

- Stop all services
- `rm -rf ~/.cache/rclone` - Clear vfs cache
- Start all services

# Reload SystemD Daemon

- `sudo systemctl daemon-reload`
- `systemctl --user daemon-reload`

# OneDrive Cloud Service (User Service)

- `systemctl --user start rclonemount@OneDrive`
- `systemctl --user enable rclonemount@OneDrive`
- `systemctl --user status rclonemount@OneDrive`
- `systemctl --user stop rclonemount@OneDrive`
- `systemctl --user disable rclonemount@OneDrive`
- `systemctl --user restart rclonemount@OneDrive`
