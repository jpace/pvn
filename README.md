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
    Compares two revisions, showing the changes in the size (length)
    of files that have been modified in the latter revision, to
    show the extent to which they have increased or decreased.

    The columns are:

    length in svn repository

    length in local version

    difference in line counts

    percentage, with the base being the lines in the svn revision.

    file name

    The total numbers are displayed as the last line.
    Added and deleted files are not included.

  * `status`:
    Prints the status for locally changed files.

  * `diff`:
    Shows changes to files.

  * `seek`:
    Searches through revision history for pattern match.

    This command looks through revisions and displays (a la grep) the most
    recent revision when the given pattern matched. In the case of the
    `--no-match` argument, the displayed revision is the most recent one in
    which the pattern did not match.

## AUTHOR

Jeff Pace (jeugenepace at gmail dot com)

http://www.github.com/jeugenepace/pvn
