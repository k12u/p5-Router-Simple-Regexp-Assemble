package Router::Simple::Regexp::Assemble;

use strict;
use warnings;

use Regexp::Assemble;
use Router::Simple::Regexp::Assemble::Route;

use parent qw(Router::Simple);
use Data::Dumper;

our $VERSION = '0.01';
our $DEFAULT_VALUE = '__ROUTER_SIMPLE_DEFAULT__';

# TODO croak on match without finish
# TODO 稼働ログでリグレッションテスト

sub connect {
    my $self = shift;
    my $route = Router::Simple::Regexp::Assemble::Route->new(@_);
    push @{ $self->{routes} }, $route;
    return $self;
}

sub _match {
    my ($self, $env) = @_;

    $env = +{ PATH_INFO => $env } unless ref $env;

    for (
        [$env->{HTTP_HOST}, $env->{REQUEST_METHOD}],
        [$DEFAULT_VALUE,    $env->{REQUEST_METHOD}],
        [$env->{HTTP_HOST}, $DEFAULT_VALUE],
        [$DEFAULT_VALUE,    $DEFAULT_VALUE]
       ) {
        next unless defined $self->{ra}{ $_->[0] }{ $_->[1] };
        my $status =
            do {
                # notice that `match' comes from Regexp::Assemble.
                use re 'eval';
                $self->{ra}{$_->[0]}{$_->[1]}->match($env->{PATH_INFO})
            };
        next unless defined $status;

        my $matched_route = $self->{ra}{ $_->[0] }{ $_->[1] }->matched;
        my $route = $self->{dict}{ $_->[0] }{ $_->[1] }{$matched_route};

        my $matched = {
            action     => $route->{dest}->{action},
            controller => $route->{dest}->{controller},
        };
        return ($matched, $route);
    }

#     for my $route (@{$self->{routes}}) {
#         my $match = $route->match($env);
#         if ($match){
#             warn Dumper($route);
#             warn Dumper($match);
#         }
#         return ($match, $route) if $match;
#     }
    return undef; # not matched.
}

sub finish {
    my $self = shift;
    my $ra = Regexp::Assemble->new->track(1);

    for my $r( @{ $self->{routes} } ){
        next unless($r->{pattern_str} or $r->{pattern_re});

        for my $method ( @{ $r->{method} }, $DEFAULT_VALUE ){
            my $host = $r->{host} || $DEFAULT_VALUE;

            my $ra = $self->_get_ra($host, $method);
            my $str = $r->{pattern_str};
            if($r->{_regexp_capture}){
#warn $r->{pattern_re};
                $ra->add($r->{pattern_re});
            }
            else {
#warn qr{^$str$};
                $ra->add(qr{^$str$});
            }
            $self->{dict}{ $host }{ $method }{ $r->{pattern_re} } = $r;
#            $self->{ra}{   $host }{ $method } =  $ra;
        }
    }
}

sub _get_ra {
    my ($self, $host, $method) = @_;
    $self->{ra}{$host}{$method} ||= _gen_ra();
}

sub _gen_ra {
    Regexp::Assemble->new->track(1);
}


1;
__END__

=head1 NAME

Router::Simple::Regexp::Assemble - fine-tuned Router::Simple by using Regexp::Assemble

=head1 SYNOPSIS

  use Router::Simple::Assembled;

=head1 DESCRIPTION

Router::Simple::Assembled is fine-tuned implementation of Router::Simple module.
This module is made for large amount of route rules.

Note that using many `host' rules may result in performance disadvantage and/or memory overuse.

=head1 AUTHOR

KAWAMOTO, Minoru E<lt>minoru-cpan@k12u.orgE<gt>

=head1 SEE ALSO

L<Router::Simple>
L<Regexp::Assemble>

=head1 CAVEATS

 Tightly-coupled with Router-Simple-0.08

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
