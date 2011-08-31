# SM Framework Extension Development Notes

## Requirements

SM Framework Extensions must:

  Never rely on or use SM Framework internal functions.

  Use as many api's as possible to get the job done. This takes advantage of the
  carefully thought out checks provided by the core APIs

## Distributing Single Extensions (one)

Single extensions are stored, packaged and distributed with the following format:

    sm_{extension name}-{extension version}

Followed by a suffix corresponding to the distribution method (git/tar/...)
Notice the '\_' separator character.

This extracts to a single directory containing all of the expected extension
artifacts (bin/ config/ shell/ ...)

Single extensions may be installed via the 'ext' command line interface (cli):

    root# sm ext install deploy git://github.com/sm/sm_deploy.git

This command will install the sm\_deploy extension from the github repository
into an extension named 'deploy'. After this command has been run, a user may
then use the deploy extension:

    user$ sm deploy


## Distributing Sets of Extensions (many)

Sets of extensions (many) Single extensions are stored, packaged and distributed with the following format:

    sm-{extension name}-{extension version}

Followed by a suffix corresponding to the distribution method (git/tar/...)
Notice the '-' separator character.

This extracts to a single directory containing one or more subdirectories.
Each subdirecotry corresponds to a single extension directory. Within the
single extension direcotry all of the expected extension artifacts will be found
(bin/ config/ shell/ ...)

Extension sets may be installed via the 'sets' command line interface (cli):

    root# sm set install servers git://github.com/sm/sm-servers.git

This command will install the sm-servers extension set from the given github
repository into an extension set named 'servers'. After this command has been
run, a user may then use any of the extensions provided within the set:

    root# sm nginx install
    root# sm nginx start

## Extension Basics

Fundamentially an extension is nothing more than a namespaced collection
(directory) of binary files and/or shell scripts with the ability to map cli
routes directly to shell functions (map).

### Actions

### Mapped Actions

### Config


