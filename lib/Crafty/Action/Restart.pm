package Crafty::Action::Restart;

use strict;
use warnings;

use parent 'Crafty::Action::Base';

use Crafty::AppConfig;
use Crafty::Builder;

sub run {
    my $self = shift;
    my (%params) = @_;

    my $uuid = $params{build_id};

    return sub {
        my $respond = shift;

        $self->db->load($uuid)->then(
            sub {
                my ($build) = @_;

                if ($build && $build->restart) {
                    return $self->db->save($build);
                }
                else {
                    die 'not found';
                }
            },
            sub {
                $respond->([404, [], ['Not found']]);
            }
          )->then(
            sub {
                my ($build) = @_;

                my $app_config =
                  Crafty::AppConfig->new(root => $self->{root})
                  ->load($build->app);

                my $builder = Crafty::Builder->new(
                    app_config => $app_config,
                    root       => $self->{root}
                );

                $self->{builder} = $builder;

                my $promise = $builder->build(
                    $build,
                    on_pid => sub {
                        my ($pid) = @_;

                        $build->start($pid);

                        $self->db->save($build);
                    }
                );

                $respond->(
                    [
                        302, [Location => sprintf("/builds/%s", $build->uuid)],
                        ['']
                    ]
                );

                return $promise;
            }
          )->then(
            sub {
                my ($build, $status) = @_;

                $build->finish($status);

                return $self->db->save($build);
            }
          );
    };
}

1;