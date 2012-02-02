require File.expand_path('../../spec_helper', __FILE__)

# MacRuby TODO: We need StringIO for one spec: Predefined global $_ is set to the last line read by e.g. StringIO#gets
# require 'stringio'

# The following tables are excerpted from Programming Ruby: The Pragmatic Programmer's Guide'
# Second Edition by Dave Thomas, Chad Fowler, and Andy Hunt, page 319-22.
#
# Entries marked [r/o] are read-only and an error will be raised of the program attempts to
# modify them. Entries marked [thread] are thread local.

=begin
Exception Information
---------------------------------------------------------------------------------------------------

$!               Exception       The exception object passed to raise. [thread]
$@               Array           The stack backtrace generated by the last exception. [thread]
=end

=begin
Pattern Matching Variables
---------------------------------------------------------------------------------------------------

These variables (except $=) are set to nil after an unsuccessful pattern match.

$&               String          The string matched (following a successful pattern match). This variable is
                                 local to the current scope. [r/o, thread]
$+               String          The contents of the highest-numbered group matched following a successful
                                 pattern match. Thus, in "cat" =~/(c|a)(t|z)/, $+ will be set to “t”. This
                                 variable is local to the current scope. [r/o, thread]
$`               String          The string preceding the match in a successful pattern match. This variable
                                 is local to the current scope. [r/o, thread]
$'               String          The string following the match in a successful pattern match. This variable
                                 is local to the current scope. [r/o, thread]
$=               Object          Deprecated.1.8 If set to any value apart from nil or false, all pattern matches
                                 will be case insensitive, string comparisons will ignore case, and string hash
                                 values will be case insensitive.
$1 to $9         String          The contents of successive groups matched in a successful pattern match. In
                                 "cat" =~/(c|a)(t|z)/, $1 will be set to “a” and $2 to “t”. This variable
                                 is local to the current scope. [r/o, thread]
$~               MatchData       An object that encapsulates the results of a successful pattern match. The
                                 variables $&, $`, $', and $1 to $9 are all derived from $~. Assigning to $~
                                 changes the values of these derived variables. This variable is local to the
                                 current scope. [thread]
=end


describe "Predefined global $~" do
  it "is set to contain the MatchData object of the last match if successful" do
    md = /foo/.match 'foo'
    $~.should be_kind_of(MatchData)
    $~.object_id.should == md.object_id

    /bar/ =~ 'bar'
    $~.should be_kind_of(MatchData)
    $~.object_id.should_not == md.object_id
  end

  it "is set to nil if the last match was unsuccessful" do
    /foo/ =~ 'foo'
    $~.nil?.should == false

    /foo/ =~ 'bar'
    $~.nil?.should == true
  end

  it "is set at the method-scoped level rather than block-scoped" do
    obj = Object.new
    def obj.foo; yield; end
    def obj.foo2(&proc); proc.call; end

    match = /foo/.match "foo"

    obj.foo { match = /bar/.match("bar") }

    $~.should == match

    eval 'match = /baz/.match("baz")'

    $~.should == match

    obj.foo2 { match = /qux/.match("qux") }

    $~.should == match
  end

  it "raises an error if assigned an object not nil or instanceof MatchData" do
    lambda { $~ = nil }.should_not raise_error
    lambda { $~ = /foo/.match("foo") }.should_not raise_error
    lambda { $~ = Object.new }.should raise_error(TypeError)
    lambda { $~ = 1 }.should raise_error(TypeError)
  end
end

describe "Predefined global $&" do
  it "is equivalent to MatchData#[0] on the last match $~" do
    /foo/ =~ 'barfoobaz'
    $&.should == $~[0]
    $&.should == 'foo'
  end
end

describe "Predefined global $`" do
  it "is equivalent to MatchData#pre_match on the last match $~" do
    /foo/ =~ 'barfoobaz'
    $`.should == $~.pre_match
    $`.should == 'bar'
  end
end

describe "Predefined global $'" do
  it "is equivalent to MatchData#post_match on the last match $~" do
    /foo/ =~ 'barfoobaz'
    $'.should == $~.post_match
    $'.should == 'baz'
  end
end

describe "Predefined global $+" do
  it "is equivalent to $~.captures.last" do
    /(f(o)o)/ =~ 'barfoobaz'
    $+.should == $~.captures.last
    $+.should == 'o'
  end
end

describe "Predefined globals $1..N" do
  it "are equivalent to $~[N]" do
    /(f)(o)(o)/ =~ 'foo'
    $1.should == $~[1]
    $2.should == $~[2]
    $3.should == $~[3]
    $4.should == $~[4]

    [$1, $2, $3, $4].should == ['f', 'o', 'o', nil]
  end

  it "are nil unless a match group occurs" do
    def test(arg)
      case arg
      when /-(.)?/
        $1
      end
    end
    test("-").should == nil
  end
end

describe "Predefined global $stdout" do
  before(:each) do
    @old_stdout = $stdout
  end

  after(:each) do
    $stdout = @old_stdout
  end

  ruby_version_is "" ... "1.9" do
    it "is the same as $defout" do
      $stdout.should == $defout

      $stdout = IOStub.new
      $stdout.should == $defout
    end
  end

  it "is the same as $DEFAULT_OUTPUT from 'English' library" do
    require 'English'
    $stdout.should == $DEFAULT_OUTPUT

    $stdout = IOStub.new
    $stdout.should == $DEFAULT_OUTPUT
  end

  it "raises TypeError error if assigned to nil" do
    lambda { $stdout = nil }.should raise_error(TypeError)
  end

  it "raises TypeError error if assigned to object that doesn't respond to #write" do
    obj = mock('object')
    lambda { $stdout = obj }.should raise_error(TypeError)

    obj.stub!(:write)
    lambda { $stdout = obj }.should_not raise_error()
  end
end

describe "Predefined global $!" do
  it "needs to be reviewed for spec completeness"

  ruby_version_is "1.9" do
    # See http://jira.codehaus.org/browse/JRUBY-5550
    it "remains nil after a failed core class \"checked\" coercion against a class that defines method_missing" do
      $!.should == nil

      obj = Class.new do
        def method_missing(*args)
          super
        end
      end.new

      [obj, 'foo'].join

      $!.should == nil
    end
  end
end

=begin
Input/Output Variables
---------------------------------------------------------------------------------------------------

$/               String          The input record separator (newline by default). This is the value that rou-
                                 tines such as Kernel#gets use to determine record boundaries. If set to
                                 nil, gets will read the entire file.
$-0              String          Synonym for $/.
$\               String          The string appended to the output of every call to methods such as
                                 Kernel#print and IO#write. The default value is nil.
$,               String          The separator string output between the parameters to methods such as
                                 Kernel#print and Array#join. Defaults to nil, which adds no text.
$.               Fixnum          The number of the last line read from the current input file.
$;               String          The default separator pattern used by String#split. May be set from the
                                 command line using the -F flag.
$<               Object          An object that provides access to the concatenation of the contents of all
                                 the files given as command-line arguments or $stdin (in the case where
                                 there are no arguments). $< supports methods similar to a File object:
                                 binmode, close, closed?, each, each_byte, each_line, eof, eof?,
                                 file, filename, fileno, getc, gets, lineno, lineno=, path, pos, pos=,
                                 read, readchar, readline, readlines, rewind, seek, skip, tell, to_a,
                                 to_i, to_io, to_s, along with the methods in Enumerable. The method
                                 file returns a File object for the file currently being read. This may change
                                 as $< reads through the files on the command line. [r/o]
$>               IO              The destination of output for Kernel#print and Kernel#printf. The
                                 default value is $stdout.
$_               String          The last line read by Kernel#gets or Kernel#readline. Many string-
                                 related functions in the Kernel module operate on $_ by default. The vari-
                                 able is local to the current scope. [thread]
$-F              String          Synonym for $;.
$stderr          IO              The current standard error output.
$stdin           IO              The current standard input.
$stdout          IO              The current standard output. Assignment to $stdout is deprecated: use
                                 $stdout.reopen instead.
=end

describe "Predefined global $," do
  it "defaults to nil" do
    $,.should be_nil
  end

  it "raises TypeError if assigned a non-String" do
    lambda { $, = Object.new }.should raise_error(TypeError)
  end
end

describe "Predefined global $_" do
  it "is set to the last line read by e.g. StringIO#gets" do
    stdin = StringIO.new("foo\nbar\n", "r")

    read = stdin.gets
    read.should == "foo\n"
    $_.should == read

    read = stdin.gets
    read.should == "bar\n"
    $_.should == read

    read = stdin.gets
    read.should == nil
    $_.should == read
  end

  it "is set at the method-scoped level rather than block-scoped" do
    obj = Object.new
    def obj.foo; yield; end
    def obj.foo2; yield; end

    stdin = StringIO.new("foo\nbar\nbaz\nqux\n", "r")
    match = stdin.gets

    obj.foo { match = stdin.gets }

    match.should == "bar\n"
    $_.should == match

    eval 'match = stdin.gets'

    match.should == "baz\n"
    $_.should == match

    obj.foo2 { match = stdin.gets }

    match.should == "qux\n"
    $_.should == match
  end

  it "can be assigned any value" do
    lambda { $_ = nil }.should_not raise_error
    lambda { $_ = "foo" }.should_not raise_error
    lambda { $_ = Object.new }.should_not raise_error
    lambda { $_ = 1 }.should_not raise_error
  end
end

=begin
Execution Environment Variables
---------------------------------------------------------------------------------------------------

$0               String          The name of the top-level Ruby program being executed. Typically this will
                                 be the program’s filename. On some operating systems, assigning to this
                                 variable will change the name of the process reported (for example) by the
                                 ps(1) command.
$*               Array           An array of strings containing the command-line options from the invoca-
                                 tion of the program. Options used by the Ruby interpreter will have been
                                 removed. [r/o]
$"               Array           An array containing the filenames of modules loaded by require. [r/o]
$$               Fixnum          The process number of the program being executed. [r/o]
$?               Process::Status The exit status of the last child process to terminate. [r/o, thread]
$:               Array           An array of strings, where each string specifies a directory to be searched for
                                 Ruby scripts and binary extensions used by the load and require methods.
                                 The initial value is the value of the arguments passed via the -I command-
                                 line option, followed by an installation-defined standard library location, fol-
                                 lowed by the current directory (“.”). This variable may be set from within a
                                 program to alter the default search path; typically, programs use $: << dir
                                 to append dir to the path. [r/o]
$-a              Object          True if the -a option is specified on the command line. [r/o]
$-d              Object          Synonym for $DEBUG.
$DEBUG           Object          Set to true if the -d command-line option is specified.
__FILE__         String          The name of the current source file. [r/o]
$F               Array           The array that receives the split input line if the -a command-line option is
                                 used.
$FILENAME        String          The name of the current input file. Equivalent to $<.filename. [r/o]
$-i              String          If in-place edit mode is enabled (perhaps using the -i command-line
                                 option), $-i holds the extension used when creating the backup file. If you
                                 set a value into $-i, enables in-place edit mode.
$-I              Array           Synonym for $:. [r/o]
$-K              String          Sets the multibyte coding system for strings and regular expressions. Equiv-
                                 alent to the -K command-line option.
$-l              Object          Set to true if the -l option (which enables line-end processing) is present
                                 on the command line. [r/o]
__LINE__         String          The current line number in the source file. [r/o]
$LOAD_PATH       Array           A synonym for $:. [r/o]
$-p              Object          Set to true if the -p option (which puts an implicit while gets . . . end
                                 loop around your program) is present on the command line. [r/o]
$SAFE            Fixnum          The current safe level. This variable’s value may never be
                                 reduced by assignment. [thread]
$VERBOSE         Object          Set to true if the -v, --version, -W, or -w option is specified on the com-
                                 mand line. Set to false if no option, or -W1 is given. Set to nil if -W0
                                 was specified. Setting this option to true causes the interpreter and some
                                 library routines to report additional information. Setting to nil suppresses
                                 all warnings (including the output of Kernel.warn).
$-v              Object          Synonym for $VERBOSE.
$-w              Object          Synonym for $VERBOSE.
=end
describe "Execution variable $:" do
  it "is initialized to an array of strings" do
    $:.is_a?(Array).should == true
    ($:.length > 0).should == true
  end

  ruby_version_is ""..."1.9" do
    it "includes the current directory" do
      $:.should include(".")
    end
  end

  ruby_version_is "1.9" do
    it "does not include the current directory" do
      $:.should_not include(".")
    end
  end

  it "does not include '.' when the taint check level > 1" do
    begin
      orig_opts, ENV['RUBYOPT'] = ENV['RUBYOPT'], '-T'
      `#{RUBY_EXE} -e 'p $:.include?(".")'`.should == "false\n"
    ensure
      ENV['RUBYOPT'] = orig_opts
    end
  end

  it "is the same object as $LOAD_PATH and $-I" do
    $:.__id__.should == $LOAD_PATH.__id__
    $:.__id__.should == $-I.__id__
  end

  it "can be changed via <<" do
    $: << "foo"
    $:.should include("foo")
  end

  it "is read-only" do
    lambda {
      $: = []
    }.should raise_error(NameError)

    lambda {
      $LOAD_PATH = []
    }.should raise_error(NameError)

    lambda {
      $-I = []
    }.should raise_error(NameError)
  end
end

describe "Global variable $\"" do
  it "is an alias for $LOADED_FEATURES" do
    $".object_id.should == $LOADED_FEATURES.object_id
  end

  it "is read-only" do
    lambda {
      $" = []
    }.should raise_error(NameError)

    lambda {
      $LOADED_FEATURES = []
    }.should raise_error(NameError)
  end
end

describe "Global variable $<" do
  it "is read-only" do
    lambda {
      $< = nil
    }.should raise_error(NameError)
  end
end

describe "Global variable $FILENAME" do
  it "is read-only" do
    lambda {
      $FILENAME = "-"
    }.should raise_error(NameError)
  end
end

describe "Global variable $?" do
  it "is read-only" do
    lambda {
      $? = nil
    }.should raise_error(NameError)
  end
end

describe "Global variable $-a" do
  it "is read-only" do
    lambda { $-a = true }.should raise_error(NameError)
  end
end

describe "Global variable $-l" do
  it "is read-only" do
    lambda { $-l = true }.should raise_error(NameError)
  end
end

describe "Global variable $-p" do
  it "is read-only" do
    lambda { $-p = true }.should raise_error(NameError)
  end
end

describe "Global variable $-d" do
  before :each do
    @debug = $DEBUG
  end

  after :each do
    $DEBUG = @debug
  end

  it "is an alias of $DEBUG" do
    $DEBUG = true
    $-d.should be_true
    $-d = false
    $DEBUG.should be_false
  end
end

describe :verbose_global_alias, :shared => true do
  before :each do
    @verbose = $VERBOSE
  end

  after :each do
    $VERBOSE = @verbose
  end

  it "is an alias of $VERBOSE" do
    $VERBOSE = true
    eval(@method).should be_true
    eval("#{@method} = false")
    $VERBOSE.should be_false
  end
end

describe "Global variable $-v" do
  it_behaves_like :verbose_global_alias, '$-v'
end

describe "Global variable $-w" do
  it_behaves_like :verbose_global_alias, '$-w'
end

=begin
Standard Objects
---------------------------------------------------------------------------------------------------

ARGF             Object          A synonym for $<.
ARGV             Array           A synonym for $*.
ENV              Object          A hash-like object containing the program’s environment variables. An
                                 instance of class Object, ENV implements the full set of Hash methods. Used
                                 to query and set the value of an environment variable, as in ENV["PATH"]
                                 and ENV["term"]="ansi".
false            FalseClass      Singleton instance of class FalseClass. [r/o]
nil              NilClass        The singleton instance of class NilClass. The value of uninitialized
                                 instance and global variables. [r/o]
self             Object          The receiver (object) of the current method. [r/o]
true             TrueClass       Singleton instance of class TrueClass. [r/o]
=end

describe "The predefined standard objects" do
  it "includes ARGF" do
    Object.const_defined?(:ARGF).should == true
  end

  it "includes ARGV" do
    Object.const_defined?(:ARGV).should == true
  end

  it "includes a hash-like object ENV" do
    Object.const_defined?(:ENV).should == true
    ENV.respond_to?(:[]).should == true
  end
end

describe "The predefined standard object nil" do
  it "is an instance of NilClass" do
    nil.should be_kind_of(NilClass)
  end

  it "raises a SyntaxError if assigned to" do
    lambda { eval("nil = true") }.should raise_error(SyntaxError)
  end
end

describe "The predefined standard object true" do
  it "is an instance of TrueClass" do
    true.should be_kind_of(TrueClass)
  end

  it "raises a SyntaxError if assigned to" do
    lambda { eval("true = false") }.should raise_error(SyntaxError)
  end
end

describe "The predefined standard object false" do
  it "is an instance of FalseClass" do
    false.should be_kind_of(FalseClass)
  end

  it "raises a SyntaxError if assigned to" do
    lambda { eval("false = nil") }.should raise_error(SyntaxError)
  end
end

describe "The self pseudo-variable" do
  it "raises a SyntaxError if assigned to" do
    lambda { eval("self = 1") }.should raise_error(SyntaxError)
  end
end

=begin
Global Constants
---------------------------------------------------------------------------------------------------

The following constants are defined by the Ruby interpreter.

DATA                 IO          If the main program file contains the directive __END__, then
                                 the constant DATA will be initialized so that reading from it will
                                 return lines following __END__ from the source file.
FALSE                FalseClass  Synonym for false.
NIL                  NilClass    Synonym for nil.
RUBY_PLATFORM        String      The identifier of the platform running this program. This string
                                 is in the same form as the platform identifier used by the GNU
                                 configure utility (which is not a coincidence).
PLATFORM             String      Same as RUBY_PLATFORM (only in 1.8).
RUBY_RELEASE_DATE    String      The date of this release.
RUBY_VERSION         String      The version number of the interpreter.
STDERR               IO          The actual standard error stream for the program. The initial
                                 value of $stderr.
STDIN                IO          The actual standard input stream for the program. The initial
                                 value of $stdin.
STDOUT               IO          The actual standard output stream for the program. The initial
                                 value of $stdout.
SCRIPT_LINES__       Hash        If a constant SCRIPT_LINES__ is defined and references a Hash,
                                 Ruby will store an entry containing the contents of each file it
                                 parses, with the file’s name as the key and an array of strings as
                                 the value.
TOPLEVEL_BINDING     Binding     A Binding object representing the binding at Ruby’s top level—
                                 the level where programs are initially executed.
TRUE                 TrueClass   Synonym for true.
=end

describe "The predefined global constants" do
  it "includes TRUE" do
    Object.const_defined?(:TRUE).should == true
    TRUE.should equal(true)
  end

  it "includes FALSE" do
    Object.const_defined?(:FALSE).should == true
    FALSE.should equal(false)
  end

  it "includes NIL" do
    Object.const_defined?(:NIL).should == true
    NIL.should equal(nil)
  end

  it "includes STDIN" do
    Object.const_defined?(:STDIN).should == true
  end

  it "includes STDOUT" do
    Object.const_defined?(:STDOUT).should == true
  end

  it "includes STDERR" do
    Object.const_defined?(:STDERR).should == true
  end

  it "includes RUBY_VERSION" do
    Object.const_defined?(:RUBY_VERSION).should == true
  end

  it "includes RUBY_RELEASE_DATE" do
    Object.const_defined?(:RUBY_RELEASE_DATE).should == true
  end

  it "includes RUBY_PLATFORM" do
    Object.const_defined?(:RUBY_PLATFORM).should == true
  end

  ruby_version_is "" ... "1.9" do
    it "includes PLATFORM" do
      Object.const_defined?(:PLATFORM).should == true
      RUBY_PLATFORM == PLATFORM
    end
  end

  it "includes TOPLEVEL_BINDING" do
    Object.const_defined?(:TOPLEVEL_BINDING).should == true
  end

end

describe "Processing RUBYOPT" do
  before (:each) do
    @rubyopt, ENV["RUBYOPT"] = ENV["RUBYOPT"], nil
    @ruby_flags, ENV["RUBY_FLAGS"] = ENV["RUBY_FLAGS"], nil
  end

  after (:each) do
    ENV["RUBYOPT"] = @rubyopt
    ENV["RUBY_FLAGS"] = @ruby_flags
  end

  it "adds the -I path to $LOAD_PATH" do
    ENV["RUBYOPT"] = "-Ioptrubyspecincl"
    result = ruby_exe("puts $LOAD_PATH.grep(/byspecin/)", :escape => true)
    result.chomp[-15..-1].should == "optrubyspecincl"
  end

  it "sets $DEBUG to true for '-d'" do
    ENV["RUBYOPT"] = '-d'
    command = %[puts "value of $DEBUG is \#{$DEBUG}"]
    result = ruby_exe(command, :escape => true, :args => "2>&1")
    result.should =~ /value of \$DEBUG is true/
  end

  ruby_version_is "1.9" do
    it "prints the version number for '-v'" do
      ENV["RBXOPT"] = '-X19'
      ENV["RUBYOPT"] = '-v'
      ruby_exe("").chomp.should == RUBY_DESCRIPTION
    end
  end

  it "sets $VERBOSE to true for '-w'" do
    ENV["RUBYOPT"] = '-w'
    ruby_exe("p $VERBOSE", :escape => true).chomp.should == "true"
  end

  it "sets $VERBOSE to true for '-W'" do
    ENV["RUBYOPT"] = '-W'
    ruby_exe("p $VERBOSE", :escape => true).chomp.should == "true"
  end

  it "sets $VERBOSE to nil for '-W0'" do
    ENV["RUBYOPT"] = '-W0'
    ruby_exe("p $VERBOSE", :escape => true).chomp.should == "nil"
  end

  it "sets $VERBOSE to false for '-W1'" do
    ENV["RUBYOPT"] = '-W1'
    ruby_exe("p $VERBOSE", :escape => true).chomp.should == "false"
  end

  it "sets $VERBOSE to true for '-W2'" do
    ENV["RUBYOPT"] = '-W2'
    ruby_exe("p $VERBOSE", :escape => true).chomp.should == "true"
  end

  it "requires the file for '-r'" do
    f = fixture __FILE__, "rubyopt"
    ENV["RUBYOPT"] = "-r#{f}"
    ruby_exe("").should =~ /^rubyopt.rb required/
  end

  ruby_version_is ""..."1.9" do
    it "sets $KCODE to 'NONE' with '-K'" do
      ENV["RUBYOPT"] = '-K'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "NONE"
    end

    it "sets $KCODE to 'NONE' with '-Ka'" do
      ENV["RUBYOPT"] = '-Ka'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "NONE"
    end

    it "sets $KCODE to 'NONE' with '-KA'" do
      ENV["RUBYOPT"] = '-KA'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "NONE"
    end

    it "sets $KCODE to 'NONE' with '-Kn'" do
      ENV["RUBYOPT"] = '-Kn'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "NONE"
    end

    it "sets $KCODE to 'NONE' with '-KN'" do
      ENV["RUBYOPT"] = '-KN'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "NONE"
    end

    it "sets $KCODE to 'EUC' with '-Ke'" do
      ENV["RUBYOPT"] = '-Ke'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "EUC"
    end

    it "sets $KCODE to 'EUC' with '-KE'" do
      ENV["RUBYOPT"] = '-KE'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "EUC"
    end

    it "sets $KCODE to 'UTF8' with '-Ku'" do
      ENV["RUBYOPT"] = '-Ku'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "UTF8"
    end

    it "sets $KCODE to 'UTF8' with '-KU'" do
      ENV["RUBYOPT"] = '-KU'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "UTF8"
    end

    it "sets $KCODE to 'SJIS' with '-Ks'" do
      ENV["RUBYOPT"] = '-Ks'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "SJIS"
    end

    it "sets $KCODE to 'SJIS' with '-KS'" do
      ENV["RUBYOPT"] = '-KS'
      ruby_exe("puts $KCODE", :escape => true).chomp.should == "SJIS"
    end
  end

  it "raises a RuntimeError for '-a'" do
    ENV["RUBYOPT"] = '-a'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-p'" do
    ENV["RUBYOPT"] = '-p'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-n'" do
    ENV["RUBYOPT"] = '-n'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-y'" do
    ENV["RUBYOPT"] = '-y'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-c'" do
    ENV["RUBYOPT"] = '-c'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-s'" do
    ENV["RUBYOPT"] = '-s'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-h'" do
    ENV["RUBYOPT"] = '-h'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '--help'" do
    ENV["RUBYOPT"] = '--help'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-l'" do
    ENV["RUBYOPT"] = '-l'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-S'" do
    ENV["RUBYOPT"] = '-S irb'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-e'" do
    ENV["RUBYOPT"] = '-e0'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-i'" do
    ENV["RUBYOPT"] = '-i.bak'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-x'" do
    ENV["RUBYOPT"] = '-x'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-C'" do
    ENV["RUBYOPT"] = '-C'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-X'" do
    ENV["RUBYOPT"] = '-X.'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-F'" do
    ENV["RUBYOPT"] = '-F'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '-0'" do
    ENV["RUBYOPT"] = '-0'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '--copyright'" do
    ENV["RUBYOPT"] = '--copyright'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '--version'" do
    ENV["RUBYOPT"] = '--version'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end

  it "raises a RuntimeError for '--yydebug'" do
    ENV["RUBYOPT"] = '--yydebug'
    ruby_exe("", :args => '2>&1').should =~ /RuntimeError/
  end
end
