unit class HTTPixie::Server;

use HTTPixie::Wheel;

has $.host;
has $.port;
has $!done;
has $!srv-tap;

method start() {
    my $h = $!host // '0.0.0.0';
    my $p = $!port // 6060;
    say "starting tcp server on $h:$p";
    my $server-socket = IO::Socket::Async.listen($h, $p);
    $!done = Promise.new();
    $!srv-tap = $server-socket.tap( -> $client-socket {
        say "accepted connection";
        my $wheel = HTTPixie::Wheel.new;
        $client-socket.Supply(:bin).act( -> $input {
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
