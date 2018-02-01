#!/usr/bin/perl

use v5.14;

use Mojolicious::Lite;

use POSIX qw(strftime);

post '/' => sub {
    my ($c) = @_;

    my $lines = '';

    my $value_list = $c->req->json;

    for my $value (@$value_list) {
        my $keys = join ',', $value->{plugin}, map { join '=', $_ => $value->{$_} } grep { defined $value->{$_} and $value->{$_} ne '' } qw(host plugin_instance type type_instance);
        my $values = $value->{values};
        my $fields = join ',', map { join '=', $value->{dsnames}[$_] => $values->[$_] } 0 .. $#$values;
        my $time = int($value->{time} * 1e9);
        $lines .= (join ' ', $keys, $fields, $time) . "\n";
    }

    $c->ua->post('http://127.0.0.1:8086/write?db=collectd' => $lines => sub {
        my ($ua, $tx) = @_;

        $c->app->log->info(join ' ',
            $c->tx->original_remote_address,
            '-',
            '-',
            strftime('[%d/%b/%Y:%H:%M:%S %z]', localtime),
            '"' . $c->req->method,
            $c->req->url,
            'HTTP/' . $c->req->version . '"',
            ($tx->res->code//'520'),
            $c->req->body_size,
            '"' . ($c->req->headers->referrer//'') . '"',
            '"' . ($c->req->headers->user_agent//'') . '"',
            ($tx->res->headers->header('Request-Id')//''),
            $tx->req->body_size,
        );

        $c->render(text => $tx->res->body, status => $tx->res->code);
    });
};

app->start;
