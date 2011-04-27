# Bash Delectable Scripting Management (BDSM) Framework Roadmap

Features Roadmap
====================

## Add documentation
* For each bash Module DSL function

## Customizable extension installation
* Install extension-head from a given repository url.
* Install extension-$version from a given url.

## Extension distribution
* extensions.beginrescueend.com
  * API for publishing extensions
  * Interface for browsing published extensions.

## Package (pkg) extension and module
* Package activation and deactivation
  $ bdsm pkg {activate/deactivate} {package}

## Service (srv) extension and module
* Overridable start/stop/restart/status actions ala package_install
* init scripts
* activate/deactivate -- autostart on boot
  $ bdsm srv {activate/deactivate} {service}

