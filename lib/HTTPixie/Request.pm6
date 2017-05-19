use HTTPixie::Message;

unit class HTTPixie::Request is HTTPixie::Message;

has $.method;
has $.request-target;
has $.http-version;

method parse-start-line($request-line) {
    # XXX \S is not quite right for method
    # XXX \S may not be right for target
    # XXX \S is not right for version
    if ($request-line ~~ /^ (\S+) \s (\S+) \s (\S+) $/) {
        ($!method, $!request-target, $!http-version) = ~$0, ~$1, ~$2;
    }
    # XXX throw exception
}

