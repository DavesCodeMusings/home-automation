# Home Assistant, ESPHome, Nginx, and Docker
A lot of people run Home Assistant for their home automation system. Quite a few of those people try to avoid "the cloud" and use only locally controlled devices. But I don't think a lot of folks run their Home Assistant in Docker containers. That's what this repository is for. It's a place where I share my configurations for Home Assistant, running in Docker containers, and avoiding cloud connections.

My focus is on minimalism and avoiding cloud connected devices. However, minimalism does not mean a lack of features. It is simply a careful consideration features and the effort required to maintain them.

## Hardware
My platform of choice is the Intel based mini PC. Next Unit of Computing (NUC) is what Intel called it. There are multiple manufacturers now. In these examples, I'm using an old Celeron J4005-based NUC with 8G of RAM and a 256G Western Digital Green SATA-attached solid-state drive. It's humming along happily, but that particular model is no longer manufactured. Any of the popular N100 CPU models available today should be more than capable.

## Operating System
I'm using Alpine Linux as my operating system. Everything I'm doing should be possible with Debian or Raspberry Pi OS. My preference for Alpine comes from its small footprint. Nearly everything I'm running is in a Docker container. All the underlying OS has to is run Docker and provide a few basic services. Alpine can do that in an 8G root partition. In fact, it's using less than half of that.

## Basic Services
Here's a list of what I'm running on the Alpine OS beyond what is included in the base installation.
* apcupsd - monitors and alerts on uninterruptable power supply (UPS) events
* dovecot - lets users access email with IMAP and POP3 clients
* exim - delivers mail locally
* lvm - allows the solid-state drive partitions to be easily organized and resized if needed
* monit - tracks system processes, sends alerts, and in some situations makes repairs automatically
* slapd - provides a single username and password option for applications that support LDAP authentication
* smartd - monitors solid state and spinning disk health, reporting potential problems

The main goal of this set of services (everything except for lvm and slapd) is to provide monitoring and notification. The secondary goal is to provide an easy user experience with one password to access all network services with LDAP authentication (slapd). Finally, lvm's logical volumes provide a safeguard against anything using up too much space on the root partition and crashing the system.

For help getting these services set up on Alpine, see the [Alpine Wiki Tutorials and HOWTOs](https://wiki.alpinelinux.org/wiki/Tutorials_and_Howtos). Specifically, the HOWTOs for [apcupsd](https://wiki.alpinelinux.org/wiki/Apcupsd), [Small-Time Email with Exim and Dovecot](https://wiki.alpinelinux.org/wiki/Small-Time_Email_with_Exim_and_Dovecot), and [OpenLDAP](https://wiki.alpinelinux.org/wiki/Configure_OpenLDAP).

Remaining services are all run in Docker containers.

## Docker and Docker Compose
Docker is one of a few ways to run containerized applications on Linux. Docker Community Edition is a well-established project that brings containers to the Linux OS.

### Why Docker?
The answer is simple: Docker Compose.

Docker Compose is included with the docker package. Using Docker Compose YAML files allows me to have a simple, well understood, and repeatable way to bring up services I want to run on my home automation system. Alternative methods for installing all seem to involve more manual effort and more risk of incompatibilities with operating sytem components. Granted, Docker is not without its own learning curve, but the idea of having installation documented and repeatable in a compose.yml file is why I choose Docker.

### Installing Docker on Alpine
To install Docker, I'm using the Alpine package called _docker_, which includes Docker Community Edition and supporting packages. It's installed with the command shown below.

```
apk update && apk add docker
```

Once this is done, verify by showing the help output for the main commands we'll be using. Abbreviated output is shown below.

```
alpine:~# docker --help
Usage:  docker [OPTIONS] COMMAND
A self-sufficient runtime for containers

alpine:~# docker compose --help
Usage:  docker compose [OPTIONS] COMMAND
Define and run multi-container applications with Docker
```

### Creating a Home for Compose Projects
Docker Compose reads its configuration from a YAML file, named compose.yml, in a directory. The directory exists to provide separation between projects and can also hold other files and subdirectories. I'm using this Compose project directory to store persistent data alongside the compose.yml for easy organization.

I put my Docker Compose projects in the parent directory of _/var/lib/docker/compose_ and give the _docker_ group write permissions. You can put it wherever you want. I chose _/var/lib/docker/compose_ to keep all Docker related things together on the same logical volume.

My Compose project directory looks like this:

```
alpine:/var/lib/docker/compose# ls -1
file-sharing/
gitea/
homeassistant/
jellyfin/
ldapinator/
nginx/
pihole/
portainer/
```

Most of the directory names match up with easily recognizable open source projects, like _homeassistant_, _nginx_, _pihole_, etc. This list simply shows what is possible with a single, budget mini-pc. For the remainder of this HOWTO, we'll focus on the _homeassistant_ and _nginx_ compose projects.

#### Grouping Everything Home Assistant Related
Inside the homeassistant directory, there are a handful of files and subdirectories.

```
alpine:/var/lib/docker/compose/homeassistant# ls -1
compose.yml
esphome/
hass/
setup.sh*
```

Starting from the bottom, setup.sh is a shell script I'm using to create and populate the necessary subdirectories. It also creates the compose.yml, though this is simply for the convenience of having everything in one file.

The _hass_ subdirectory contains the _config_ directory where Home Assistant stores its persistent data. The _esphome_ subdirectory is similar in that it contains a single _config_ directory where ESPHome stores its YAML for various devices and their secrets. Having this persistent data grouped under the hass project directory organizes things and makes backup and recovery easier.

Finally, there is the compose.yml file itself. This lets Docker Compose know what options to use when starting up the containers.

#### Grouping Nginx Configs
Inside the nginx directory, there is a similar arrangement of compose.yml and persistent data. Though with Nginx, the configuration directory is called _conf.d_ and it contains bits of the overall configuration grouped as individual files. There is no difference between this and the way Nginx would be configured if it were installed as an Alpine package.

### Creating the Project Directories and Compose Files
The [setup.sh](https://github.com/DavesCodeMusings/home-automation/blob/main/homeassistant/setup.sh) file in this repository's _homeassistant_ directory can be used to create the directory structure and compose.yml file for the Home Assistant and ESPHome containers. Simply download it into the directory where you want Home Assistant to live and run setup.sh from there.

For example:

```
alpine:/var/lib/docker/compose# mkdir homeassistant
alpine:/var/lib/docker/compose# cd homeassistant
alpine:/var/lib/docker/compose/homeassistant# wget https://raw.githubusercontent.com/DavesCodeMusings/home-automation/refs/heads/main/homeassistant/setup.sh
alpine:/var/lib/docker/compose/homeassistant# sh ./setup.sh
```
