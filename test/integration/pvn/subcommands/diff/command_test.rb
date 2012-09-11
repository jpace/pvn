#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/diff/command'
require 'resources'
require 'stringio'

module PVN::Subcommands::Diff
  class CommandTest < PVN::TestCase

    def test_local_to_head

      explines = Array.new

      explines << "Index: AddedFile.txt"
      explines << "==================================================================="
      explines << "--- AddedFile.txt	(revision 0)"
      explines << "+++ AddedFile.txt	(revision 0)"
      explines << "@@ -0,0 +1,17 @@"
      explines << "+THE KNIGHT'S TALE"
      explines << "+WHILOM, as olde stories tellen us,"
      explines << "+There was a duke that highte Theseus. was called"
      explines << "+Of Athens he was lord and governor,"
      explines << "+And in his time such a conqueror"
      explines << "+That greater was there none under the sun."
      explines << "+Full many a riche country had he won."
      explines << "+What with his wisdom and his chivalry,"
      explines << "+He conquer'd all the regne of Feminie,"
      explines << "+That whilom was y-cleped Scythia;"
      explines << "+And weddede the Queen Hippolyta"
      explines << "+And brought her home with him to his country"
      explines << "+With muchel glory and great solemnity,"
      explines << "+And eke her younge sister Emily,"
      explines << "+And thus with vict'ry and with melody"
      explines << "+Let I this worthy Duke to Athens ride,"
      explines << "+And all his host, in armes him beside."
      explines << "Index: LICENSE"
      explines << "==================================================================="
      explines << "--- LICENSE	(revision 1950)"
      explines << "+++ LICENSE	(working copy)"
      explines << "@@ -1,19 +0,0 @@"
      explines << "-Copyright (c) 2009 WiQuery team"
      explines << "-"
      explines << "-Permission is hereby granted, free of charge, to any person obtaining a copy"
      explines << "-of this software and associated documentation files (the \"Software\"), to deal"
      explines << "-in the Software without restriction, including without limitation the rights"
      explines << "-to use, copy, modify, merge, publish, distribute, sublicense, and/or sell"
      explines << "-copies of the Software, and to permit persons to whom the Software is"
      explines << "-furnished to do so, subject to the following conditions:"
      explines << "-"
      explines << "-The above copyright notice and this permission notice shall be included in"
      explines << "-all copies or substantial portions of the Software."
      explines << "-"
      explines << "-THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR"
      explines << "-IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"
      explines << "-FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"
      explines << "-AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"
      explines << "-LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"
      explines << "-OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN"
      explines << "-THE SOFTWARE."
      # because we're reading the lines, then puts-ing them, each line gets a "\n"
      # explines << "\ No newline at end of file"
      explines << "Index: pom.xml"
      explines << "==================================================================="
      explines << "--- pom.xml	(revision 1950)"
      explines << "+++ pom.xml	(working copy)"
      explines << "@@ -7,7 +7,7 @@"
      explines << " 	<packaging>pom</packaging>"
      explines << " 	<version>1.5-SNAPSHOT</version>"
      explines << " 	<name>WiQuery Parent</name>"
      explines << "-"
      explines << "+        <!-- inserted comment -->"
      explines << " 	<scm>"
      explines << " 		<developerConnection>scm:svn:https://wiquery.googlecode.com/svn/branches/wicket-1.5</developerConnection>"
      explines << " 	</scm>"
      explines << "Index: wiquery-core/src/main/java/org/odlabs/wiquery/core/effects/EffectBehavior.java"
      explines << "==================================================================="
      explines << "--- wiquery-core/src/main/java/org/odlabs/wiquery/core/effects/EffectBehavior.java	(revision 1950)"
      explines << "+++ wiquery-core/src/main/java/org/odlabs/wiquery/core/effects/EffectBehavior.java	(working copy)"
      explines << "@@ -38,7 +38,6 @@"
      explines << "  */"
      explines << " public class EffectBehavior extends WiQueryAbstractBehavior"
      explines << " {"
      explines << "-"
      explines << " 	private static final long serialVersionUID = 3597955113451275208L;"
      explines << " "
      explines << " 	/**"
      explines << "@@ -49,17 +48,19 @@"
      explines << " 	/**"
      explines << " 	 * Builds a new instance of {@link EffectBehavior}."
      explines << " 	 */"
      explines << "-	public EffectBehavior(Effect effect)"
      explines << "-	{"
      explines << "-		super();"
      explines << "+	public EffectBehavior(Effect effect) {"
      explines << " 		this.effect = effect;"
      explines << " 	}"
      explines << " "
      explines << "+    public void newMethod() {"
      explines << "+        // a new method"
      explines << "+    }"
      explines << "+"
      explines << " 	@Override"
      explines << " 	public JsStatement statement()"
      explines << " 	{"
      explines << "-		JsQuery query = new JsQuery(getComponent());"
      explines << "-		query.$().chain(this.effect);"
      explines << "-		return query.getStatement();"
      explines << "+		JsQuery queryx = new JsQuery(getComponent());"
      explines << "+		queryx.$().chain(this.effect);"
      explines << "+		return queryx.getStatement();"
      explines << " 	}"
      explines << " }"

      orig_dir = Dir.pwd
      
      Dir.chdir '/Programs/wiquery/trunk'

      args = %w{ }

      strio = StringIO.new
      $io = strio

      dc = Command.new args
      info "dc: #{dc}".yellow
      
      strio.close
      # puts strio.string

      $io = $stdout

      actlines = strio.string.split("\n")

      (0 ... [ explines.size, actlines.size ].max).each do |idx|
        assert_equal explines[idx], actlines[idx]
      end

      # output = dc.output
      # info "output: #{output}"
      
      Dir.chdir orig_dir
    end
  end
end
