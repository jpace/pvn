pvn(1) - Extended functionality for Subversion
==============================================

## SYNOPSIS

`pvn` subcommand [options] <files>

## DESCRIPTION

Pvn is a set of subcommands that extend `svn`, adding functionality inspired by
Git and Perforce.

Pvn supports revisions being specified as being relative to their "index" in the
list of Subversion revisions. "+n" means the nth revision in the list for a
given path, and "-n" is the nth from the last revision, where -1 means the last
revision.

Pvn differs from Subversion in that for all subcommands, file names are printed
in sorted order, improving legibility.

Output from some commands is cached, for speed.

### SUBCOMMANDS

For all subcommands, `pvn help <command>` shows extended information.

  * `log`:
    Prints log messages for files.

    The `log` subcommand works in pvn as it does with svn, except that output is
    colorized, differing for the elements (file, directory) and the status of
    the element (added, deleted, changed). The logging output also shows the
    relative revision.

  * `pct`:
    Compares revisions as a percentage of lines modified.

  * `status`:
    Prints the status for locally changed files.

  * `diff`:
    Shows changes to files.

  * `seek`:
    Searches through revision history for pattern match.

## AUTHOR

Jeff Pace (jeugenepace at gmail dot com)

http://www.github.com/jeugenepace/pvn
