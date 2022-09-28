# homer-scripts
A collection of scripts to to make homer awesome.
# Scripts
* proxmox-report.sh - get a list of running VM's on proxmox
* mikrotik-dhcp-leases.sh - grab current DHCP leases on your Mikrotik router.

# Installation
1. Grab the files!
    * Clone this repository.
    * Download the source code release either as a .zip/tar.gz
    * wget/curl the raw files :)
2. Place the files anywhere that can be executed by cron or Synology Scheduled Task
3. Create a env.cfg file using the env.cfg.example and save it in the same directory as the scripts.
4. Run either script to confirm they work!
5. Setup a cron or Synology Scheduled Task to output data to a static HTML file (See Examples)
6. Add an iframe on homer's message.
```
message:
  style: "is-dark" # See https://bulma.io/documentation/components/message/#colors for styling options.
  title: "Proxmox/Mikrotik Status"
  icon: "fa fa-grin"
  content: '<div class="message-body" style="text-align:center;">
                <iframe width="50%" height="100%" scrolling="no" src="/assets/tools/pm_status.html"></iframe>
            </div>
                        <div class="message-body" style="text-align:center;">
                <iframe width="50%" height="900px" scrolling="no" src="/assets/tools/mikrotik-dhcp-leases.html"></iframe>
            </div>
            '
```

# Notes
* The iframe using the message area is what I've decided to use, you can do anything you wish here.
* I created a separate page to hold the data as it makes it cleaner.

# Examples
## Running proxmox-report.sh via Synology Scheduled Task
* Navigate to Synology -> Control Panel -> Task Scheduler
* Click Create -> Scheduled Task -> User-defined Script
* Under Task Settings -> Run Command -> User-defined Script add the following
```
/home/homer-scripts/proxmox-report.sh > /volume1/@docker/volumes/90512614c76584595b92ae72f2f8f95fbd0d869ab64f61c29d1552349fe0b938/_data/tools
```
* /home/home-scripts = Location of this repositories scripts
* /volume1/@docker/volumes/90512614c76584595b92ae72f2f8f95fbd0d869ab64f61c29d1552349fe0b938/_data/tools = Location of docker container for homer's /assets/tools/ folder that is publically available.

## Running proxmox-report.sh via Cronjob on a *nix System
```
*/5 * * * * /home/homer-scripts/proxmox-report.sh > /home/homer/data/tools
```
* /home/home-scripts = Location of this repositories scripts
* /home/homer/data = Data folder for homer's /assets/tools/ folder that is publically available.

# ToDo
* More Proxmox information, list IP's, memory, CPU per instance and overall stats.
