# Home Assistant, ESPHome, Nginx, and Docker
A lot of people run Home Assistant for their home automation system. Quite a few of those people try to avoid "the cloud" and use only locally controlled devices. But I don't think a lot of folks run their Home Assistant in Docker containers. That's what this repository is for. It's a place where I share my configurations for Home Assistant, running in Docker containers, and avoiding cloud connections.

## The Hardware
My platform of choice is the Intel based mini PC. Next Unit of Computing (NUC) is what Intel called it. There are multiple manufacturers now. In these examples, I'm using an old Celeron J4005-based NUC with 8G of RAM and a 256G Western Digital Green SATA-attached solid-state drive. It's humming along happily, but that particular model is no longer manufactured. Any of the popular N100 CPU models available today should be more than capable.

## The Operating System
I'm using Alpine Linux as my operating system. Everything I'm doing should be possible with Debian or Raspberry Pi OS. My preference for Alpine comes from its small footprint. Nearly everything I'm running is in a Docker container. All the underlying OS has to is run Docker and provide a few basic services. Alpine can do that in an 8G root partition. In fact, it's using less than half of that.

## Docker and Docker Compose
