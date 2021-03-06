use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::MonkeyMock;

use Promises qw(deferred);

use_ok 'Crafty::PubSub';

subtest 'subscribes and publishes' => sub {
    my $pubsub = _build();

    $pubsub->listen('/tmp/sock');

    my $event;
    my $data;
    $pubsub->subscribe(
        'my.event',
        sub {
            ($event, $data) = @_;

            return deferred->resolve;
        }
    );

    my $promised;
    $pubsub->publish('my.event', { foo => 'bar' })->then(
        sub {
            $promised++;
        }
    );

    is $event, 'my.event';
    is_deeply $data, { foo => 'bar' };
    is $promised, 1;
};

subtest 'subscribes and publishes to everything' => sub {
    my $pubsub = _build();

    $pubsub->listen('/tmp/sock');

    my $called;
    $pubsub->subscribe(
        '*',
        sub {
            $called++;

            return deferred->resolve;
        }
    );

    $pubsub->publish('my.event',    { foo => 'bar' });
    $pubsub->publish('other.event', { foo => 'bar' });

    is $called, 2;
};

subtest 'does nothing when no subscribers' => sub {
    my $pubsub = _build();

    $pubsub->listen('/tmp/sock');

    my $called;
    $pubsub->subscribe(
        'my.event',
        sub {
            $called++;
        }
    );

    $pubsub->publish('other.event', { foo => 'bar' });

    ok !$called;
};

subtest 'sends request when not owner' => sub {
    my $request;

    my $pubsub = _build();
    $pubsub = Test::MonkeyMock->new($pubsub);
    $pubsub->mock(_push_event => sub { shift; ($request) = @_; return deferred->resolve->promise; });
    $pubsub->connect('/tmp/sock');

    my $cv = AnyEvent->condvar;

    $pubsub->publish('my.event', { foo => 'bar' })->then(
        sub {
            $cv->send;
        }
    );

    $cv->wait;

    is_deeply $request, [ 'my.event', { foo => 'bar' } ];
};

done_testing;

sub _build {
    return Crafty::PubSub->clear->instance;
}
