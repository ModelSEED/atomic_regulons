package ExpressionDir;

use FileHandle;
use gjoseqlib;
use Data::Dumper;
use strict;
use SeedAware;
use File::Copy;
use File::Temp 'tempfile';
use File::Spec::Functions;
use Carp;
use Fcntl ':seek';
use GenomeTypeObject;

sub genome_dir {
	my ($self, $parm) = @_;
	if (defined $parm) {
		$self->{genome_dir} = $parm;
	}
	my $retVal = $self->{genome_dir};
	return $retVal;
}

sub expr_dir {
	my ($self, $parm) = @_;
	if (defined $parm) {
		$self->{expr_dir} = $parm;
	}
	my $retVal = $self->{expr_dir};
	return $retVal;
}

sub genome_id {
	my ($self, $parm) = @_;
	if (defined $parm) {
		$self->{genome_id} = $parm;
	}
	my $retVal = $self->{genome_id};
	return $retVal;
}


=head3 new

    my $edir = ExpressionDir->new($expr_dir);

Create a new ExpressionDir object from an existing expression dir.


=cut

sub new
{
    my($class, $expr_dir) = @_;

    my $gfile = catfile($expr_dir, "GENOME_ID");
    open(GF, "<", $gfile) or die "Cannot open $expr_dir/GENOME_ID: $!";
    my $genome_id = <GF>;
    chomp $genome_id;
    close(GF);

    my $self = {
	genome_dir => catfile($expr_dir, $genome_id),
	genome_id => $genome_id,
	expr_dir => $expr_dir,
    };
    return bless $self, $class;
}

#
# Our "native" format, used for passing through pre-parsed data.
#
sub parse_probe_format_native
{
    my($self, $in_file, $out_file) = @_;

    my($fh);

    open($fh, "<", $in_file) or confess "Cannot open $in_file for reading: $!";
    my $l = <$fh>;
    chomp $l;
    $l =~ s/\r//;

    if ($l !~ /^\d+_\d+\t[ACGT]+$/)
    {
	close($fh);
	return undef;
    }
    seek($fh, 0, SEEK_SET);

    my $out;
    open($out, ">", $out_file) or confess "Cannot open $out for writing: $!";

    while (<$fh>)
    {
	if ($_ =~ /^\d+_\d+\t[ACGT]+$/)
	{
	    print $out $_;
	}
	else
	{
	    confess "Bad input at line $. of $in_file";
	}
    }
    close($out);
    close($fh);
    return 1;
}

sub make_missing_probes
{
    my($self, $probe_table, $probes, $output) = @_;
    open(MATCH,"<", $probe_table) or die "Cannot open $probe_table: $!";
    open(PROBES,"<", $probes) or die "Cannot open $probes: $!";
    open(OUTPUT, ">", $output) or die "Cannot open $output: $!";
    my %locations;
    while(<MATCH>)
    {
	chomp;
	my($peg,$loc)=split "\t";
	$locations{$loc} = $peg;
    }

    while(<PROBES>)
    {
	chomp;
	my($loc,$seq) = split "\t";
	print OUTPUT $loc, "\n" if ! exists $locations{$loc};
    }
    close(MATCH);
    close(PROBES);
    close(OUTPUT);
}

#
# we don't copy the experiment files in here because
# they may be very large. This may change.
#
# We do copy the cdf.
#

sub compute_atomic_regulons
{
    print "I am here ExpressionDir\n";


    my($self, $pearson_cutoff) = @_;

    $pearson_cutoff ||= 0.7;

    my $coreg_clusters = catfile($self->expr_dir, "coregulated.clusters");
    my $coreg_subsys = catfile($self->expr_dir, "coregulated.subsys");
    my $merged_clusters = catfile($self->expr_dir, "merged.clusters");
    my $probes_always_on = catfile($self->expr_dir, "probes.always.on");
    my $pegs_always_on = catfile($self->expr_dir, "pegs.always.on");


    $self->run(["./call_coregulated_clusters_on_chromosome", $self->expr_dir],
	   { stdout => $coreg_clusters });

    my $genome_ss_dir = $self->genome_dir . "/Subsystems";
    $self->run(["./make_coreg_conjectures_based_on_subsys",
		$self->expr_dir,
		(-d $genome_ss_dir ? $genome_ss_dir : ()),
		],
	   { stdout => $coreg_subsys });

    $self->run(["./filter_and_merge_gene_sets", $self->expr_dir, $coreg_clusters, $coreg_subsys],
	   { stdout => $merged_clusters });
    $self->run(["./get_ON_probes", $self->expr_dir, $probes_always_on, $pegs_always_on]);

    if (-s $pegs_always_on == 0)
    {
	confess "No always-on pegs were found";
    }

    $self->run(["./Pipeline", $pegs_always_on, $merged_clusters, $self->expr_dir],
	   { stdout => catfile($self->expr_dir, "comments.by.Pipeline.R") });

    $self->run(["./SplitGeneSets", $merged_clusters, $pearson_cutoff, $self->expr_dir],
	   { stdout => catfile($self->expr_dir, "split.clusters") });

    $self->run(["./compute_atomic_regulons_for_dir", $self->expr_dir]);
}

sub run
{
    my($self, $cmd, $redirect) = @_;

    print &Dumper ($redirect);

    print "Run @$cmd\n";
    my $rc = system_with_redirect($cmd, $redirect);
    if ($rc != 0)
    {
	confess "Command failed: @$cmd\n";
    }
}


sub all_features
{
    my($self, $type) = @_;

    my @ftypes;
    my $fdir = catfile($self->genome_dir, "Features");
    if (defined($type))
    {
	@ftypes = ($type);
    }
    else
    {
	opendir(D, $fdir);
	@ftypes = grep { -f catfile($fdir, $_) && /^\./ } readdir(D);
	closedir(D);
    }
    my @out;
    for my $ftype (@ftypes)
    {
	if (open(TBL, "<", catfile($fdir, $ftype, "tbl")))
	{
	    push(@out, map { /^(\S+)/; $1 } <TBL>);
	    close(TBL);
	}
    }
    return @out;
}

sub fid_locations
{
    my($self, $fids) = @_;

    my %fids;
    $fids{$_}++ for @$fids;

    my $genome_id = $self->genome_id;

    my $fdir = catfile($self->genome_dir, "Features");
    opendir(D, $fdir);
    my @ftypes = grep { -d catfile($fdir, $_) && ! /^\./ } readdir(D);
    closedir(D);
    my $out = {};
    for my $ftype (@ftypes)
    {
	if (open(TBL, "<", catfile($fdir, $ftype, "tbl")))
	{
	    while (<TBL>)
	    {
		my($id, $locs) = /^(\S+)\t(\S+)/;

		if ($fids{$id})
		{
		    $out->{$id} = "$genome_id:" . SeedUtils::boundary_loc($locs);
		}
	    }
	    close(TBL);
	}
    }
    return $out;
}

sub ids_in_subsystems
{
    my($self) = @_;

    my $dir = $self->genome_dir;
    my $fh;
    if (!open($fh, "<", "$dir/Subsystems/bindings"))
    {
	warn "No bindings file, falling back to old method\n";
	return $self->ids_in_subsystems_old();
    }

    my $res;
    while (<$fh>)
    {
	chomp;
	my($ss, $role, $fid) = split(/\t/);
	$ss =~ s/\s+/_/g;
	push(@{$res->{$ss}->{$role}}, $fid);
    }
    close($fh);
    return $res;
}

sub ids_to_subsystems
{
    my($self, $ids) = @_;

    my $dir = $self->genome_dir;
    my $fh;
    if (!open($fh, "<", "$dir/Subsystems/bindings"))
    {
	warn "No bindings file, falling back to old method\n";
	return $self->ids_to_subsystems_old($ids);
    }

    my %ids;
    $ids{$_} = 1 for @$ids;

    my $res = {};
    while (<$fh>)
    {
	chomp;
	my($ss, $role, $fid) = split(/\t/);
	if ($ids{$fid})
	{
	    push(@{$res->{$fid}}, $ss);
	}
    }
    close(SS);

    return $res;
}


sub ids_to_functions
{
    my($self, $ids) = @_;
    open(AF, "<", catfile($self->genome_dir, "assigned_functions"));
    my %ids;
    $ids{$_} = 1 for @$ids;
    my $res = {};

    while (<AF>)
    {
	chomp;
	my($id, $fn) = split(/\t/);
	$res->{$id} = $fn if $ids{$id};
    }
    close(AF);
    return $res;
}

sub best_pearson_corr {
    my($self,$pegs1,$cutoff) = @_;

    my @pegs2 = $self->all_features('peg');
    my $handle = $self->get_pc_hash_strip($pegs1,\@pegs2);

    my %ok;
    my $i;
    for ($i=0; ($i < @$pegs1); $i++)
    {
	foreach my $peg2 ( @pegs2 )
	{
	    my $pc = &pearson_corr($handle,$pegs1->[$i],$peg2);
	    if (abs($pc >= $cutoff))
	    {
		$ok{$pegs1->[$i]} -> {$peg2} = $pc;
	    }
	}
    }
    return \%ok;
}

sub pearson_corr {
    my($hash,$peg1,$peg2) = @_;
    my $v = $hash->{$peg1}->{$peg2};
    return defined($v) ? sprintf("%0.3f",$v) : " ";
}

sub get_pc_hash_strip {
    my($self,$pegs1,$pegs2) = @_;
    my $corrH = $self->get_corr;
    my $hash  = &compute_pc_strip($pegs1,$pegs2,$corrH);
    return $hash;
}

sub get_corr {
    my($self) = @_;

    my $dir           = $self->expr_dir;
    my $rawF          = "$dir/rma_normalized.tab";
    my %gene_to_values;
    open(RAW,"<$rawF") || die "could not open $rawF";
    while (<RAW>)
    {
	chomp;
	my ($gene_id, @gxp_values) = split("\t");
	$gene_to_values{$gene_id} = \@gxp_values;
    }
    close(RAW);
    return \%gene_to_values;
}

sub compute_pc_strip {
    my ($pegs1,$pegs2, $gxp_hash) = @_;
    my %values = ();

    for (my $i = 0; $i < @$pegs1; $i++)
    {
	my $stat = Statistics::Descriptive::Full->new();
	$stat->add_data(@{$gxp_hash->{$pegs1->[$i]}});

	foreach my $peg2 (@$pegs2)
	{
	    if ($pegs1->[$i] ne $peg2)
	    {
		my ($q, $m, $r, $err) = $stat->least_squares_fit(@{$gxp_hash->{$peg2}});
		$values{$pegs1->[$i]}->{$peg2} = $r;
	    }
	}
    }

    return \%values;
}


1;

