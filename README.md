# CM (Container Multiplexer)

Manage multiple Docker containers (hundreds of them, if you want) with SSH access and simple tmux integration. Each instance gets its own SSH port and persistent workspace directory.

## Quick Start

```bash
./cm start 1        # Start a single container
./cm ssh 1          # SSH into it
./cm stop 1         # Stop it

# Or work with many container instances at once
./cm start 1-12     # Start twelve container instances (001-012)
./cm pan 1-6        # Tmux session with split panes, each SSH'd
./cm broadcast on   # Send keystrokes to all panes in a session
```

## Setup

1. Add your SSH public key to an `authorized_keys` file in the project root:
   ```bash
   cat ~/.ssh/id_ed25519.pub > authorized_keys
   ```

2. Install Python Docker library (`cm` does not use any docker subprocess):
   ```bash
   sudo apt install python3-docker
   ```

3. Build the base image (you need docker & docker compose installed):

   ```bash
   # Build bootstrap image
   docker build --no-cache -t cm-bootstrap:latest -f Dockerfile.base .

   # Run interactively to make changes if desired
   docker run -it --user me --name cm-auth cm-bootstrap:latest /bin/bash

   # Commit container as base image
   docker commit cm-auth cm-base:latest
   docker rm cm-auth
   ```

4. Build runtime image:
   ```bash
   docker build -t cm .
   ```

## Configuration

### SSH Config

Add to your `~/.ssh/config`:

```
Host cm
    HostName localhost
    User me
    IdentityFile ~/.ssh/id_ed25519
```

### Bash Completion

```bash
./cm autocomplete >> ~/.bashrc
source ~/.bashrc
```

### Add `cm` to PATH
Copies the python script to `~/.local/bin/` (or a specified directory) with symlinks for `authorized_keys` and `workspaces/`.  
Re-run after a `git pull` to update.
```bash
./install.sh
```

## Usage
Use `-h` for each argument to explore more
```
cm -h
usage: cm [-h] {start,stop,restart,ssh,list,logs,pan,win,kill,broadcast,autocomplete} ...

Manage CM instances

positional arguments:
  {start,stop,restart,ssh,list,logs,pan,win,kill,broadcast,autocomplete}
    start               Start instance(s)
    stop                Stop instance(s)
    restart             Restart instance(s)
    ssh                 SSH into an instance
    list                List all instances
    logs                Show logs for an instance
    pan                 Open tmux session with SSH panes
    win                 Open tmux session with SSH windows
    kill                Kill cm tmux session(s)
    broadcast           Toggle synchronized input to all panes
    autocomplete        Print bash completion script

options:
  -h, --help            show this help message and exit
  ```

Example commands
```bash
# Start/stop
cm start 1          # Start a single instance
cm start 1-400      # Start 400 container instances (!)
cm stop 1           # Stop a specific instance
cm stop all         # Stop all running instances
cm restart all      # Restart all running instances

# Connect
cm list             # List all instances with status
cm ssh 1            # SSH into an individual instance
cm logs 1           # View container logs ala "docker logs"

# Tmux sessions (for working with many container instances)
cm pan 1-9          # Use split panes, each SSH'd to an instance
cm pan 1-9 --sync   # Same, with synchronized input (broadcast on)
cm win 1-2          # Use tmux windows instead of panes
cm kill             # Kill sessions (ALL by default, with confirmation)
cm broadcast on     # Enable synchronized input across sessions
```

## Architecture

```
cm-bootstrap:latest  →  cm-base:latest  →  cm:latest
(Debian + tooling)      (+ mods)           (+ entrypoint)
```
- **Multithreading**: Instance operations run in parallel for fast execution
- **SSH Ports**: 2201, 2202, ... (2200 + N): auto-retries if port in use; do not assume the port number is aligned with the container instance ID
- **Workspaces**: `workspaces/cm.001/`, `workspaces/cm.002/`, ... (mounted at `/home/me/workspace`)
- **Tmux 's'essions**: `cm-s1`, `cm-s2`, ... (created by `pan`/`win` commands)


## Rebuilding Images

```bash
# After changing Dockerfile.base (rare)
docker build --no-cache -t cm-bootstrap:latest -f Dockerfile.base .
# Then commit to cm-base:latest

# After changing Dockerfile or entrypoint.sh (fast, uses cm-base cache)
docker build -t cm .
```
