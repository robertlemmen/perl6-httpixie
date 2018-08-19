unit class HTTPixie::Message;

has $.headers is rw = {};
has $.body is rw = Nil;

method parse-start-line($start-line) {
    # needs to be implemented by child classes
    ...
}

method serialize-start-line() {
    # needs to be implemented by child classes
    ...
}

method parse-header($header-text) {
    my @lines = $header-text.split("\r\n");

    # XXX parse request-line
    self.parse-start-line(shift @lines);

    for @lines -> $line {
        my ($k, $v) = $line.split(":", 2);
        $v .= trim-leading;
        $!headers{$k} = $v;
        # XXX cookie headers are special...
    } 
}

method serialize-header() {
    my $buffer = self.serialize-start-line();
    for $!headers.pairs -> $h {
        $buffer ~= "\r\n{$h.key}: {$h.value}".encode;
    }
    $buffer ~= "\r\n\r\n".encode;
    return $buffer;
}
