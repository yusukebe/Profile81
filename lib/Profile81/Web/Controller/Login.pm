package Profile81::Web::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';
use Net::Twitter::Lite;

sub facebook {
    my $self = shift;
    return $self->render_not_found;
}

sub twitter {
    my $self = shift;
    my $nt = $self->nt;
    my $url = $nt->get_authorization_url(callback => $self->req->url->base . '/callback/twitter');
    $self->session( twitter_token => $nt->request_token );
    $self->session( twitter_token_secret => $nt->request_token_secret );
    $self->redirect_to($url);
}

sub twitter_callback {
    my $self = shift;
    my $nt = $self->nt;
    $nt->request_token($self->session('twitter_token'));
    $nt->request_token_secret($self->session('twitter_token_secret'));
    my $verifier = $self->req->param('oauth_verifier');
    my($access_token, $access_token_secret, $user_id, $screen_name) =
        $nt->request_access_token(verifier => $verifier);
    my $twitter = {
        access_token =>  $access_token,
        access_token_secret => $access_token_secret,
        user_id => $user_id,
        screen_name => $screen_name,
    };
    $self->session('twitter', undef);
    $self->session('twitter', $twitter);
    $self->redirect_to('/');
}

sub logout {
    my $self = shift;
    $self->session('twitter', undef);
    $self->session('user', undef);
    $self->redirect_to('/');
}

1;
