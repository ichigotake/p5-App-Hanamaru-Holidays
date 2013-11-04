package App::Hanamaru::Holidays;
use strict;
use warnings;
use utf8;

use Plack::Builder;
use Plack::Request;
use Calendar::Japanese::Holiday;
use Time::Local qw/timelocal/;
use Encode qw/encode/;

our $VERSION = 0.01;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub to_app {
    my ($self) = @_;

    use Data::Dumper;
    my (undef, $a) = caller;
    warn Dumper $a;

    Plack::Builder->import;
    return builder {
        mount('/', $self->_build_app);
    };
}

sub _build_app {
    my $self = shift;
    return sub {
        my $env = shift;

        my $req = Plack::Request->new($env);
        my $body = $self->_format_holidays($req->param('year'), $req->param('month'));
        [
            200,
            ['Content-Type' => 'text/plain; charset=utf8'],
            [Encode::encode_utf8($body)]
        ];
    };
}

sub _format_holidays {
    my ($self, $year, $mon) = @_;
    my (undef,undef,undef, undef,$now_mon,$now_year) = localtime(time);
    $year //= $now_year + 1900;
    $mon  //= $now_mon + 1;

    my @weeks = qw/日 月 火 水 木 金 土/;
    my $output = "";
    my $holidays = $self->_get_holidays($year, $mon);

    $output .= $year . "年\n";
    $output .=  "----\n";
    foreach my$d( sort { $a <=> $b } keys %$holidays ) { 
        my $wday = $weeks[ $holidays->{$d}->{wday} ];
        my $name = $holidays->{$d}->{name};
        $output .= "$mon/$d($wday) $name\n";
    }

    return $output;
}


sub _get_holidays {
    my ($self, $year, $mon) = @_;

    my %holidays;
    my $holidays = getHolidays($year, $mon);
    for my$day( 1..31 ) {
        # check date exists
        my $time;
        eval {
            $time = timelocal(0,0,0, $day,$mon-1,$year);
        };
        last if $@;

        my (undef,undef,undef, undef,undef,undef, $wday) = localtime($time);
        # add day in $holidays when date is holiday
        if ( $wday == 6 || $wday == 0 || isHoliday($year, $mon, $day) ) {
            my $name = $holidays->{ $day } || '';
            $holidays{ $day } = {
                wday => $wday,
                name => $name,
            };
        }
    }

    return \%holidays;
}

1;
__DATA__

=encoding utf8

=head1 NAME

App::Hanamaru::Holidays - 月の休日の一覧を出力します。

=head1 SYNOPSIS

    $ carton install && carton exec -- plackup
    
=head1 TODO

- 振り替え休日が考慮されていない

- 依存モジュールの定義ファイルを設置

- JSONレスポンス

- WEBフォーム

=head1 AUTHOR

ichigotake

=cut

