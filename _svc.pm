package _svc;
use Mojo::Base -strict;
use _init;

sub version {
    my ($cb) = @_;
    my $port = (split /:/ms, $::c->app->config('hypnotoad')->{listen}[0])[2];
    $::c->jsonrpc2->url('http://localhost:'.$port)->call(internal_version => 'pass', sub {
        my ($failed, $result, $error) = @_;
        if (defined $failed) {
            $cb->(undef, 2, 'Network Error');
        }
        elsif (defined $error) {
            $cb->($result, $error->{code}, $error->{message});
        }
        else {
            $cb->($result);
        }
    });
    return;
}

sub internal_version {
    my ($cb, $secret) = @_;
    if ($secret ne 'pass') {
        return $cb->(undef, 1, 'bad secret');
    }
    Mojo::IOLoop->timer(1 => sub {
        return $cb->($::VERSION);
    });
    return;
}


1;
