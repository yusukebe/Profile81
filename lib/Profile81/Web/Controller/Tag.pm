package Profile81::Web::Controller::Tag;
use Mojo::Base 'Mojolicious::Controller';

sub tag {
    my $self = shift;
    my $tag_name = $self->stash->{tag_name} || '';
    my $tag = $self->db->single('tag', { tag_name => $tag_name });
    return $self->render_not_found unless $tag;
    $self->stash->{tag} = $tag;
    my @profile_tags = $self->db->search('profile_tag',
                                     { tag_name => $tag_name }, { order_by => 'id desc' });
    my @users;
    for my $profile_tag (@profile_tags) {
        push @users, $self->db->single('user', { id => $profile_tag->user_id });
    }
    $self->stash->{users} = \@users;
}

1;
