unit class HTTPixie::Server;

use HTTPixie::Wheel;

has $.host;
has $.port;
has $.handler;
has $!done;
has $!srv-tap;

# XXX handler, when we have a RQ we call handler with that. if it returns
# a response, serialize onto socket. if it's a promise, chain onto it.

method start() {
    my $h = $!host // '0.0.0.0';
    my $p = $!port // 6060;
    say "starting tcp server on $h:$p";
    my $server-socket = IO::Socket::Async.listen($h, $p);
    $!done = Promise.new;
    $!srv-tap = $server-socket.tap( -> $client-socket {
        say "accepted connection";
        my $wheel = HTTPixie::Wheel.new(message-class => 'request',
                            handler => sub ($rq) {
                                my $response = $!handler($rq);
                                if $response.body {
                                    my $body-buf = $response.body.encode;
                                    $response.headers<Content-Length> = $body-buf.bytes;
                                    $client-socket.write($response.serialize-header);
                                    $client-socket.write($body-buf);
                                }
                                else {
                                    $client-socket.write($response.serialize-header);
                                }
                                # XXX needs much better heuristic, HTTP/1.1 and
                                # all
                                my $client-conn = $rq.headers<Connection>//"??";
                                if $client-conn ne "Keep-Alive" {
                                    my $client-conn = $rq.headers<Connection>//"??";
                                    say "closing socket due to [$client-conn]";
                                    $client-socket.close;
                                }
                            });
        $client-socket.Supply(:bin).act( -> $input {
            say "input from {$*THREAD.id}";
            # XXX how can we do this in parallel? we would need to lock the
            # wheel to make sure we are 
            # XXX I hope that act is only a critical section per Supply. if it
            # is the docs may need improvement
            $wheel.put($input);
        },
        done => {
            say "connection lost";
        });
    });
    return $!done;
}

method stop() {
    say "shutting down listener";
    $!srv-tap.close;
    $!done.keep;
}
