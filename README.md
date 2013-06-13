# NAME

Plack::Middleware::LogErrors - Map psgi.errors to psgix.logger or other logger

# VERSION

version 0.001

# SYNOPSIS

Using a logger you have already configured (using [Log::Dispatch](http://search.cpan.org/perldoc?Log::Dispatch) as an
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

# DESCRIPTION

`psgi.errors` defaults to `stderr` in most backends, which results in
content going somewhere unhelpful like the server console.

This middleware simply remaps the `psgi.errors` stream to the
`psgix.logger` stream, or an explicit logger that you provide.

This is especially handy when used in combination with other middlewares
such as [Plack::Middleware::LogWarn](http://search.cpan.org/perldoc?Plack::Middleware::LogWarn) (which diverts Perl warnings to
`psgi.errors`);
[Plack::Middleware::HTTPExceptions](http://search.cpan.org/perldoc?Plack::Middleware::HTTPExceptions) (which diverts
uncaught exceptions to `psgi.errors`);
and [Plack::Middleware::AccessLog](http://search.cpan.org/perldoc?Plack::Middleware::AccessLog), which defaults to `psgi.errors` when not
passed a logger -- which is also automatically applied via [plackup](http://search.cpan.org/perldoc?plackup) (so if
you provided no `--access-log` option indicating a filename, `psgi.errors`
is used).

# CONFIGURATION

- `logger`

    A code reference for logging messages, that conforms to the
    [psgix.logger](http://search.cpan.org/perldoc?PSGI::Extensions#SPECIFICATION) specification.
    If not provided, `psgix.logger` is used, or the application will generate an
    error at runtime if there is no such logger configured.

# SUPPORT

Bugs may be submitted through [the RT bug tracker](https://rt.cpan.org/Public/Dist/Display.html?Name=Plack-Middleware-LogErrors)
(or [bug-Plack-Middleware-LogErrors@rt.cpan.org](mailto:bug-Plack-Middleware-LogErrors@rt.cpan.org)).
I am also usually active on irc, as 'ether' at `irc.perl.org`.

# SEE ALSO

- [PSGI::Extensions](http://search.cpan.org/perldoc?PSGI::Extensions) - the definition of `psgix.logger`
- ["The-Error-Stream" in PSGI](http://search.cpan.org/perldoc?PSGI#The-Error-Stream) - the definition of `psgi.errors`
- [Plack::Middleware::LogWarn](http://search.cpan.org/perldoc?Plack::Middleware::LogWarn) - maps warnings to `psgi.errors`
- [Plack::Middleware::HTTPExceptions](http://search.cpan.org/perldoc?Plack::Middleware::HTTPExceptions) - maps exceptions to `psgi.errors`
- [Plack::Middleware::Log::Contextual](http://search.cpan.org/perldoc?Plack::Middleware::Log::Contextual) - use a [Log::Contextual](http://search.cpan.org/perldoc?Log::Contextual) logger for `psgix.logger`
- [Plack::Middleware::LogDispatch](http://search.cpan.org/perldoc?Plack::Middleware::LogDispatch) - use a [Log::Dispatch](http://search.cpan.org/perldoc?Log::Dispatch) logger for `psgix.logger`
- [Plack::Middleware::Log4perl](http://search.cpan.org/perldoc?Plack::Middleware::Log4perl) - use a [Log::Log4perl](http://search.cpan.org/perldoc?Log::Log4perl) logger for `psgix.logger`
- [Plack::Middleware::SimpleLogger](http://search.cpan.org/perldoc?Plack::Middleware::SimpleLogger) - essentially the opposite of this module!

# AUTHOR

Karen Etheridge <ether@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
