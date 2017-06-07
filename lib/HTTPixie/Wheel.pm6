unit class HTTPixie::Wheel;

use HTTPixie::Request;

has $.handler;
has $!buffer = buf8.new;
has $!parse-pos = 0;

constant $header-sep = "\r\n\r\n".encode;

method put($input) {
    $!buffer ~= $input;

    # XXX need to chomp newlines before verb? check spec...

    # look for end of header
    for $!parse-pos..($!buffer.elems-4) -> $i {
        $!parse-pos = $i+1;
        if (       ($!buffer[$i]   == $header-sep[0])
                && ($!buffer[$i+1] == $header-sep[1])
                && ($!buffer[$i+2] == $header-sep[2])
                && ($!buffer[$i+3] == $header-sep[3]) ) {
            my $header = $!buffer.subbuf(0, $i).decode(encoding => 'ISO-8859-1');
            # XXX also reset buffer to not contain header anymore

            # XXX need to know which role we are in to determine whether
            # we parse as request or response
            my $request = HTTPixie::Request.new;
            $request.parse-header($header);

            say $request.perl;

            last;
        }
    }
}
