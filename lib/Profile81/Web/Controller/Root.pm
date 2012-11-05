package Profile81::Web::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;
    my @users = $self->db->search('user', {}, { order_by => 'id desc' });
    $self->stash->{users} = \@users;
}

sub search {
    my $self = shift;
    my $id = $self->req->param('id');
    my $user = $self->db->single('user', { id => $id });
    return $self->render_not_found unless $user;
    $self->redirect_to('/' . $user->id);
}

1;
