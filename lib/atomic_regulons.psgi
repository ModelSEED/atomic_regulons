use atomic_regulons::atomic_regulonsImpl;

use atomic_regulons::atomic_regulonsServer;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = atomic_regulons::atomic_regulonsImpl->new;
    push(@dispatch, 'atomic_regulons' => $obj);
}


my $server = atomic_regulons::atomic_regulonsServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
