package Crafty::Action::Events;
use Moo;
extends 'Crafty::Action::Base';

use Promises qw(deferred);
use JSON ();
use Plack::App::EventSource;
use Crafty::PubSub;
use Crafty::Log;

sub run {
    my $self = shift;
    my (%params) = @_;

    return sub {
        my $respond = shift;

        my $cb = Plack::App::EventSource->new(
            headers    => [ 'Access-Control-Allow-Credentials', 'true' ],
            handler_cb => sub {
                my ($conn, $env) = @_;

                Crafty::PubSub->instance->subscribe(
                    '*' => sub {
                        my ($ev, $data) = @_;

                        eval {
                            $conn->push(JSON::encode_json({ type => $ev, data => $data }));
                            1;
                        } or do {
                            $conn->close;
                        };

                        return deferred->resolve;
                    }
                );
            }
        )->call($self->env);

        $cb->($respond);
    };
}

1;
