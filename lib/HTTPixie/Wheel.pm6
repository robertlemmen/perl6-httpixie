unit class HTTPixie::Wheel;

use HTTPixie::Request;

has $.handler;
has $!buffer = buf8.new;
has $!parse-pos = 0;
has $!request = Nil;
has $!content-length = 0;
has $!lock = Lock.new;

constant $header-sep = "\r\n\r\n".encode;

method put($input) {
    $!lock.lock;
    start {
        $!buffer ~= $input;

        # look for end of header
        if ! defined $!request {
            for $!parse-pos..($!buffer.elems-4) -> $i {
                if (       ($!buffer[$i]   == $header-sep[0])
                        && ($!buffer[$i+1] == $header-sep[1])
                        && ($!buffer[$i+2] == $header-sep[2])
                        && ($!buffer[$i+3] == $header-sep[3]) ) {
                    
                    my $header = $!buffer.subbuf(0, $i).decode(encoding => 'ISO-8859-1');
                    # XXX also reset buffer to not contain header anymore

                    $!request = HTTPixie::Request.new;
                    $!request.parse-header($header);
                    if defined $!request.headers<Content-Length> {
                        $!content-length = $!request.headers<Content-Length>.Numeric;
                    }
                    last;
                } 
                else {
                    $!parse-pos = $i+1;
                }
            }
        }
        # if we have a header, extract body and handle request
        if defined $!request {
            if $!buffer.elems >= $!parse-pos + $!content-length {
                $!request.body = $!buffer.subbuf($!parse-pos + 4, $!content-length).decode(encoding => 'UTF-8');
                $!handler($!request);
                # XXX reset everything so that we can read the next message, also
                # shift buffer
            }
        }
        $!lock.unlock;
    }
}
