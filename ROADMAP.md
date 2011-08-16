# Benevolent Delectable S{cripting,ystem} Manager (BDSM) Framework (Core)

## Roadmap

Features Roadmap
====================

### Add documentation
* For each bash Module DSL function.

### Customizable extension installation
* Install extension-head from a given repository url.
* Install extension-$version from a given url.

### Extension distribution
* extensions.beginrescueend.com
* API for publishing extensions.
* Interface for browsing published extensions.

### Service (svc) extension and module
* Overridable start/stop/restart/status actions, à la package_install.
* Init scripts.
* Activate/deactivate -- autostart on boot.
  $ sm svc {activate/deactivate} {service}
