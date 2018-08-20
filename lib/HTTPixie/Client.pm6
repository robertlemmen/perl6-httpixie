unit class HTTPixie::Client;

# XXX weirdly, if I comment this out it fails silently. should really
# complain...
use HTTPixie::Wheel;
use HTTPixie::Response;

method execute($request) {
    # XXX open socket to host/port from Host header,
    # serialize request, wait for response data and pipe into wheel. 
    # return a promise that will be fulfilled by the wheel handler with a 
    # response object
    #
    # XXX proper handling, default ports
    my ($host, $port) = $request.headers<Host>.split(':');
    # XXX look up connection in connection cache
    my $response-promise = Promise.new;
    my $socket-promise = IO::Socket::Async.connect($host, $port);
    $socket-promise.then({
        say "connected!";
        say $socket-promise.status;
        my $socket = $socket-promise.result;
        # XXX there must be a better way to detect failure and do the then
        # really. also how do I get the error from connect?
        my $wheel = HTTPixie::Wheel.new(message-class => 'response',
                                        handler => sub ($rs) {
                                            say "got response: " ~ $rs.perl;
                                        });
        $socket.Supply(:bin).tap( -> $input {
            say "input from {$*THREAD.id}";
            $wheel.put($input);
        },
        done => {
            say "connection lost";
        });
        $socket.write($request.serialize-header);
        # XXX send body
    });
    
    return $response-promise;
}
