package Profile81::Web::Controller::Register;
use Mojo::Base 'Mojolicious::Controller';
use DateTime;
use DateTime::Format::MySQL;

sub action {
    my $self = shift;
    my $nt = $self->nt;
    return $self->redirect_to('/') unless $nt->authorized;
    my $user_info = $self->nt->show_user($self->session('twitter')->{user_id});
    return $self->redirect_to('/') unless $user_info;

    my $db = $self->db;
    if ( my $user = $db->single( 'user', { id => $user_info->{id} } ) ) {
        $db->update('user', {
            image_url => $user_info->{profile_image_url},
            screen_name => $user_info->{screen_name},
        });
    } else {
        $db->insert(
            'user',
            {
                twitter_id => $user_info->{id},
                screen_name => $user_info->{screen_name},
                image_url   => $user_info->{profile_image_url},
                created_on  => DateTime::Format::MySQL->format_datetime(
                    DateTime->now( time_zone => 'Asia/Tokyo' )
                ),
            }
        );
    }
    $self->redirect_to('/');
}

1;
