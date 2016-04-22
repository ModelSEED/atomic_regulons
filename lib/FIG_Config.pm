package FIG_Config;

    ## WHEN YOU ADD ITEMS TO THIS FILE, BE SURE TO UPDATE kernel/scripts/Config.pl.
    ## All paths should be absolute, not relative.


    # root directory of the local web server
    our $web_dir = "";

    # TRUE for windows mode
    our $win_mode = 0;

    # source code project directory
    our $proj = "/kb/module/SEEDtk";

    # location of shared code
    our $cvsroot = "";

    # TRUE to switch to the data directory during setup
    our $data_switch = 0;

    # location of global file directory
    our $global = "/kb/module/SEEDtk/Data/Global";

    # default conserved domain search URL
    our $ConservedDomainSearchURL = "http://maple.mcs.anl.gov:5600";

    # Patric Data API URL
    our $p3_data_api_url = "";

    # code module base directory
    our $mod_base = '/kb/module/SEEDtk/modules';

    # list of script directories
    our @scripts = ('/kb/module/SEEDtk/modules/tbltools/scripts', '/kb/module/SEEDtk/modules/RASTtk/scripts', '/kb/module/SEEDtk/modules/kernel/scripts', '/kb/module/SEEDtk/modules/ERDB/scripts', '/kb/module/SEEDtk/modules/utils/scripts');

    # list of PERL libraries
    our @libs = ('/kb/module/SEEDtk/config', '/kb/module/SEEDtk/modules/tbltools/lib', '/kb/module/SEEDtk/modules/RASTtk/lib', '/kb/module/SEEDtk/modules/kernel/lib', '/kb/module/SEEDtk/modules/ERDB/lib', '/kb/module/SEEDtk/modules/utils/lib');

    # list of project modules
    our @modules = qw(tbltools RASTtk kernel ERDB utils);

    # list of shared modules
    our @shared = qw();

    # list of tool directories
    our @tools = ();


    # SHRUB CONFIGURATION


    # root directory for Shrub data files (should have
    # subdirectories "Inputs" (optional) and "LoadFiles"
    # (required))
    our $data = "/kb/module/SEEDtk/Data";

    # full name of the Shrub DBD XML file
    our $shrub_dbd = "/kb/module/SEEDtk/modules/ERDB/ShrubDBD.xml";

    # Shrub database signon info (name/password)
    our $userData = "seedtk/when26crazy";

    # name of the Shrub database (empty string to use the
    # default)
    our $shrubDB = "seedtk_shrub";

    # TRUE if we should create indexes before a table load
    # (generally TRUE for MySQL, FALSE for PostGres)
    our $preIndex = 1;

    # default DBMS (currently only "mysql" works for sure)
    our $dbms = "mysql";

    # database access port
    our $dbport = 3306;

    # TRUE if we are using an old version of MySQL (legacy
    # parameter; may go away)
    our $mysql_v3 = 0;

    # default MySQL storage engine
    our $default_mysql_engine = "InnoDB";

    # database host server (empty string to use the default)
    our $dbhost = "db3.chicago.kbase.us";
    #our $dbhost = "branch.mcs.anl.gov";

    # TRUE to turn off size estimates during table creation--
    # should be FALSE for MyISAM
    our $disable_dbkernel_size_estimates = 1;

    # mode for LOAD TABLE INFILE statements, empty string is OK
    # except in special cases (legacy parameter; may go away)
    our $load_mode = "";

    # location of the DNA repository
    our $shrub_dna = "";

    # Insure the PATH has our scripts in it.
    $_ = "/homes/janakae/KServices/atomic_regulons/SEEDtk/bin";
    if (! $ENV{PATH}) {
        $ENV{PATH} = $_;
    } elsif (substr($ENV{PATH}, 0, 51) ne $_) {
        $ENV{PATH} = "$_:$ENV{PATH}";
    }

    # Insure the PERL5LIB has our libraries in it.
    $_ = "/kb/module/SEEDtk/modules/tbltools/lib:/kb/module/SEEDtk/modules/RASTtk/lib:/kb/module/SEEDtk/modules/kernel/lib:/kb/module/SEEDtk/modules/ERDB/lib:/kb/module/SEEDtk/modules/utils/lib:/homes/janakae/KServices/atomic_regulons/SEEDtk/config";
    if (! $ENV{PERL5LIB}) {
        $ENV{PERL5LIB} = $_;
    } elsif (substr($ENV{PERL5LIB}, 0, 238) ne $_) {
        $ENV{PERL5LIB} = "$_:$ENV{PERL5LIB}";
    }

    # Add include paths.
    push @INC, '/kb/module/SEEDtk/modules/tbltools/lib', '/kb/module/SEEDtk/modules/RASTtk/lib', '/kb/module/SEEDtk/modules/kernel/lib', '/kb/module/SEEDtk/modules/ERDB/lib', '/kb/module/SEEDtk/modules/utils/lib';

1;
