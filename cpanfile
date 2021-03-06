requires 'AnyEvent';
requires 'AnyEvent::Fork';
requires 'AnyEvent::HTTP';
requires 'AnyEvent::DBI';
requires 'EV';
requires 'Promises';

requires 'Moo';
requires 'Time::Moment';
requires 'Class::Load';
requires 'JSON';
requires 'Routes::Tiny';
requires 'SQL::Composer';
requires 'DBD::SQLite';
requires 'Text::Caml';
requires 'Data::UUID';
requires 'Input::Validator';
requires 'YAML::Tiny';
requires 'Kwalify';

requires 'CGI::Compile';
requires 'CGI::Emulate::PSGI';
requires 'Plack';
requires 'Plack::App::EventSource';
requires 'Plack::Middleware::ReverseProxy';
requires 'Plack::Middleware::Session';
requires 'Twiggy';

requires 'Digest::Bcrypt';

on 'test' => sub {
    requires 'Test::More';
    requires 'Test::MonkeyMock';
    requires 'Test::Deep';
    requires 'Test::TempDir::Tiny';
};
