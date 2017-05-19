unit class HTTPixie::Message;

has $.headers is rw = {};

method !parse-start-line($start-line) {
    # needs to be implemented by child classes
    ...
}

method parse-header($header) {
    my @lines = $header.split("\r\n");

    # XXX parse request-line
    self.parse-start-line(shift @lines);

    for @lines -> $line {
        my ($k, $v) = $line.split(":", 2);
        $v .= trim-leading;
        $.headers{$k} = $v;
        # XXX cookie headers are special...
    } 
}
