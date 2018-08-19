use HTTPixie::Message;

unit class HTTPixie::Response is HTTPixie::Message;

has $.http-version;
has $.status-code;
has $.status-phrase;

method serialize-start-line() {
    return "$.http-version $.status-code $.status-phrase".encode;
}

