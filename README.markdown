PVN
===

Pvn adds functionality stolen and inspired by Perforce and Git, as well as just
things I conjured up.

What it isn't: a replace for svn (the command). The intent here is not to do
everything svn does, but better. Maybe some day that will happen.

SUMMARY
-------

    svn [ options ] file ...

FEATURES
--------

**Relative revisions**: Pvn supports revisions being specified as being relative
to their "index" in the list of svn revision. "+n" means the nth revision in
the list for a given path, and "-n" is the nth from the last revision, where
-1 means the last revision.

Thus for the following list of revisions for a path:

    r1947 | easter.bunny | 2011-11-14 07:24:45 -0500 (Mon, 14 Nov 2011) | 1 line
    r1714 | santa.claus | 2011-09-22 16:38:30 -0400 (Thu, 22 Sep 2011) | 1 line
    r1192 | santa.claus | 2011-09-05 03:51:04 -0400 (Mon, 05 Sep 2011) | 1 line
    r1145 | tooth.fairy | 2011-08-02 04:57:23 -0400 (Tue, 02 Aug 2011) | 1 line
    r1143 | santa.claus | 2011-07-29 07:51:49 -0400 (Fri, 29 Jul 2011) | 1 line
    r1049 | santa.claus | 2011-06-22 07:17:43 -0400 (Wed, 22 Jun 2011) | 1 line

Relative revision +0 is r1049, -1 is r1947, +1 is r1143, and so on.

**Colorized logging**. The "log" subcommand works in pvn as it does with svn,
except that output is colorized, differing for the elements (file, directory) and
the status of the element (added, deleted, changed). The logging output also
shows the relative revision.
