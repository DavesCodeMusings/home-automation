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
* monit - tracks system processes, sends alerts, and in some situations makes repairs automatically
* slapd - provides a single username and password option for applications that support LDAP authentication
* smartd - monitors solid state and spinning disk health, reporting potential problems

The main goal of this set of services (everything except for slapd) is to provide monitoring and notification. The secondary goal is to provide an easy user experience with one password to access all network services with LDAP authentication (slapd).

For help getting these services set up on Alpine, see the [Alpine Wiki Tutorials and HOWTOs](https://wiki.alpinelinux.org/wiki/Tutorials_and_Howtos). Specifically, the HOWTOs for [apcupsd](https://wiki.alpinelinux.org/wiki/Apcupsd), [Small-Time Email with Exim and Dovecot](https://wiki.alpinelinux.org/wiki/Small-Time_Email_with_Exim_and_Dovecot), and [OpenLDAP](https://wiki.alpinelinux.org/wiki/Configure_OpenLDAP).

Remaining services are all run in Docker containers.

## Docker and Docker Compose
To install Docker, I'm using the Alpine package called _docker_, which includes Docker Community Edition and supporting packages. It's installed with the command shown below.

```
apk update && apk add docker
```
