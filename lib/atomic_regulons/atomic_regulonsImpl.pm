package atomic_regulons::atomic_regulonsImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

atomic_regulons

=head1 DESCRIPTION

A KBase module: atomic_regulons
This sample module contains one small method - filter_contigs.

=cut

#BEGIN_HEADER
#use lib "/.";
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use Config::IniFiles;
use atomic_regulons::GTO;
use atomic_regulons::ExpressionDir;
use Shrub;
use Shrub::Subsystems;
use Data::Dumper;

########

# perl for_ross.pl  GTO_SS Emat PC

use strict;
use File::Copy::Recursive;
use gjoseqlib;
use BasicLocation;
########

#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR

    my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
    my $cfg = Config::IniFiles->new(-file=>$config_file);
    my $wsInstance = $cfg->val('atomic_regulons','workspace-url');
    die "no workspace-url defined" unless $wsInstance;

    $self->{'workspace-url'} = $wsInstance;

    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 compute_atomic_regulons

  $return = $obj->compute_atomic_regulons($workspace, $expression_matrix_ref, $genome_ref, $expression_cutoff, $output_atomicRegulons)

=over 4

=item Parameter and return types

=begin html

<pre>
$workspace is an atomic_regulons.workspace
$expression_matrix_ref is an atomic_regulons.expression_matrix_ref
$genome_ref is an atomic_regulons.genome_ref
$expression_cutoff is an atomic_regulons.expression_cutoff
$output_atomicRegulons is an atomic_regulons.output_atomicRegulons
$return is an atomic_regulons.AtomicRegulonSet
workspace is a string
expression_matrix_ref is a string
genome_ref is a string
expression_cutoff is a string
output_atomicRegulons is a string
AtomicRegulonSet is a reference to a hash where the following keys are defined:
	expression_matrix_ref has a value which is a string
	genome_ref has a value which is a string
	expression_cutoff has a value which is a string

</pre>

=end html

=begin text

$workspace is an atomic_regulons.workspace
$expression_matrix_ref is an atomic_regulons.expression_matrix_ref
$genome_ref is an atomic_regulons.genome_ref
$expression_cutoff is an atomic_regulons.expression_cutoff
$output_atomicRegulons is an atomic_regulons.output_atomicRegulons
$return is an atomic_regulons.AtomicRegulonSet
workspace is a string
expression_matrix_ref is a string
genome_ref is a string
expression_cutoff is a string
output_atomicRegulons is a string
AtomicRegulonSet is a reference to a hash where the following keys are defined:
	expression_matrix_ref has a value which is a string
	genome_ref has a value which is a string
	expression_cutoff has a value which is a string


=end text



=item Description



=back

=cut

sub compute_atomic_regulons
{
    my $self = shift;
    my($workspace, $expression_matrix_ref, $genome_ref, $expression_cutoff, $output_atomicRegulons) = @_;

    my @_bad_arguments;
    (!ref($workspace)) or push(@_bad_arguments, "Invalid type for argument \"workspace\" (value was \"$workspace\")");
    (!ref($expression_matrix_ref)) or push(@_bad_arguments, "Invalid type for argument \"expression_matrix_ref\" (value was \"$expression_matrix_ref\")");
    (!ref($genome_ref)) or push(@_bad_arguments, "Invalid type for argument \"genome_ref\" (value was \"$genome_ref\")");
    (!ref($expression_cutoff)) or push(@_bad_arguments, "Invalid type for argument \"expression_cutoff\" (value was \"$expression_cutoff\")");
    (!ref($output_atomicRegulons)) or push(@_bad_arguments, "Invalid type for argument \"output_atomicRegulons\" (value was \"$output_atomicRegulons\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to compute_atomic_regulons:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compute_atomic_regulons');
    }

    my $ctx = $atomic_regulons::atomic_regulonsServer::CallContext;
    my($return);
    #BEGIN compute_atomic_regulons
    my $token=$ctx->token;
    my $wshandle=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);
    my $gto=$wshandle->get_objects([{workspace=>$workspace, name=>$genome_ref}]);
    my $em=$wshandle->get_objects([{workspace=>$workspace,name=>$expression_matrix_ref}]);
    my $expDir = "/kb/module/work/tmp/arwork";
    my $exRef = $em->[0]->{info}->[6]."/".$em->[0]->{info}->[0]."/".$em->[0]->{info}->[4];


    my $preData = {
        original_data => $exRef,
        feature_clusters => []
    };


    my $atomic_pegs = {

        msec => 0,
        meanco => 0,
        id_to_pos => {}
    };


     #$preData->{original_data} = "5711/2/1";




    my $emx = $em->[0]->{data}->{data};
    my $rows = $emx->{row_ids};
    my $cols = $emx->{col_ids};
    my $ex_vals = $emx->{values};

    #my $exp = "../data/rma_normalized1.tab";
    my $expex = "/kb/module/work/tmp/arwork";

    open(my $emt, ">$expex/$expression_matrix_ref") || die "Could not write subsystem bindings: $!";

    for (my $i =0; $i<@$cols; $i++){

        print $emt "$cols->[$i]\t";
    }
    print $emt "\n";

    for (my $i =0; $i< @$rows; $i++){

        print $emt "$rows->[$i]\t";
        my $val_set= $ex_vals->[$i];
        for (my $j=0; $j< @$val_set; $j++){

            print $emt "$val_set->[$j]\t";
        }
        print $emt "\n";

    }

    close $emt;


    my $genomeID = $gto->[0]->{data}->{source_id};
    print "$genomeID\n\n";
    File::Copy::Recursive::pathmk("$expDir/$genomeID");
    open(my $oh, ">$expDir/GENOME_ID") || die "Could not write genome ID: $!";
    print $oh $genomeID;
    close $oh;
    #File::Copy::Recursive::pathmk("$expDir/$genomeID");
    #print &Dumper ($expdata);

    #print &Dumper ($exp);
    #die;
    my $exp = "/kb/module/work/tmp/arwork/$expression_matrix_ref";
    File::Copy::Recursive::fcopy($exp, "$expDir/rma_normalized.tab") or die "copy failed $!";
    #GenomeTypeObject::write_seed_dir("$expDir/$genomeID");
    print "its here now\n";
    #added genomeID as an option
    atomic_regulons::GTO::write_seed_dir ($gto->[0],"$expDir/$genomeID");

    #atomic_regulons::GenomeTO::write_seed_dir();
    # Write the subsystems.
    #simplesr ();
    #seed_dir($gto->[0],$expDir);

    File::Copy::Recursive::pathmk("$expDir/$genomeID/Subsystems");
    open(my $bh, ">$expDir/$genomeID/Subsystems/bindings") || die "Could not write subsystem bindings: $!";
    open(my $sh, ">$expDir/$genomeID/Subsystems/subsystems") || die "Could not write subsystem listing: $!";
    my $shrub = Shrub->new();
    my $subH = Shrub::Subsystems::ProjectForGto ($shrub, $gto->[0]);

    #print &Dumper ($subH);

    for my $sub (keys %$subH) {
	   my $subRow = $subH->{$sub};
	   my ($variant, $cellsH) = @$subRow;
	   print $sh "$sub\t$variant\n";
	   for my $roleData ( @$cellsH) {
            my ($role,$fid) = @$roleData;
 			print $bh "$sub\t$role\t$fid\n";

	   }
    }

    close $bh;
    close $sh;
    my $e = ExpressionDir->new($expDir);

    $e->compute_atomic_regulons();


    my $reg_set;
    my $count =1;
    open INFILE, "$expDir/atomic.regulons" or die "Couldn't open atomic_regulons file : $!";
    while (my $input = <INFILE>){
        chomp $input;
        my @arr = split /\t/, $input;

        if ($arr[0] == $count){
            my $numReg = $arr[0]+0;
            $reg_set->{$arr[1]."_".$arr[2]} = $numReg;

        }
        else{
            $atomic_pegs->{id_to_pos} = $reg_set;
            push ($preData->{feature_clusters}, $atomic_pegs);
            $count++;
            $reg_set = {};
            $atomic_pegs = {

                msec => 0,
                meancor => 0,
                id_to_pos => {}
            };


        }
    }

    my $saveObjectParams;
    $saveObjectParams->{workspace}=$workspace;
    $saveObjectParams->{objects}->[0]->{type} = "KBaseFeatureValues.FeatureClusters";
    $saveObjectParams->{objects}->[0]->{data} = $preData;
    $saveObjectParams->{objects}->[0]->{name} = $output_atomicRegulons;
    my $meta = $wshandle->save_objects($saveObjectParams);
    $return = {'atomic_regulons' => $meta};

    #print &Dumper ($saveObjectParams);
    #die;

    #END compute_atomic_regulons
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to compute_atomic_regulons:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compute_atomic_regulons');
    }
    return($return);
}




=head2 version

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 workspace

=over 4



=item Description

A string representing the workspace name


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 expression_matrix_ref

=over 4



=item Description

String represent the Expression Matrix


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 genome_ref

=over 4



=item Description

A string for the genome


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 expression_cutoff

=over 4



=item Description

A string for the expression_cutoff


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 output_atomicRegulons

=over 4



=item Description

A string for the output regulon set


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 AtomicRegulonSet

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
expression_matrix_ref has a value which is a string
genome_ref has a value which is a string
expression_cutoff has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
expression_matrix_ref has a value which is a string
genome_ref has a value which is a string
expression_cutoff has a value which is a string


=end text

=back



=cut

1;
