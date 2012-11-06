package Profile81::Web::Controller::Profile;
use Mojo::Base 'Mojolicious::Controller';
use DateTime;
use DateTime::Format::MySQL;
use FormValidator::Lite;
use HTML::FillInForm::Lite;
use Encode;
use Text::Tags::Parser;
use LWP::UserAgent;
use utf8;

sub index {
    my $self = shift;
    my $user = $self->user;
    return $self->render_not_found unless $user;
    my $db = $self->db;
    my $profile = $db->single('profile', { user_id => $user->id });
    $self->stash->{profile} = $profile;
    my @profile_tags = $db->search('profile_tag', { user_id => $user->id });
    $self->stash->{profile_tags} = \@profile_tags;
    my @recommend_tags = $db->search('tag', {}, { limit => 40, order_by => 'user_count desc' });
    $self->stash->{recommend_tags} = \@recommend_tags;
}

sub edit {
    my $self = shift;
    my $user = $self->user;
    return $self->render_not_found unless $user;
    my $db = $self->db;

    my $validator = FormValidator::Lite->new( $self->req );
    $validator->set_message(
        'body.length' => '本文が長すぎます(1,000文字以内)',
        'tags_text.length' => 'タグが長すぎます',
        'facebook_name' => 'Facebook Nameが長すぎます'
    );
    my $res = $validator->check(
        body => [ [qw/LENGTH 1 1000/] ],
        tags_text => [ [qw/LENGTH 1 400/] ],
        facebook_name => [ [qw/LENGTH 1 100/] ],
    );
    my @error_messages;
    if($validator->has_error) {
        for my $message ( $validator->get_error_messages ) {
            push @error_messages, $message;
        }
        $self->stash->{profile} = $db->single('profile', { user_id => $user->id});
        $self->stash->{error_messages} = \@error_messages;
        my @profile_tags = $db->search('profile_tag', { user_id => $user->id });
        $self->stash->{profile_tags} = \@profile_tags;
        my @recommend_tags = $db->search('tag', {}, { limit => 40, order_by => 'user_count desc' });
        $self->stash->{recommend_tags} = \@recommend_tags;
        my $html = $self->render_partial('/profile/index')->to_string;
        return $self->render_text(
            HTML::FillInForm::Lite->fill(\$html, $self->req->params),
            format => 'html'
        );
    }
    
    if(my $facebook_name = $self->req->param('facebook_name')) {
        my $ua = LWP::UserAgent->new;
        my $res = $ua->get('https://graph.facebook.com/' . $facebook_name);
        if($res->is_error) {
            push @error_messages, '有効なFacebook Nameではありません';
            $self->stash->{profile} = $db->single('profile', { user_id => $user->id});
            $self->stash->{error_messages} = \@error_messages;
            my @profile_tags = $db->search('profile_tag', { user_id => $user->id });
            $self->stash->{profile_tags} = \@profile_tags;
            my @recommend_tags = $db->search('tag', {}, { limit => 40, order_by => 'user_count desc' });
            $self->stash->{recommend_tags} = \@recommend_tags;
            my $html = $self->render_partial('/profile/index')->to_string;
            return $self->render_text(
                HTML::FillInForm::Lite->fill(\$html, $self->req->params),
                format => 'html'
            );
        }
    }

    my $txn = $db->txn_scope;

    my $now = DateTime::Format::MySQL->format_datetime(DateTime->now( time_zone => 'Asia/Tokyo' ));
    unless($db->single('profile', { user_id => $user->id})) {
        $db->insert('profile', {
            user_id => $user->id,
            body => $self->req->param('body'),
            facebook_name => $self->req->param('facebook_name'),
            created_on => $now,
            updated_on => $now,
        } );
    }else{
        $db->update('profile', { body => decode_utf8($self->req->param('body')), updated_on => $now,
                                     facebook_name => $self->req->param('facebook_name'),
                             }, 
                { user_id => $user->id } );
    }

    my @profile_tags = $db->search('profile_tag', { user_id => $user->id });
    for my $profile_tag (@profile_tags) {
        $db->delete('profile_tag', { id => $profile_tag->id });
    }

    my @tags = Text::Tags::Parser->new->parse_tags($self->req->param('tags_text'));

    for my $tag (@tags) {
        next if $tag =~ /^\s+$/;
        if ( $db->single('tag', { tag_name => lc $tag } ) ) {
        }else{
            $db->insert('tag',{
                user_count => 0,
                tag_name => lc $tag,
                label => $tag,
            });
        }
        $db->insert('profile_tag', {
            tag_name => lc $tag,
            tag_label => $tag,
            user_id => $user->id,
            created_on => $now,
        });
        my $user_count = $db->count('profile_tag', '*', { tag_name=> lc $tag });
        $db->update('tag', { user_count => $user_count, label => $tag }, { tag_name => lc $tag });
    }

    $txn->commit;
    $self->redirect_to('/' . $user->id);
}

sub show {
    my $self = shift;
    my $target_user = $self->db->single('user', { id => $self->stash->{profile_id} });
    return $self->render_not_found unless $target_user;
    my $profile = $self->db->single('profile', { user_id => $self->stash->{profile_id} });
    $self->stash->{target_user} = $target_user;
    $self->stash->{profile} = $profile;
    my @profile_tags = $self->db->search('profile_tag', { user_id => $target_user->id });
    $self->stash->{profile_tags} = \@profile_tags;
}

sub delete {
    my $self = shift;
    my $user = $self->user;
    my $txn = $self->db->txn_scope;
    my @profile_tags = $self->db->search('profile_tag',{ user_id => $user->id });
    for my $profile_tag(@profile_tags) {
        my $tag = $self->db->single('tag', { tag_name => $profile_tag->tag_name });
        if($tag->user_count < 2) {
            $self->db->delete('tag',{ tag_name => $tag->tag_name });
        }else{
            $tag->update({ user_count => $tag->user_count - 1 });
        }
    }
    $self->db->delete('profile_tag',{ user_id => $user->id });
    $self->db->delete('user', { id => $user->id });
    $txn->commit;

    $self->session('user', undef);
    $self->session('twitter', undef);
    $self->redirect_to('/');
}

1;
