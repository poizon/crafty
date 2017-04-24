package Crafty::Pool::Worker;
use strict;
use warnings;

use AnyEvent::Fork::Pool;
use AnyEvent::Fork::RPC;
use Crafty::Runner;

sub init {
}

my $count = 0;

sub run {
    my ($done, $build, $cmds) = @_;

    my $uuid = $build->{uuid};

    AnyEvent::Fork::RPC::event($$, 'build.started', $uuid);

    my $runner = Crafty::Runner->new(
        stream    => 'data/builds/' . $uuid . '.log',
        build_dir => 'data/builds/' . $uuid
      )->run(
        cmds   => $cmds,
        on_pid => sub {
            my ($pid) = @_;

            AnyEvent::Fork::RPC::event($$, 'build.pid', $uuid, $pid);
        },
        on_eof => sub {
            my ($exit_code) = @_;

            AnyEvent::Fork::RPC::event($$, 'build.done', $uuid, $exit_code);

            $done->() if $done;
        },
        on_error => sub {
            AnyEvent::Fork::RPC::event($$, 'build.error', $uuid);

            $done->() if $done;
        }
      );

    #++$count == 1
    #and AnyEvent::Fork::Pool::retire();

    return;
}

1;