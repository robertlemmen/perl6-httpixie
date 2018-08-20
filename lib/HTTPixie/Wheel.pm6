unit class HTTPixie::Wheel;

use HTTPixie::Request;
use HTTPixie::Response;

has $.handler;
has $!buffer = buf8.new;
has $!parse-pos = 0;
has $!message = Nil;
has $!content-length = 0;
has $.message-class;

constant $header-sep = "\r\n\r\n".encode;

method put($input) {
    $!buffer ~= $input;

    # look for end of header
    if ! defined $!message {
        for $!parse-pos..($!buffer.elems-4) -> $i {
            if (       ($!buffer[$i]   == $header-sep[0])
                    && ($!buffer[$i+1] == $header-sep[1])
                    && ($!buffer[$i+2] == $header-sep[2])
                    && ($!buffer[$i+3] == $header-sep[3]) ) {
                
                my $header = $!buffer.subbuf(0, $i).decode(encoding => 'ISO-8859-1');
                # XXX also reset buffer to not contain header anymore

                if 'request' eq $!message-class {
                    $!message = HTTPixie::Request.new;
                }
                elsif 'response' eq $!message-class {
                    $!message = HTTPixie::Response.new;
                }
                $!message.parse-header($header);
                if defined $!message.headers<Content-Length> {
                    $!content-length = $!message.headers<Content-Length>.Numeric;
                               last;
                }
            } 
            else {
                $!parse-pos = $i+1;
            }
        }
    }
    # if we have a header, extract body and handle message
    if defined $!message {
        if $!buffer.elems >= $!parse-pos + $!content-length {
            $!message.body = $!buffer.subbuf($!parse-pos + 4, $!content-length).decode(encoding => 'UTF-8');
            $!handler($!message);

            $!buffer = buf8.new;
            $!parse-pos = 0;
            $!message = Nil;
            $!content-length = 0;
        }
    }
}
