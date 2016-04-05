package atomic_regulons::GTO;


use gjoseqlib;
use BasicLocation;
use Data::Dumper;
use strict;
use warnings;
use fr0g;

sub write_seed_dir
{
    print "after the func\n";
    my($self, $dir, $options) = @_;

    open(my $ctg_fh, ">", "$dir/contigs") or die "Cannot create $dir/contigs: $!";
=head
    for my $contig (@{$self->{contigs}})
    {
        write_fasta($ctg_fh, [$contig->{id}, undef, $contig->{dna}]);
    }
    close($ctg_fh);
=cut
    #
    # Some individual file metadata.
    #
    my $write_md = sub { my($name, $value) = @_;
                         my $fh;
                         open($fh, ">", "$dir/$name") or die "Cannot open $dir/$name: $!";
                         print $fh "$value\n";
                         close($fh);
                    };



    $write_md->("GENETIC_CODE", $self->{data}->{genetic_code};)
    $write_md->("GENOME", $self->{data}->{scientific_name});
    $write_md->("TAXONOMY", $self->{taxonomy}) if $self->{taxonomy};

    my $features = $self->{features};  #$self->{data}->{features};
    my %types = map { $_->{type} => 1 } @$features;

    my %typemap;
    if ($options->{map_CDS_to_peg})
    {
        delete $types{CDS};
        $types{peg} = 1;
    }
    my @types = keys %types;
    $typemap{$_} = $_ foreach @types;
    $typemap{CDS} = 'peg' if $options->{map_CDS_to_peg};
    ## print Dumper(\@types, \%typemap);

    #
    # closest.genomes file.
    #
=head
    my $close = $self->{close_genomes};
    if (ref($close) && @$close)
    {
        open(my $close_fh, ">", "$dir/closest.genomes") or die "cannot open $dir/closest.genomes: $!";
        for my $c (@$close)
        {
            print $close_fh join("\t", $c->{genome_id}, $c->{closeness_measure}, $c->{genome_name}), "\n";
        }
        close($close_fh);
    }
=cut
    my $fn_file = $options->{assigned_functions_file};
    $fn_file = "assigned_functions" if !$fn_file;

    open(my $func_fh, ">", "$dir/$fn_file") or die "Cannot create $dir/fn_file: $!";
    open(my $anno_fh, ">", "$dir/annotations") or die "Cannot create $dir/annotations: $!";

    mkdir("$dir/Features");

    my(%tbl_fh, %fasta_fh);

    for my $type (@types)
    {
        my $tdir = "$dir/Features/$type";
        -d $tdir or mkdir($tdir) or die "Cannot mkdir $tdir: $!";

        my $fh;
        open($fh, ">", "$tdir/tbl") or die "Cannot create $dir/tbl:$ !";
        $tbl_fh{$type} = $fh;

        my $fafh;
        open($fafh, ">", "$tdir/fasta") or die "Cannot create $dir/fasta:$ !";
        $fasta_fh{$type} = $fafh;
    }

    #     "location" : [
    #        [
    #           "kb|g.140.c.0",
    #           "631472",
    #           "+",
    #           3216
    #        ]
    #     ],

        for my $feature (@$features){     #for (my $i=0; $i< @$features; $i++){

        my $fid = $feature->{id};
        my $type = $feature->{type};
        my @aliases;

        if ($options->{correct_fig_id} && $fid =~ /^\d+\.\d+\.$type/)
        {
            $fid = "fig|$fid";
        }
        if ($type eq 'CDS' && $options->{map_CDS_to_peg})
        {
            $type = 'peg';
            $fid =~ s/\.CDS\./.peg./;
        }
        my $function = $feature->{function} || "hypothetical protein";
        print $func_fh "$fid\t$function\n";

        my $loc = $feature->{location};

        my @bloc;
        for my $loc_part (@$loc)
        {
            my($ctg, $start, $strand, $len) = @$loc_part;
            my $bl = BasicLocation->new($ctg, $start, $strand, $len);
            push(@bloc, $bl);
        }
        my $sloc = join(",", map { $_->SeedString() } @bloc);

        print { $tbl_fh{$type} } join("\t", $fid, $sloc, @aliases), "\n";

        if ($feature->{protein_translation})
        {
            write_fasta($fasta_fh{$type}, [$fid, undef, $feature->{protein_translation}]);
        }
        else
        {
            write_fasta($fasta_fh{$type}, [$fid, undef, $self->get_feature_dna($feature->{id})]);
        }

        # typedef tuple<string comment, string annotator, int annotation_time, analysis_event_id> annotation;
=head
        for my $anno (@{$feature->{annotations}})
        {
            my($txt, $annotator, $time, $event_id) = @$anno;
            print $anno_fh join("\n", $fid, $time, defined($annotator) ? $annotator : "", $txt);
            print $anno_fh "\n" if substr($txt, -1) ne "\n";
            print $anno_fh "//\n";
        }
=cut
    }

    for my $type (@types)
    {
        $fasta_fh{$type}->close();
        $tbl_fh{$type}->close();
    }
    close($anno_fh);
    close($func_fh);
}
1;