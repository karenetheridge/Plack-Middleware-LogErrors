use strict;
use warnings;
package Plack::Middleware::LogErrors;
# ABSTRACT: Map psgi.errors to psgix.logger or other logger

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

    die 'no psgix.logger in $env; cannot map psgi.errors to it!'
        if not $logger;

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

Using a logger you have already configured (using L<Log::Dispatch> as an
example):

    use Log::Dispatch;
    my $logger = Log::Dispatch->new;
    $logger->add( Log::Dispatch::File->new(...) );

    builder {
        enable 'LogDispatch', logger => $logger;
        enable 'LogErrors';
        $app;
    }

Using an explicitly defined logger:

    builder {
        enable 'LogErrors', logger => sub {
            my $args = shift;
            $logger->log(%$args);
        };
        $app;
    }

=head1 DESCRIPTION

=for stopwords psgi psgix middlewares

C<psgi.errors> defaults to C<stderr> in most backends, which results in
content going somewhere unhelpful like the server console.

This middleware simply remaps the C<psgi.errors> stream to the
C<psgix.logger> stream, or an explicit logger that you provide.

This is especially handy when used in combination with other middlewares
such as L<Plack::Middleware::LogWarn> (which diverts Perl warnings to
C<psgi.errors>);
L<Plack::Middleware::HTTPExceptions> (which diverts
uncaught exceptions to C<psgi.errors>);
and L<Plack::Middleware::AccessLog>, which defaults to C<psgi.errors> when not
passed a logger -- which is also automatically applied via L<plackup> (so if
you provided no C<--access-log> option indicating a filename, C<psgi.errors>
is used).

=head1 CONFIGURATION

=over 4

=item * C<logger>

A code reference for logging messages, that conforms to the
L<psgix.logger|PSGI::Extensions/SPECIFICATION> specification.
If not provided, C<psgix.logger> is used, or the application will generate an
error at runtime if there is no such logger configured.

=back

=head1 SUPPORT

=for stopwords irc

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Plack-Middleware-LogErrors>
(or L<bug-Plack-Middleware-LogErrors@rt.cpan.org|mailto:bug-Plack-Middleware-LogErrors@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 SEE ALSO

=begin :list

* L<PSGI::Extensions> - the definition of C<psgix.logger>
* L<PSGI/The-Error-Stream> - the definition of C<psgi.errors>
* L<Plack::Middleware::LogWarn> - maps warnings to C<psgi.errors>
* L<Plack::Middleware::HTTPExceptions> - maps exceptions to C<psgi.errors>
* L<Plack::Middleware::LogDispatch> - use a L<Log::Dispatch> logger for C<psgix.logger>
* L<Plack::Middleware::Log4perl> - use a L<Log::Log4perl> logger for C<psgix.logger>
* L<Plack::Middleware::SimpleLogger> - essentially the opposite of this module!

=end :list

=cut
