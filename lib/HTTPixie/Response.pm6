use HTTPixie::Message;

unit class HTTPixie::Response is HTTPixie::Message;

has $.http-version;
has $.status-code;
has $.status-phrase;

method parse-start-line($response-line) {
    # XXX \S is not quite right for any of these
    if ($response-line ~~ /^ (\S+) \s (\S+) \s (.*) $/) {
        ($!http-version, $!status-code, $!status-phrase) = ~$0, ~$1, ~$2;
    }
    # XXX throw exception
}

method serialize-start-line() {
    return "$.http-version $.status-code $.status-phrase".encode;
}

