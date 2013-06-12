use strict;
use warnings;
package Plack::Middleware::LogErrors;
# ABSTRACT: ...

use parent 'Plack::Middleware';

use Plack::Util::Accessor 'logger';
use Scalar::Util 'reftype';

sub prepare_app
{
    my $self = shift;
    die "'logger' is not a coderef!"
        if $self->logger and not __isa_coderef($self->logger);
}

sub call
{
    my ($self, $env) = @_;

    my $logger = $self->logger || $env->{'psgix.logger'};
    if (not $logger)
    {
        die 'no psgix.logger in $env; cannot map psgi.errors to it!';
    }

    # convert to something that matches the psgi.errors specs
    $env->{'psgi.errors'} = Plack::Middleware::LogErrors::LogHandle->new($logger);

    return $self->app->($env);
}

sub __isa_coderef
{
    ref $_[0] eq 'CODE'
        or (reftype($_[0]) || '') eq 'CODE'
        or overload::Method($_[0], '&{}')
}

package Plack::Middleware::LogErrors::LogHandle;
# ABSTRACT: convert psgix.logger-like logger into an IO::Handle-like object

sub new
{
    my ($class, $logger) = @_;
    return bless { logger => $logger }, $class;
}

sub print
{
    my ($self, $message) = @_;
    $self->{logger}->({
        level => 'error',
        message => $message,
    });
}

1;
__END__

=pod

=head1 SYNOPSIS

    use Plack::Middleware::LogErrors;

    ...

=head1 DESCRIPTION

...

=head1 FUNCTIONS/METHODS

=over 4

=item * C<foo>

...

=back

=head1 SUPPORT

=for stopwords irc

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Plack-Middleware-LogErrors>
(or L<bug-Plack-Middleware-LogErrors@rt.cpan.org|mailto:bug-Plack-Middleware-LogErrors@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 ACKNOWLEDGEMENTS

...

=head1 SEE ALSO

=begin :list

* L<foo>

=end :list

=cut
