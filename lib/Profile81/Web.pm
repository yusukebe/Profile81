package Profile81::Web;
use Mojo::Base 'Mojolicious';
use Teng::Schema::Loader;
use Net::Twitter::Lite;

sub startup {
    my $self = shift;

    my $config = $self->plugin('Config');

    $self->helper(
        db => sub {
            my $db = Teng::Schema::Loader->load(
                connect_info => $config->{connect_info},
                namespace    => 'Profile81::DB'
            );
            $db->load_plugin('Count');
            return $db;
        }
    );

    $self->helper(
        nt => sub {
            my $c = shift;
            my $nt = Net::Twitter::Lite->new(
                consumer_key => $config->{twitter_consumer_key},
                consumer_secret => $config->{twitter_consumer_secret},
                legacy_lists_api => 0,
            );
            if(my $data = $c->session('twitter')) {
                $nt->access_token($data->{access_token});
                $nt->access_token_secret($data->{access_token_secret});
            }
            return $nt;
        }
    );

    $self->helper(
        user => sub {
            my $c = shift;
            return undef unless($c->session('twitter'));
            my $user_info = $c->nt->show_user($c->session('twitter')->{user_id});
            if(my $user = $self->db->single('user', { twitter_id => $user_info->{id} })) {
                return $user;
            }
            return undef;
        }
    );

    $self->helper(
        b => sub {
            my $self = shift;
            return Mojo::ByteStream->new(@_);
        }
    );

    my $r = $self->routes;
    $r->namespace('Profile81::Web::Controller');
    $r->route('/:profile_id', profile_id => qr/\d+/)->via('GET')->to('profile#show');
    $r->get('/')->to('root#index');
    $r->get('/login/facebook')->to('login#facebok');
    $r->get('/login/twitter')->to('login#twitter');
    $r->get('/callback/twitter')->to('login#twitter_callback');
    $r->route('/logout')->to('login#logout');
    $r->post('/register')->to('register#action');
    $r->get('/profile')->to('profile#index');
    $r->post('/profile')->to('profile#edit');
    $r->post('/profile/delete')->to('profile#delete');
    $r->get('/tag/:tag_name')->to('tag#tag');
    $r->get('/search')->to('root#search');
}

1;
