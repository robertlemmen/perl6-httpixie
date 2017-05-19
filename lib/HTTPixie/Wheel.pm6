unit class HTTPixie::Wheel;

has $.handler;
has $!buffer = buf8.new;
has $.id;

my $id-seq = 0;

method new() {
    self.bless(id => $id-seq++);
}

method put($input) {
    $!buffer ~= $input;
    say "[$!id] now have " ~ $!buffer.elems ~ " characters";
}
