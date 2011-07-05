package Router::Simple::Regexp::Assemble::Route;

use strict;
use warnings;

use Router::Simple::Route;

use parent qw(Router::Simple::Route);

our $VERSION = '0.01';

sub new {
    my $class = shift;

    # connect([$name, ]$pattern[, \%dest[, \%opt]])
    if (@_ == 1 || ref $_[1]) {
        unshift(@_, undef);
    }

    my ($name, $pattern, $dest, $opt) = @_;
    Carp::croak("missing pattern") unless $pattern;
    my $row = +{
        name     => $name,
        dest     => $dest,
        on_match => $opt->{on_match},
    };
    if (my $method = $opt->{method}) {
        $method = [$method] unless ref $method;
        $row->{method} = $method;

        my $method_re = join '|', @{$method};
        $row->{method_re} = qr{^(?:$method_re)$};
    }
    if (my $host = $opt->{host}) {
        $row->{host} = $host;
        $row->{host_re} = ref $host ? $host : qr(^\Q$host\E$);
    }

    $row->{pattern} = $pattern;

    # compile pattern
    my @capture;
    if (ref $pattern) {
        $row->{_regexp_capture} = 1;
        $row->{pattern_re} = $pattern;
    }
    else {
        $row->{pattern_str} = do {
            $pattern =~ s!
                \{((?:\{[0-9,]+\}|[^{}]+)+)\} | # /blog/{year:\d{4}}
                :([A-Za-z0-9_]+)              | # /blog/:year
                (\*)                          | # /blog/*/*
                ([^{:*]+)                       # normal string
            !
                if ($1) {
                    my ($name, $pattern) = split /:/, $1, 2;
                    push @capture, $name;
                    $pattern ? "($pattern)" : "([^/]+)";
                } elsif ($2) {
                    push @capture, $2;
                    "([^/]+)";
                } elsif ($3) {
                    push @capture, '__splat__';
                    "(.+)";
                } else {
                    quotemeta($4);
                }
            !gex;
            $pattern;
        };
        my $p = $row->{pattern_str};
        $row->{pattern_re} = qr{^$p$};
    }
    $row->{capture} = \@capture;
    $row->{dest}  ||= +{};

    return bless $row, $class;
}



1;
__END__

=head1 NAME

Router::Simple::Regexp::Assemble::Route - route object

=head1 DESCRIPTION

This class represents route.

=head1 ATTRIBUTES

This class provides following attributes.

=over 4

=item name

=item dest

=item on_match

=item method

=item host

=item pattern

=back

=head1 SEE ALSO

L<Router::Simple>
L<Router::Simple::Regexp::Assemble>

